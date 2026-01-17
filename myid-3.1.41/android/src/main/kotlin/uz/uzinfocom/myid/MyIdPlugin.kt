package uz.uzinfocom.myid

import android.content.Context
import androidx.annotation.Keep
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import uz.myid.android.sdk.capture.MyIdClient

@Keep
class MyIdPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var myidSdk: MyIdSdk
    private lateinit var activityListener: MyIdSdkActivityListener
    private lateinit var methodChannel: MethodChannel
    private lateinit var applicationContext: Context
    private lateinit var pluginBinding: ActivityPluginBinding

    private val myidClient = MyIdClient()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        onAttachedToEngine(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "startSdk") {
            val config = call.arguments as HashMap<*, *>
            @Suppress("UNCHECKED_CAST")
            myidSdk.start(config["config"] as? HashMap<String, Any?>, result)
        } else {
            result.notImplemented()
        }
    }

    private fun onAttachedToEngine(context: Context, messenger: BinaryMessenger) {
        applicationContext = context
        methodChannel = MethodChannel(messenger, "myid_uz")
        methodChannel.setMethodCallHandler(this)
        activityListener = MyIdSdkActivityListener(myidClient)
        myidSdk = MyIdSdk(myidClient, activityListener)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        myidSdk.setActivity(null)
        pluginBinding.removeActivityResultListener(activityListener)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        myidSdk.setActivity(binding.activity)
        pluginBinding = binding
        pluginBinding.addActivityResultListener(activityListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
