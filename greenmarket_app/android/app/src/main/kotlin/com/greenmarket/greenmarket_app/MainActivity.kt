package com.greenmarket.greenmarket_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.greenmarket.greenmarket_app/deeplink"
    private val SECURITY_CHANNEL = "com.greenmarket.app/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Deep link channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                result.notImplemented()
            }

        // Xavfsizlik channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isDeviceRooted" -> {
                        result.success(isDeviceRooted())
                    }
                    "isEmulator" -> {
                        result.success(isEmulator())
                    }
                    else -> result.notImplemented()
                }
            }

        // Deep link'ni handle qilish
        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent) {
        val action = intent.action
        val data = intent.data

        if (action == Intent.ACTION_VIEW && data != null) {
            val uri = data.toString()
            println("🔗 Deep Link: $uri")

            // Flutter'ga deep link'ni yuborish
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("handleDeepLink", uri)
        }
    }

    /// Qurilma root'langan yoki yo'qligini tekshirish
    private fun isDeviceRooted(): Boolean {
        return try {
            val buildTags = Build.TAGS
            if (buildTags != null && buildTags.contains("test-keys")) {
                return true
            }

            val paths = arrayOf(
                "/system/app/Superuser.apk",
                "/system/xbin/su",
                "/system/bin/su",
                "/data/local/xbin/su",
                "/data/local/bin/su",
                "/system/sd/xbin/su",
                "/system/bin/failsafe/su",
                "/data/local/su",
                "/su/bin/su"
            )

            for (path in paths) {
                if (java.io.File(path).exists()) {
                    return true
                }
            }

            false
        } catch (e: Exception) {
            false
        }
    }

    /// Emulyatorni tekshirish
    private fun isEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("generic") ||
                Build.FINGERPRINT.startsWith("unknown") ||
                Build.MODEL.contains("google_sdk") ||
                Build.MODEL.contains("Emulator") ||
                Build.MODEL.contains("Android SDK built for x86") ||
                Build.MANUFACTURER.contains("Genymotion") ||
                (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
                "Qemu" == Build.HARDWARE ||
                Build.HARDWARE.contains("goldfish") ||
                Build.HARDWARE.contains("ranchu"))
    }
}

