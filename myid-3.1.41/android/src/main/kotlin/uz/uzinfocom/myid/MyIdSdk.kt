package uz.uzinfocom.myid

import android.app.Activity
import android.content.Context
import android.content.res.Resources.NotFoundException
import android.os.Build
import androidx.annotation.Keep
import io.flutter.plugin.common.MethodChannel
import uz.myid.android.sdk.capture.MyIdClient
import uz.myid.android.sdk.capture.MyIdConfig
import uz.myid.android.sdk.capture.MyIdException
import uz.myid.android.sdk.capture.MyIdResult
import uz.myid.android.sdk.capture.MyIdResultListener
import uz.myid.android.sdk.capture.model.MyIdCameraResolution
import uz.myid.android.sdk.capture.model.MyIdCameraSelector
import uz.myid.android.sdk.capture.model.MyIdCameraShape
import uz.myid.android.sdk.capture.model.MyIdEntryType
import uz.myid.android.sdk.capture.model.MyIdEnvironment
import uz.myid.android.sdk.capture.model.MyIdEvent
import uz.myid.android.sdk.capture.model.MyIdImageFormat
import uz.myid.android.sdk.capture.model.MyIdLocale
import uz.myid.android.sdk.capture.model.MyIdOrganizationDetails
import uz.myid.android.sdk.capture.model.MyIdResidency

