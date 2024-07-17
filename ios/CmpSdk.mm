// ConsentManager.m

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
@interface RCT_EXTERN_MODULE (Consentmanager, RCTEventEmitter)

RCT_EXTERN_METHOD(createInstance:(NSString *)id domain:(NSString *)domain appName:(NSString *)appName language:(NSString *)language)
RCT_EXTERN_METHOD(createInstanceByConfig:(NSDictionary *)config)
RCT_EXTERN_METHOD(open)
RCT_EXTERN_METHOD(addEventListeners)
RCT_EXTERN_METHOD(initializeCmp)
RCT_EXTERN_METHOD(getLastATTRequestDate:(RCTPromiseResolveBlock)resolve
                                    rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(requestATTPermission)
RCT_EXTERN_METHOD(openConsentLayerOnCheck)
RCT_EXTERN_METHOD(importCmpString:(NSString *)cmpString resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(hasVendor:(NSString *)id defaultReturn:(BOOL)defaultReturn resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(hasPurpose:(NSString *)id defaultReturn:(BOOL)defaultReturn resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(reset)
RCT_EXTERN_METHOD(exportCmpString:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(hasConsent:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getAllVendors:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getAllPurposes:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getEnabledVendors:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getEnabledPurposes:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getDisabledVendors:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getDisabledPurposes:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getUSPrivacyString:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getGoogleACString:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(configureConsentLayer:(NSString *)screenConfig)
RCT_EXTERN_METHOD(configurePresentationStyle:(NSString *)style resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(supportedEvents)
@end
