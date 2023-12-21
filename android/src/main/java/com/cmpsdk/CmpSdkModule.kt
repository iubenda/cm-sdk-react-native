package com.cmpsdk

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule

import net.consentmanager.sdk.CmpManager
import net.consentmanager.sdk.consentlayer.model.CmpConfig
import org.json.JSONArray
import java.lang.Exception

class CmpSdkModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private var consentManager : CmpManager? = null
  private var listenerCount = 0
  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun createInstance(id: String, domain: String, appName : String, language: String) {
    CmpConfig.id = id
    CmpConfig.domain = domain
    CmpConfig.appName = appName
    CmpConfig.language = language
    CmpConfig.timeout = 5000
    consentManager = CmpManager.createInstance(reactApplicationContext, CmpConfig)
    setCallbacks()
  }
  @ReactMethod
  fun createInstanceByConfig(config: ReadableMap) {
    val id = config.getString("id")
    val domain = config.getString("domain")
    val appName = config.getString("appName")
    val language = config.getString("language")
    val idfaOrGaid = config.getString("idfaOrGaid")
    val timeout = config.getInt("timeout")
    val jumpToSettingsPage = config.getBoolean("jumpToSettingsPage")
    val dialogBgColor = config.getString("dialogBgColor")
    val designId = config.getString("designId")
    val isDebugMode = config.getBoolean("isDebugMode")

    if (id != null) {
      CmpConfig.id = id
    }

    CmpConfig.domain = domain
    CmpConfig.appName = appName
    CmpConfig.language = language
    CmpConfig.gaid = idfaOrGaid
    CmpConfig.timeout = timeout
    CmpConfig.jumpToSettingsPage = jumpToSettingsPage

    if (dialogBgColor != null) {
      CmpConfig.dialogBgColor = dialogBgColor
    }
    CmpConfig.designId = designId?.toInt()
    CmpConfig.isDebugMode = isDebugMode

    consentManager = CmpManager.createInstance(reactApplicationContext, CmpConfig)
    setCallbacks()
  }

  @ReactMethod
  fun setCallbacks() {
    consentManager?.setCallbacks(
      openListener = { emitEvent("onOpen", null) },
      closeListener = { emitEvent("onClose", null) },
      cmpNotOpenedCallback = { emitEvent("onNotOpened", null) },
      onErrorCallback = { type, message ->
        val map: WritableMap = Arguments.createMap()
        map.putString("type", type.toString())
        map.putString("message", message)
        emitEvent("onError", map) },
     { event ->
       val map: WritableMap = Arguments.createMap()
       map.putString("buttonType", event.toString())
       emitEvent("onButtonClicked", map) })
  }

  @ReactMethod
  fun importCmpString(cmpString: String, promise: Promise) {
    consentManager?.importCmpString(cmpString) { success, message ->
      // Prepare the payload
      val payload = Arguments.createMap().apply {
        putBoolean("success", success)
        putString("message", message)
      }

      // Resolve or reject the promise based on the success flag
      if (success) {
        promise.resolve(payload)
      } else {
        promise.reject(Throwable(message))
      }
    } ?: run {
      // Handle the case where consentManager is null
      promise.reject(Throwable("ConsentManager is not initialized"))
    }
  }


  @ReactMethod
  fun initializeCmp() {
    consentManager?.initialize(reactApplicationContext)
  }

 @ReactMethod
  fun openConsentLayerOnCheck() {
    consentManager?.checkAndOpenConsentLayer(reactApplicationContext)
  }

  @ReactMethod
  fun open() {
    consentManager?.openConsentLayer(reactApplicationContext)
  }

  @ReactMethod
  fun hasVendor(id: String, promise: Promise) {
    try {
      promise.resolve(consentManager?.hasVendorConsent(id)!!)
    } catch (e: Exception) {
      promise.reject(e)
    }
  }

  @ReactMethod
  fun hasPurpose(id: String, promise: Promise) {
    try {
      promise.resolve(consentManager?.hasPurposeConsent(id
      )!!)
    } catch (e: Exception) {
      promise.reject(e)
    }
  }

  @ReactMethod
  fun exportCmpString(promise: Promise) {
    try {
      val consent = consentManager?.exportCmpString()
      promise.resolve(consent)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error checking consent: ${e.message}")
    }
  }

  // Getter
  @ReactMethod
  fun reset() {
    CmpManager.reset(reactApplicationContext)
  }

  @ReactMethod
  fun getAllVendors(promise: Promise) {
    try {
      val jsonList = convertListToJson(consentManager?.getAllVendorsList()!!)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject(e)
    }
  }

  @ReactMethod
  fun getAllPurposes(promise: Promise) {
    try {
      val jsonList = convertListToJson(consentManager?.getAllPurposeList()!!)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject(e)
    }
  }

  @ReactMethod
  fun hasConsent(promise: Promise) {
    try {
      val consent = consentManager?.hasConsent()
      promise.resolve(consent)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error checking consent: ${e.message}")
    }
  }
  @ReactMethod
  fun getEnabledPurposes(promise: Promise) {
    try {
      val enabledPurposeList = consentManager?.getEnabledPurposeList()!!
      val jsonList = convertListToJson(enabledPurposeList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }

  @ReactMethod
  fun getEnabledVendors(promise: Promise) {
    try {
      val enabledVendorList = consentManager?.getEnabledVendorList()!!
      val jsonList = convertListToJson(enabledVendorList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }

  @ReactMethod
  fun getDisabledPurposes(promise: Promise) {
    try {
      val disabledPurposeList = consentManager?.getDisabledPurposes()!!
      val jsonList = convertListToJson(disabledPurposeList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }
  @ReactMethod
  fun getDisabledVendors(promise: Promise) {
    try {
      val disabledVendorList = consentManager?.getDisabledVendors()!!
      val jsonList = convertListToJson(disabledVendorList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }

  @ReactMethod
  fun getUSPrivacyString(promise: Promise) {
    try {
      val usPrivacyString = consentManager?.getUSPrivacyString() ?: ""
      promise.resolve(usPrivacyString)
    } catch (e: Exception) {
      promise.reject("ERROR", "Failed to get US privacy string: ${e.localizedMessage}")
    }
  }

  @ReactMethod
  fun getGoogleACString(promise: Promise) {
    try {
      val googleACString = consentManager?.getGoogleACString() ?: ""
      promise.resolve(googleACString)
    } catch (e: Exception) {
      promise.reject("ERROR", "Failed to get US privacy string: ${e.localizedMessage}")
    }
  }
  private fun emitEvent(eventName: String, params: WritableMap?) {
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, params)
  }
  @ReactMethod
  fun addListener(eventName: String) {
    if (listenerCount == 0) {
      // Set up any upstream listeners or background tasks as necessary
    }

    listenerCount += 1
  }

  @ReactMethod
  fun removeListeners(count: Int) {
    listenerCount -= count
    if (listenerCount == 0) {
      // Remove upstream listeners, stop unnecessary background tasks
    }
  }
  private fun convertListToJson(list: List<String>): String {
    return JSONArray(list).toString()
  }

  companion object {
    const val NAME = "Consentmanager"

  }
}
