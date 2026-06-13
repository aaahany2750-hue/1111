package com.flashtransfer.app

import android.content.Context
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedInputStream
import java.io.DataInputStream
import java.io.File
import java.io.FileOutputStream
import java.net.ServerSocket
import java.security.MessageDigest
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class TransferServer(
    private val context: Context,
    private val events: (Map<String, Any?>) -> Unit,
) {
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())
    private val running = AtomicBoolean(false)
    private var serverSocket: ServerSocket? = null

    fun start(port: Int, result: MethodChannel.Result) {
        if (!running.compareAndSet(false, true)) {
            result.success(true)
            return
        }
        executor.execute {
            var acknowledged = false
            try {
                ServerSocket(port).use { socket ->
                    serverSocket = socket
                    mainHandler.post { result.success(true) }
                    acknowledged = true
                    events(mapOf("type" to "server", "running" to true, "port" to port))
                    while (running.get()) {
                        val client = socket.accept()
                        client.use { accepted -> receive(DataInputStream(BufferedInputStream(accepted.getInputStream()))) }
                    }
                }
            } catch (error: Exception) {
                if (!acknowledged) {
                    mainHandler.post { result.error("TRANSFER_SERVER", error.message, null) }
                }
                events(mapOf("type" to "server", "running" to false, "error" to error.message))
            } finally {
                running.set(false)
                serverSocket = null
            }
        }
    }

    fun stop(result: MethodChannel.Result?) {
        running.set(false)
        serverSocket?.close()
        serverSocket = null
        events(mapOf("type" to "server", "running" to false))
        result?.success(true)
    }

    private fun receive(input: DataInputStream) {
        input.use { stream ->
            val magic = stream.readUTF()
            require(magic == TransferClient.PROTOCOL_MAGIC) { "Unsupported transfer protocol: $magic" }
            val fileName = sanitizeFileName(stream.readUTF())
            val totalBytes = stream.readLong()
            val expectedSha256 = stream.readUTF()
            val destination = uniqueDestination(fileName)
            val digest = MessageDigest.getInstance("SHA-256")
            val buffer = ByteArray(BUFFER_SIZE)
            var received = 0L
            val start = System.nanoTime()
            FileOutputStream(destination).use { output ->
                while (totalBytes < 0 || received < totalBytes) {
                    val remaining = if (totalBytes < 0) buffer.size else (totalBytes - received).coerceAtMost(buffer.size.toLong()).toInt()
                    val read = stream.read(buffer, 0, remaining)
                    if (read <= 0) break
                    output.write(buffer, 0, read)
                    digest.update(buffer, 0, read)
                    received += read.toLong()
                    emitProgress(fileName, received, totalBytes, start, false)
                }
            }
            val actualSha256 = digest.digest().joinToString(separator = "") { byte -> "%02x".format(byte) }
            val verified = actualSha256.equals(expectedSha256, ignoreCase = true)
            events(mapOf("type" to "verification", "fileName" to fileName, "verified" to verified, "sha256" to actualSha256, "path" to destination.absolutePath))
            emitProgress(fileName, received, totalBytes, start, true)
            require(verified) { "SHA-256 verification failed for $fileName" }
        }
    }

    private fun uniqueDestination(fileName: String): File {
        val dir = File(context.getExternalFilesDir(null), "FlashTransfer/Received").apply { mkdirs() }
        var candidate = File(dir, fileName)
        var index = 1
        val extension = candidate.extension.takeIf { it.isNotBlank() }?.let { ".$it" } ?: ""
        val base = candidate.nameWithoutExtension
        while (candidate.exists()) {
            candidate = File(dir, "$base-$index$extension")
            index += 1
        }
        return candidate
    }

    private fun sanitizeFileName(name: String): String = name.replace(Regex("[^A-Za-z0-9._ -]"), "_").ifBlank { "flashtransfer-file" }

    private fun emitProgress(fileName: String, received: Long, total: Long, start: Long, done: Boolean) {
        val elapsedSeconds = ((System.nanoTime() - start).coerceAtLeast(1L)) / 1_000_000_000.0
        events(TransferProgress(fileName, received, total, (received / elapsedSeconds).toLong(), done).toMap())
    }

    companion object {
        private const val BUFFER_SIZE = 1024 * 1024
    }
}
