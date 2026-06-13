package com.flashtransfer.app

import android.content.Context
import android.net.Uri
import java.security.MessageDigest

object HashVerifier {
    private const val BUFFER_SIZE = 1024 * 1024

    fun sha256(context: Context, uriText: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        context.contentResolver.openInputStream(Uri.parse(uriText)).use { input ->
            requireNotNull(input) { "Unable to open input stream for $uriText" }
            val buffer = ByteArray(BUFFER_SIZE)
            while (true) {
                val read = input.read(buffer)
                if (read <= 0) break
                digest.update(buffer, 0, read)
            }
        }
        return digest.digest().joinToString(separator = "") { byte -> "%02x".format(byte) }
    }
}
