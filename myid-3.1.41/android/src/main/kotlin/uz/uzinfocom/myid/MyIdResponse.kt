package uz.uzinfocom.myid

import androidx.annotation.Keep

@Keep
data class MyIdResponse(
    val code: String? = null,
    val base64: String? = null
) {

    fun toMap(): HashMap<String, String> {
        val map: HashMap<String, String> = HashMap()

        code?.let { map["code"] = it }
        base64?.let { map["base64"] = it }

        return map
    }
}