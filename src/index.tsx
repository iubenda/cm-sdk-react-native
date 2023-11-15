import { NativeModules, NativeEventEmitter, Platform } from 'react-native';
import type { CmpConfig, CmpEventCallbacks } from './CmpTypes';

const LINKING_ERROR =
  `The package 'cmp-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const RNConsentmanager = NativeModules.Consentmanager
  ? NativeModules.Consentmanager
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );
const eventEmitter = new NativeEventEmitter(RNConsentmanager);
export const Consentmanager = {
  createInstance: (
    id: string,
    domain: String,
    appName: String,
    language: String
  ) => {
    RNConsentmanager.createInstance(id, domain, appName, language);
  },
  createInstanceByConfig: (config: CmpConfig) => {
    RNConsentmanager.createInstanceByConfig(config);
  },
  openConsentlayer: () => {
    RNConsentmanager.open();
  },
  addEventListeners: (customCallbacks: CmpEventCallbacks = {}) => {
    const {
      onOpen = () => console.log('Open event received'),
      onClose = () => console.log('Close event received'),
      onNotOpened = () => console.log('Not open event received'),
      onError = (type, message) =>
        console.log(`Error: ${type}, Message: ${message}`),
      onButtonClicked = (buttonType) =>
        console.log(`Button clicked: ${buttonType}`),
    }: CmpEventCallbacks = customCallbacks;

    const onOpenListener = eventEmitter.addListener('onOpen', onOpen);
    const onCloseListener = eventEmitter.addListener('onClose', onClose);
    const onNotOpenListener = eventEmitter.addListener(
      'onNotOpened',
      onNotOpened
    );
    const onErrorListener = eventEmitter.addListener('onError', (event) =>
      onError(event.type, event.error)
    );
    const onButtonClickedListener = eventEmitter.addListener(
      'onButtonClicked',
      (event) => onButtonClicked(event.buttonType)
    );
    return () => {
      onOpenListener.remove();
      onCloseListener.remove();
      onNotOpenListener.remove();
      onErrorListener.remove();
      onButtonClickedListener.remove();
    };
  },
  hasVendor: (id: String): Promise<Boolean> => {
    return RNConsentmanager.hasVendor(id);
  },
  hasPurpose: (id: String): Promise<Boolean> => {
    return RNConsentmanager.hasPurpose(id);
  },
  reset: () => {
    RNConsentmanager.reset();
  },
  exportCmpString: (): Promise<String> => {
    return RNConsentmanager.exportCmpString();
  },
  // getter
  hasConsent: (): Promise<Boolean> => {
    return RNConsentmanager.hasConsent();
  },
  getAllVendors: (): Promise<String[]> => {
    return RNConsentmanager.getAllVendors();
  },
  getAllPurposes: (): Promise<String[]> => {
    return RNConsentmanager.getAllPurposes();
  },
  getEnabledVendors: (): Promise<String[]> => {
    return RNConsentmanager.getEnabledVendors();
  },
  getEnabledPurposes: (): Promise<String[]> => {
    return RNConsentmanager.getEnabledPurposes();
  },
  getDisabledVendors: (): Promise<String[]> => {
    return RNConsentmanager.getDisabledVendors();
  },
  getDisabledPurposes: (): Promise<String[]> => {
    return RNConsentmanager.getDisabledPurposes();
  },
  getUSPrivacyString: (): Promise<String> => {
    return RNConsentmanager.getUSPrivacyString();
  },
  getGoogleACString: (): Promise<String> => {
    return RNConsentmanager.getGoogleACString();
  },
};
