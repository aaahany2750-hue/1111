package com.flashtransfer.app

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.net.wifi.p2p.WifiP2pManager
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodChannel

class PeerDiscoveryManager(
    private val activity: Activity,
    private val manager: WifiP2pManager,
    private val channel: WifiP2pManager.Channel,
    private val events: (Map<String, Any?>) -> Unit,
) {
    private val peersByAddress = linkedMapOf<String, PeerDto>()

    private val peerListener = WifiP2pManager.PeerListListener { peerList ->
        peersByAddress.clear()
        peerList.deviceList.map(PeerDto::fromDevice).forEach { peer ->
            peersByAddress[peer.address] = peer
        }
        events(mapOf("type" to "peers", "peers" to peers()))
    }

    fun peers(): List<Map<String, Any?>> = peersByAddress.values.map(PeerDto::toMap)

    fun discover(result: MethodChannel.Result?) {
        if (!hasPeerPermission()) {
            result?.error("PERMISSION_DENIED", "Wi-Fi Direct discovery permission is not granted", null)
            return
        }
        manager.discoverPeers(channel, action(result) {
            requestPeers()
            result?.success(peers())
        })
    }

    fun requestPeers() {
        if (!hasPeerPermission()) {
            events(mapOf("type" to "permission", "granted" to false))
            return
        }
        manager.requestPeers(channel, peerListener)
    }

    fun stopDiscovery(result: MethodChannel.Result?) {
        manager.stopPeerDiscovery(channel, action(result) {
            result?.success(true)
        })
    }

    private fun hasPeerPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(activity, Manifest.permission.NEARBY_WIFI_DEVICES) == PackageManager.PERMISSION_GRANTED
    }

    private fun action(result: MethodChannel.Result?, onSuccess: () -> Unit): WifiP2pManager.ActionListener {
        return object : WifiP2pManager.ActionListener {
            override fun onSuccess() = onSuccess()
            override fun onFailure(reason: Int) {
                result?.error("WIFI_DIRECT", "Wi-Fi Direct operation failed with reason $reason", reason)
                events(mapOf("type" to "wifiError", "reason" to reason))
            }
        }
    }
}
