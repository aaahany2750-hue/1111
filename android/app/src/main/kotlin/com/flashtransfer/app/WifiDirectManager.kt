package com.flashtransfer.app

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.NetworkInfo
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build

class WifiDirectManager(
    private val activity: Activity,
    private val events: (Map<String, Any?>) -> Unit,
) {
    val manager: WifiP2pManager = activity.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
    val channel: WifiP2pManager.Channel = manager.initialize(activity, activity.mainLooper, null)

    val peerDiscoveryManager = PeerDiscoveryManager(activity, manager, channel, events)
    val connectionManager = ConnectionManager(activity, manager, channel, events)

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                    val state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, WifiP2pManager.WIFI_P2P_STATE_DISABLED)
                    events(mapOf("type" to "wifiState", "enabled" to (state == WifiP2pManager.WIFI_P2P_STATE_ENABLED)))
                }
                WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> peerDiscoveryManager.requestPeers()
                WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                    val networkInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO, NetworkInfo::class.java)
                    } else {
                        @Suppress("DEPRECATION") intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO)
                    }
                    if (networkInfo?.isConnected == true) connectionManager.requestConnectionInfo() else connectionManager.markDisconnected()
                }
                WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> events(mapOf("type" to "deviceChanged"))
            }
        }
    }

    private var registered = false

    fun start() {
        if (registered) return
        val filter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION") activity.registerReceiver(receiver, filter)
        }
        registered = true
    }

    fun dispose() {
        if (registered) activity.unregisterReceiver(receiver)
        registered = false
        peerDiscoveryManager.stopDiscovery(null)
        connectionManager.disconnect(null)
    }
}