@Keep
class MyIdSdk(
    private val client: MyIdClient,
    private val activityListener: MyIdSdkActivityListener,
) {

    private var currentFlutterResult: MethodChannel.Result? = null
    private var currentActivity: Activity? = null

    private fun setFlutterResult(result: MethodChannel.Result?) {
        currentFlutterResult = result
        activityListener.setCurrentFlutterResult(result)
    }

    fun setActivity(activity: Activity?) {
        if (activity != null) {
            currentActivity = activity
        }
    }

    fun start(
        config: HashMap<String, Any?>?,
        result: MethodChannel.Result?
    ) {
        setFlutterResult(result)

        try {
            if (config == null) {
                currentFlutterResult?.error(
                    "103",
                    "MyID config is null",
                    null
                )
                setFlutterResult(null)
                return
            }

            val sessionId: String
            val clientHash: String
            val clientHashId: String
            val minAge: Int
            val distance: Float
            val residency: MyIdResidency
            val environment: MyIdEnvironment
            val entryType: MyIdEntryType
            val locale: MyIdLocale
            val cameraShape: MyIdCameraShape
            val cameraSelector: MyIdCameraSelector
            val cameraResolution: MyIdCameraResolution
            val imageFormat: MyIdImageFormat
            val organizationDetails: MyIdOrganizationDetails
            val withSoundGuides: Boolean
            val showErrorScreen: Boolean
            val huaweiAppId: String

            try {
                sessionId = config.fetch("sessionId")
                clientHash = config.fetch("clientHash")
                clientHashId = config.fetch("clientHashId")
                minAge = config.fetch("minAge").toIntOrNull() ?: 16
                distance = config.fetch("distance").toFloatOrNull() ?: 0.65f

                environment = when (config.fetch("environment").uppercase()) {
                    "DEBUG" -> MyIdEnvironment.Debug
                    else -> MyIdEnvironment.Production
                }
                entryType = when (config.fetch("entryType").uppercase()) {
                    "FACE_DETECTION" -> MyIdEntryType.FaceDetection
                    "VIDEO_IDENTIFICATION" -> MyIdEntryType.VideoIdentification
                    else -> MyIdEntryType.Identification
                }
                residency = when (config.fetch("residency").uppercase()) {
                    "USER_DEFINED" -> MyIdResidency.UserDefined
                    "NON_RESIDENT" -> MyIdResidency.NonResident
                    else -> MyIdResidency.Resident
                }
                locale = when (config.fetch("locale").uppercase()) {
                    "UZBEK_CYRILLIC" -> MyIdLocale.UzbekCyrillic
                    "ENGLISH" -> MyIdLocale.English
                    "RUSSIAN" -> MyIdLocale.Russian
                    "TAJIK" -> MyIdLocale.Tajik
                    "KARAKALPAK" -> MyIdLocale.Karakalpak
                    else -> MyIdLocale.Uzbek
                }
                cameraShape = when (config.fetch("cameraShape").uppercase()) {
                    "ELLIPSE" -> MyIdCameraShape.Ellipse
                    else -> MyIdCameraShape.Circle
                }
                cameraSelector = when (config.fetch("cameraSelector").uppercase()) {
                    "BACK" -> MyIdCameraSelector.Back
                    else -> MyIdCameraSelector.Front
                }
                cameraResolution = when (config.fetch("cameraResolution").uppercase()) {
                    "HIGH" -> MyIdCameraResolution.High
                    else -> MyIdCameraResolution.Low
                }
                imageFormat = when (config.fetch("imageFormat").uppercase()) {
                    "JPEG" -> MyIdImageFormat.JPEG
                    else -> MyIdImageFormat.PNG
                }

                val orgMap = config["organizationDetails"] as? HashMap<String, Any?>

                val drawableName = orgMap?.fetch("logo")
                val drawableId = try {
                    currentActivity?.resIdByName(drawableName, "drawable")
                } catch (e: NotFoundException) {
                    null
                }

                organizationDetails = MyIdOrganizationDetails(
                    phoneNumber = orgMap?.fetch("phone"),
                    logo = drawableId,
                )

                showErrorScreen = config.fetch("showErrorScreen").toBooleanStrictOrNull() ?: true
                withSoundGuides = config.fetch("withSoundGuides").toBooleanStrictOrNull() ?: false

                huaweiAppId = config.fetch("huaweiAppId")
            } catch (e: Exception) {
                currentFlutterResult?.error(
                    "103",
                    "MyID config error: ${e.message}",
                    null
                )
                setFlutterResult(null)
                return
            }

            if (currentActivity == null) {
                currentFlutterResult?.error(
                    "103",
                    "Android activity does not exist",
                    null
                )
                setFlutterResult(null)
                return
            }

            try {
                val myidConfig = MyIdConfig.Builder(sessionId)
                    .withClientHash(clientHash, clientHashId)
                    .withMinAge(minAge)
                    .withResidency(residency)
                    .withEnvironment(environment)
                    .withEntryType(entryType)
                    .withLocale(locale)
                    .withCameraResolution(cameraResolution)
                    .withCameraShape(cameraShape)
                    .withCameraSelector(cameraSelector)
                    .withImageFormat(imageFormat)
                    .withOrganizationDetails(organizationDetails)
                    .withDistance(distance)
                    .withSoundGuides(withSoundGuides)
                    .withErrorScreen(showErrorScreen)
                    .withHuaweiAppId(huaweiAppId)
                    .build()

                currentActivity?.let {
                    client.startActivityForResult(
                        activity = it,
                        requestCode = 1,
                        config = myidConfig,
                        listener = object : MyIdResultListener {
                            override fun onSuccess(result: MyIdResult) {
                            }

                            override fun onError(exception: MyIdException) {
                            }

                            override fun onUserExited() {
                            }

                            override fun onEvent(event: MyIdEvent) {
                            }
                        }
                    )
                }
            } catch (e: Exception) {
                currentFlutterResult?.error(
                    "error",
                    "Failed to show MyID page: ${e.message}",
                    null
                )
                setFlutterResult(null)
                return
            }
        } catch (e: Exception) {
            currentFlutterResult?.error(
                "103",
                "Unexpected error starting MyID page: ${e.message}",
                null
            )
            setFlutterResult(null)
            return
        }
    }

    private fun <T> HashMap<String, T>.fetch(key: String): String {
        val result = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            getOrDefault(key, "")
        } else {
            if (containsKey(key)) {
                this[key] ?: ""
            } else {
                ""
            }
        }
        return result?.toString().orEmpty()
    }

    private fun Context.resIdByName(resIdName: String?, resType: String): Int {
        resIdName?.let {
            return resources.getIdentifier(it, resType, packageName)
        }
        throw NotFoundException()
    }
}