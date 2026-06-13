package com.flashtransfer.app

import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedOutputStream
import java.io.DataOutputStream
import java.net.InetSocketAddress
import java.net.Socket
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class TransferClient(
    private val context: Context,
    private val events: (Map<String, Any?>) -> Unit,
) {
    private val executor = Executors.newSingleThreadExecutor()
    private val cancelled = AtomicBoolean(false)
    private val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())

    fun send(uriText: String, host: String, port: Int, expectedSha256: String?, result: MethodChannel.Result) {
        cancelled.set(false)
        executor.execute {
            try {
                val uri = Uri.parse(uriText)
                val fileName = displayName(uri)
                val size = fileSize(uri)
                val sha = expectedSha256 ?: HashVerifier.sha256(context, uriText)
                Socket().use { socket ->
                    socket.connect(InetSocketAddress(host, port), CONNECT_TIMEOUT_MILLIS)
                    DataOutputStream(BufferedOutputStream(socket.getOutputStream())).use { output ->
                        output.writeUTF(PROTOCOL_MAGIC)
                        output.writeUTF(fileName)
                        output.writeLong(size)
                        output.writeUTF(sha)
                        context.contentResolver.openInputStream(uri).use { input ->
                            requireNotNull(input) { "Unable to open input stream for $uriText" }
                            val buffer = ByteArray(BUFFER_SIZE)
                            var sent = 0L
                            val start = System.nanoTime()
                            while (true) {
                                if (cancelled.get()) throw java.io.InterruptedIOException("Transfer cancelled")
                                val read = input.read(buffer)
                                if (read <= 0) break
                                output.write(buffer, 0, read)
                                sent += read.toLong()
                                emitProgress(fileName, sent, size, start, false)
                            }
                            output.flush()
                            emitProgress(fileName, sent, size, start, true)
                        }
                    }
                }
                mainHandler.post { result.success(true) }
            } catch (error: Exception) {
                mainHandler.post { result.error("TRANSFER_CLIENT", error.message, null) }
            }
        }
    }

    fun cancel(result: MethodChannel.Result) {
        cancelled.set(true)
        mainHandler.post { result.success(true) }
    }

    private fun displayName(uri: Uri): String {
        var name: String? = null
        context.contentResolver.query(uri, null, null, null, null).use { cursor: Cursor? ->
            if (cursor != null && cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) name = cursor.getString(index)
            }
        }
        return name ?: uri.lastPathSegment ?: "flashtransfer-file"
    }

    private fun fileSize(uri: Uri): Long {
        context.contentResolver.query(uri, null, null, null, null).use { cursor: Cursor? ->
            if (cursor != null && cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (index >= 0) return cursor.getLong(index)
            }
        }
        return -1L
    }

    private fun emitProgress(fileName: String, sent: Long, size: Long, start: Long, done: Boolean) {
        val elapsedSeconds = ((System.nanoTime() - start).coerceAtLeast(1L)) / 1_000_000_000.0
        val speed = (sent / elapsedSeconds).toLong()
        events(TransferProgress(fileName, sent, size, speed, done).toMap())
    }

    companion object {
        const val PROTOCOL_MAGIC = "FLASHTRANSFER_V1"
        private const val BUFFER_SIZE = 1024 * 1024
        private const val CONNECT_TIMEOUT_MILLIS = 15_000
    }
}
