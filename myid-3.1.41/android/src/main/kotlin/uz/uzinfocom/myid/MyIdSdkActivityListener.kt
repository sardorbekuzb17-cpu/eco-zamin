package uz.uzinfocom.myid

import android.content.Intent
import android.graphics.Bitmap
import android.util.Base64
import androidx.annotation.Keep
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import uz.myid.android.sdk.capture.MyIdClient
import uz.myid.android.sdk.capture.MyIdException
import uz.myid.android.sdk.capture.MyIdResult
import uz.myid.android.sdk.capture.MyIdResultListener
import uz.myid.android.sdk.capture.model.MyIdEvent
import uz.myid.android.sdk.capture.model.MyIdGraphicFieldType
import uz.myid.android.sdk.capture.model.MyIdImageFormat
import java.io.ByteArrayOutputStream

@Keep
class MyIdSdkActivityListener(
    private val client: MyIdClient
) : PluginRegistry.ActivityResultListener {

    private var flutterResult: MethodChannel.Result? = null

    fun setCurrentFlutterResult(result: MethodChannel.Result?) {
        this.flutterResult = result
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        client.handleActivityResult(resultCode, object : MyIdResultListener {
            override fun onSuccess(result: MyIdResult) {
                if (flutterResult != null) {
                    try {
                        val bitmap =
                            result.getGraphicFieldImageByType(MyIdGraphicFieldType.FacePortrait)

                        val response = MyIdResponse(
                            code = result.code,
                            base64 = bitmap?.toBase64()
                        )
                        flutterResult?.success(response.toMap())
                    } catch (e: Exception) {
                        val response = MyIdResponse(code = result.code)
                        flutterResult?.success(response.toMap())
                    } finally {
                        flutterResult = null
                    }
                }
            }

            override fun onError(exception: MyIdException) {
                if (flutterResult != null) {
                    flutterResult?.error(
                        exception.code.toString(),
                        exception.message,
                        null
                    )
                    flutterResult = null
                }
            }

            override fun onUserExited() {
                if (flutterResult != null) {
                    flutterResult?.error(
                        "101",
                        "User canceled flow",
                        null
                    )
                    flutterResult = null
                }
            }

            override fun onEvent(event: MyIdEvent) {
            }
        })
        return true
    }

    private fun Bitmap?.toBase64(
        format: MyIdImageFormat = MyIdImageFormat.JPEG
    ): String? {
        this ?: return null

        return Base64.encodeToString(toByteArray(format), Base64.NO_WRAP)
    }

    private fun Bitmap.toByteArray(
        format: MyIdImageFormat,
        quality: Int = 100
    ): ByteArray? {
        val compressFormat = when (format) {
            MyIdImageFormat.JPEG -> Bitmap.CompressFormat.JPEG
            MyIdImageFormat.PNG -> Bitmap.CompressFormat.PNG
        }

        ByteArrayOutputStream().use { stream ->
            compress(compressFormat, quality, stream)
            return stream.toByteArray()
        }
    }
}