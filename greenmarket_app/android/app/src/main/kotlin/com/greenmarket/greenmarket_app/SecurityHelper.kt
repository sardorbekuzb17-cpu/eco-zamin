package com.greenmarket.greenmarket_app

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.Signature
import java.security.MessageDigest

class SecurityHelper {
    companion object {
        // APK imzosini tekshirish
        fun checkSignature(context: Context): Boolean {
            try {
                val packageInfo = context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
                
                val signatures = packageInfo.signatures
                if (signatures != null && signatures.isNotEmpty()) {
                    for (signature in signatures) {
                        val md = MessageDigest.getInstance("SHA-256")
                        md.update(signature.toByteArray())
                        val signatureHash = bytesToHex(md.digest())
                        
                        // Bu yerda kutilayotgan imzo hash'ini tekshiring
                        // Production'da o'z imzo hash'ingizni qo'ying
                        // val expectedHash = "YOUR_SIGNATURE_HASH_HERE"
                        // if (signatureHash != expectedHash) return false
                    }
                }
                
                return true
            } catch (e: Exception) {
                return false
            }
        }
        
        // Root tekshiruvi
        fun isRooted(): Boolean {
            // Su binary mavjudligini tekshirish
            val paths = arrayOf(
                "/system/app/Superuser.apk",
                "/sbin/su",
                "/system/bin/su",
                "/system/xbin/su",
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
            
            return false
        }
        
        private fun bytesToHex(bytes: ByteArray): String {
            val hexArray = "0123456789ABCDEF".toCharArray()
            val hexChars = CharArray(bytes.size * 2)
            for (j in bytes.indices) {
                val v = bytes[j].toInt() and 0xFF
                hexChars[j * 2] = hexArray[v ushr 4]
                hexChars[j * 2 + 1] = hexArray[v and 0x0F]
            }
            return String(hexChars)
        }
    }
}
