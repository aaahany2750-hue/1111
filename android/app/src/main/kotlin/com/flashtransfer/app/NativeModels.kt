package com.flashtransfer.app

import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pInfo

data class PeerDto(
    val name: String,
    val address: String,
    val status: Int,
    val isGroupOwner: Boolean,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "name" to name,
        "address" to address,
        "status" to status,
        "isGroupOwner" to isGroupOwner,
    )

    companion object {
        fun fromDevice(device: WifiP2pDevice): PeerDto = PeerDto(
            name = device.deviceName ?: "Android Device",
            address = device.deviceAddress,
            status = device.status,
            isGroupOwner = device.isGroupOwner,
        )
    }
}

data class ConnectionDto(
    val connected: Boolean,
    val groupOwnerAddress: String?,
    val isGroupOwner: Boolean,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "connected" to connected,
        "groupOwnerAddress" to groupOwnerAddress,
        "isGroupOwner" to isGroupOwner,
    )

    companion object {
        fun fromInfo(info: WifiP2pInfo?): ConnectionDto = ConnectionDto(
            connected = info?.groupFormed == true,
            groupOwnerAddress = info?.groupOwnerAddress?.hostAddress,
            isGroupOwner = info?.isGroupOwner == true,
        )
    }
}

data class TransferProgress(
    val fileName: String,
    val transferredBytes: Long,
    val totalBytes: Long,
    val speedBytesPerSecond: Long,
    val done: Boolean,
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "type" to "transferProgress",
        "fileName" to fileName,
        "transferredBytes" to transferredBytes,
        "totalBytes" to totalBytes,
        "speedBytesPerSecond" to speedBytesPerSecond,
        "done" to done,
    )
}
