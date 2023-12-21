package com.cmpsdk

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule

import net.consentmanager.sdk.CMPConsentTool
import net.consentmanager.sdk.common.CmpError
import net.consentmanager.sdk.common.callbacks.OnCMPNotOpenedCallback
import net.consentmanager.sdk.common.callbacks.OnCloseCallback
import net.consentmanager.sdk.common.callbacks.OnCmpButtonClickedCallback
import net.consentmanager.sdk.common.callbacks.OnCmpLayerOpenCallback
import net.consentmanager.sdk.common.callbacks.OnErrorCallback
import net.consentmanager.sdk.common.callbacks.OnOpenCallback
import net.consentmanager.sdk.consentlayer.model.CMPConfig
import net.consentmanager.sdk.consentlayer.model.valueObjects.CmpButtonEvent
import org.json.JSONArray
import java.lang.Exception

class CmpSdkModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private var consentManager : CMPConsentTool? = null
  private var listenerCount = 0
  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun createInstance(id: String, domain: String, appName : String, language: String) {
    CMPConfig.id = id
    CMPConfig.domain = domain
    CMPConfig.appName = appName
    CMPConfig.language = language
    CMPConfig.timeout = 5000
    consentManager = CMPConsentTool.createInstance(reactApplicationContext, CMPConfig)
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
      CMPConfig.id = id
    }

    CMPConfig.domain = domain
    CMPConfig.appName = appName
    CMPConfig.language = language
    CMPConfig.gaid = idfaOrGaid
    CMPConfig.timeout = timeout
    CMPConfig.jumpToSettingsPage = jumpToSettingsPage

    if (dialogBgColor != null) {
      CMPConfig.dialogBgColor = dialogBgColor
    }
    CMPConfig.designId = designId?.toInt()
    CMPConfig.isDebugMode = isDebugMode

    consentManager = CMPConsentTool.createInstance(reactApplicationContext, CMPConfig)
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
  fun initialize() {
    consentManager?.initialize(reactApplicationContext)
  }

  @ReactMethod
  fun open() {
    consentManager?.openCmpConsentToolView(reactApplicationContext)
  }

  @ReactMethod
  fun hasVendor(id: String, promise: Promise) {
    try {
      promise.resolve(consentManager?.hasVendorConsent(reactApplicationContext, id, false)!!)
    } catch (e: Exception) {
      promise.reject(e)
    }
  }

  @ReactMethod
  fun hasPurpose(id: String, promise: Promise) {
    try {
      promise.resolve(consentManager?.hasPurposeConsent(reactApplicationContext, id,
        isIABPurpose = false,
        checkConsent = false
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
    CMPConsentTool.reset(reactApplicationContext)
  }

  @ReactMethod
  fun getAllVendors(promise: Promise) {
    try {
      val jsonList = convertListToJson(consentManager?.getAllVendorsList(reactApplicationContext)!!)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject(e)
    }
  }

  @ReactMethod
  fun getAllPurposes(promise: Promise) {
    try {
      val jsonList = convertListToJson(consentManager?.getAllPurposeList(reactApplicationContext)!!)
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
      val enabledPurposeList = consentManager?.getEnabledPurposeList(reactApplicationContext)!!
      val jsonList = convertListToJson(enabledPurposeList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }

  @ReactMethod
  fun getEnabledVendors(promise: Promise) {
    try {
      val enabledVendorList = consentManager?.getEnabledVendorList(reactApplicationContext)!!
      val jsonList = convertListToJson(enabledVendorList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }

  @ReactMethod
  fun getDisabledPurposes(promise: Promise) {
    try {
      val disabledPurposeList = consentManager?.getDisabledPurposes(reactApplicationContext)!!
      val jsonList = convertListToJson(disabledPurposeList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }
  @ReactMethod
  fun getDisabledVendors(promise: Promise) {
    try {
      val disabledVendorList = consentManager?.getDisabledVendors(reactApplicationContext)!!
      val jsonList = convertListToJson(disabledVendorList)
      promise.resolve(jsonList)
    } catch (e: Exception) {
      promise.reject("ERROR", "Error getting enabled purpose list: ${e.message}")
    }
  }

  @ReactMethod
  fun getUSPrivacyString(promise: Promise) {
    try {
      val usPrivacyString = consentManager?.getUSPrivacyString(reactApplicationContext) ?: ""
      promise.resolve(usPrivacyString)
    } catch (e: Exception) {
      promise.reject("ERROR", "Failed to get US privacy string: ${e.localizedMessage}")
    }
  }

  @ReactMethod
  fun getGoogleACString(promise: Promise) {
    try {
      val googleACString = consentManager?.getGoogleACString(reactApplicationContext) ?: ""
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
