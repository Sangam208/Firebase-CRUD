package com.example.my_app

import android.content.ContentValues
import android.content.Context
import android.provider.MediaStore
import android.os.Build
import android.content.Intent
import android.net.Uri
import android.media.MediaScannerConnection
import androidx.annotation.RequiresApi
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yourcompany.yourapp/media_scan"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scanMedia") {  // Ensure this matches your Dart method name
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    scanFile(filePath)
                    result.success("File scanned")
                } else {
                    result.error("INVALID_ARGUMENT", "File path is missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scanFile(filePath: String) {
        val file = File(filePath)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // ✅ Correct way to trigger media scan for Android 10+
            MediaScannerConnection.scanFile(
                applicationContext, 
                arrayOf(file.absolutePath), 
                null
            ) { path, uri ->
                println("Scanned: $path -> URI: $uri")
            }
        } else {
            val values = ContentValues()
            values.put(MediaStore.Images.Media.DATA, file.absolutePath)
            applicationContext.contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
        }
    }
}
