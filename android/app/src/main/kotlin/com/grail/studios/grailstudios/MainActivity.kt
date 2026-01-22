package com.grail.studios.grailstudios

import io.flutter.embedding.android.FlutterActivity
import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.webkit.MimeTypeMap

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.grail.studios/downloads"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val bytes = call.argument<ByteArray>("bytes")
                val fileName = call.argument<String>("fileName")

                if (bytes != null && fileName != null) {
                    try {
                        val mimeType = getMimeType(fileName) ?: "application/octet-stream"
                        saveFileToDownloads(fileName, bytes, mimeType)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Bytes or fileName missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveFileToDownloads(fileName: String, bytes: ByteArray, mimeType: String) {
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/GrailStudios")
            }
        }

        val resolver = contentResolver
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            ?: throw Exception("Failed to create file in Downloads")

        resolver.openOutputStream(uri).use { outputStream ->
            outputStream?.write(bytes)
            outputStream?.flush()
        }
    }

    private fun getMimeType(fileName: String): String? {
        val extension = fileName.substringAfterLast('.', "")
        return if (extension.isNotEmpty()) {
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.lowercase())
        } else null
    }
}
