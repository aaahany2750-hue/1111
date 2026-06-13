package com.flashtransfer.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MethodChannelBridge(
    private val activity: FlutterActivity,
    engine: FlutterEngine,
) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val wifiDirectManager = WifiDirectManager(activity) { event -> sendEvent(event) }
    private val transferServer = TransferServer(activity) { event -> sendEvent(event) }
    private val transferClient = TransferClient(activity) { event -> sendEvent(event) }
    private val methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(engine.dartExecutor.binaryMessenger, EVENT_CHANNEL)

    init {
        methodChannel.setMethodCallHandler(::onMethodCall)
        eventChannel.setStreamHandler(this)
        wifiDirectManager.start()
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "discoverPeers" -> wifiDirectManager.peerDiscoveryManager.discover(result)
                "stopDiscovery" -> wifiDirectManager.peerDiscoveryManager.stopDiscovery(result)
                "getPeers" -> result.success(wifiDirectManager.peerDiscoveryManager.peers())
                "connect" -> wifiDirectManager.connectionManager.connect(
                    address = requireArgument(call, "address"),
                    timeoutMillis = longArgument(call, "timeoutMillis", DEFAULT_CONNECT_TIMEOUT_MILLIS),
                    result = result,
                )
                "disconnect" -> wifiDirectManager.connectionManager.disconnect(result)
                "getConnectionInfo" -> wifiDirectManager.connectionManager.requestConnectionInfo(result)
                "startServer" -> transferServer.start(intArgument(call, "port", DEFAULT_PORT), result)
                "stopServer" -> transferServer.stop(result)
                "sendFile" -> transferClient.send(
                    uriText = requireArgument(call, "uri"),
                    host = requireArgument(call, "host"),
                    port = intArgument(call, "port", DEFAULT_PORT),
                    expectedSha256 = call.argument<String>("sha256"),
                    result = result,
                )
                "cancelTransfers" -> transferClient.cancel(result)
                "sha256" -> result.success(HashVerifier.sha256(activity, requireArgument(call, "uri")))
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error("FLASH_NATIVE", error.message, null)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        transferServer.stop(null)
        wifiDirectManager.dispose()
    }

    private fun sendEvent(event: Map<String, Any?>) {
        activity.runOnUiThread { eventSink?.success(event) }
    }

    private fun requireArgument(call: MethodCall, name: String): String {
        return requireNotNull(call.argument<String>(name)) { "Missing required argument: $name" }
    }

    private fun intArgument(call: MethodCall, name: String, fallback: Int): Int {
        return when (val value = call.argument<Any>(name)) {
            is Int -> value
            is Long -> value.toInt()
            is Number -> value.toInt()
            else -> fallback
        }
    }

    private fun longArgument(call: MethodCall, name: String, fallback: Long): Long {
        return when (val value = call.argument<Any>(name)) {
            is Long -> value
            is Int -> value.toLong()
            is Number -> value.toLong()
            else -> fallback
        }
    }

    companion object {
        private const val METHOD_CHANNEL = "flashtransfer/native"
        private const val EVENT_CHANNEL = "flashtransfer/native/events"
        private const val DEFAULT_PORT = 8988
        private const val DEFAULT_CONNECT_TIMEOUT_MILLIS = 30_000L
    }
}
