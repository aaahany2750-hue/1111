package com.flashtransfer.app

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodChannel

class ConnectionManager(
    private val activity: Activity,
    private val manager: WifiP2pManager,
    private val channel: WifiP2pManager.Channel,
    private val events: (Map<String, Any?>) -> Unit,
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var latestInfo: WifiP2pInfo? = null

    fun connect(address: String, timeoutMillis: Long, result: MethodChannel.Result) {
        if (!hasConnectionPermission()) {
            result.error("PERMISSION_DENIED", "Wi-Fi Direct connection permission is not granted", null)
            return
        }
        val config = WifiP2pConfig().apply {
            deviceAddress = address
            wps.setup = WpsInfo.PBC
        }
        var completed = false
        val timeout = Runnable {
            if (!completed) {
                completed = true
                disconnect(null)
                result.error("CONNECTION_TIMEOUT", "Timed out connecting to $address", null)
            }
        }
        mainHandler.postDelayed(timeout, timeoutMillis)
        manager.connect(channel, config, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                if (!completed) {
                    completed = true
                    mainHandler.removeCallbacks(timeout)
                    requestConnectionInfo()
                    result.success(true)
                }
            }

            override fun onFailure(reason: Int) {
                if (!completed) {
                    completed = true
                    mainHandler.removeCallbacks(timeout)
                    result.error("WIFI_DIRECT_CONNECT", "Connection failed with reason $reason", reason)
                }
            }
        })
    }

    fun disconnect(result: MethodChannel.Result?) {
        manager.removeGroup(channel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                latestInfo = null
                events(ConnectionDto(false, null, false).toMap() + mapOf("type" to "connection"))
                result?.success(true)
            }

            override fun onFailure(reason: Int) {
                result?.error("WIFI_DIRECT_DISCONNECT", "Disconnect failed with reason $reason", reason)
            }
        })
    }

    fun requestConnectionInfo(result: MethodChannel.Result? = null) {
        manager.requestConnectionInfo(channel) { info ->
            latestInfo = info
            val map = ConnectionDto.fromInfo(info).toMap() + mapOf("type" to "connection")
            events(map)
            result?.success(map)
        }
    }

    fun markDisconnected() {
        latestInfo = null
        events(ConnectionDto(false, null, false).toMap() + mapOf("type" to "connection"))
    }

    private fun hasConnectionPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(activity, Manifest.permission.NEARBY_WIFI_DEVICES) == PackageManager.PERMISSION_GRANTED
    }
}
