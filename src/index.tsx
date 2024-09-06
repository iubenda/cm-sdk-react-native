import type {
  CmpEventCallbacks,
  CmpImportResult,
  GoogleConsentStatus,
  GoogleConsentType,
} from './types/CmpTypes';
import type { CmpConfig } from './CmpConfig';
import { RNConsentmanager, eventEmitter } from './utils/NativeModuleUtils';
import { Platform } from 'react-native';
import type { CmpScreenConfig } from './types/CmpScreenConfig';
import type { CmpIosPresentationStyle } from './types/CmpIosPresentationStyle';

export const Consentmanager = {
  createInstance: (
    id: string,
    domain: string,
    appName: string,
    language: string
  ) => {
    RNConsentmanager.createInstance(id, domain, appName, language);
  },
  createInstanceByConfig: (config: CmpConfig) => {
    RNConsentmanager.createInstanceByConfig(config);
  },
  initialize: () => {
    RNConsentmanager.initializeCmp();
  },
  openConsentLayer: () => {
    RNConsentmanager.open();
  },
  openConsentLayerOnCheck: () => {
    RNConsentmanager.openConsentLayerOnCheck();
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
      onGoogleConsentUpdated = (
        consentMap: Record<GoogleConsentType, GoogleConsentStatus>
      ) => console.log(`Google consent updated: ${JSON.stringify(consentMap)}`),
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

    const onGoogleConsentUpdatedListener = eventEmitter.addListener(
      'onGoogleConsentUpdated',
      (event) => onGoogleConsentUpdated(event.consentMap)
    );
    return () => {
      onOpenListener.remove();
      onCloseListener.remove();
      onNotOpenListener.remove();
      onErrorListener.remove();
      onButtonClickedListener.remove();
      onGoogleConsentUpdatedListener.remove();
    };
  },
  getLastATTRequestDate: (): Promise<Date> => {
    return new Promise((resolve, reject) => {
      if (Platform.OS === 'ios') {
        RNConsentmanager.getLastATTRequestDate()
          .then((timestamp: number) => {
            const date = new Date(timestamp * 1000); // Convert to milliseconds
            resolve(date);
          })
          .catch((error: string) => reject(error));
      } else {
        console.warn('getLastATTRequestDate is not available on this platform');
        reject('Function not available on this platform');
      }
    });
  },

  requestATTPermission: () => {
    if (Platform.OS === 'ios') {
      RNConsentmanager.requestATTPermission();
    } else {
      console.warn('requestATTPermission is not available on this platform');
    }
  },
  importCmpString: (cmpString: string): Promise<CmpImportResult> => {
    return RNConsentmanager.importCmpString(cmpString);
  },
  hasVendor: (id: string, defaultReturn: boolean = true): Promise<boolean> => {
    return RNConsentmanager.hasVendor(id, defaultReturn);
  },
  hasPurpose: (id: string, defaultReturn: boolean = true): Promise<boolean> => {
    return RNConsentmanager.hasPurpose(id, defaultReturn);
  },
  reset: () => {
    RNConsentmanager.reset();
  },
  exportCmpString: (): Promise<string> => {
    return RNConsentmanager.exportCmpString();
  },
  // getter
  hasConsent: (): Promise<boolean> => {
    return RNConsentmanager.hasConsent();
  },
  getAllVendors: (): Promise<string[]> => {
    return RNConsentmanager.getAllVendors();
  },
  getAllPurposes: (): Promise<string[]> => {
    return RNConsentmanager.getAllPurposes();
  },
  getEnabledVendors: (): Promise<string[]> => {
    return RNConsentmanager.getEnabledVendors();
  },
  getEnabledPurposes: (): Promise<string[]> => {
    return RNConsentmanager.getEnabledPurposes();
  },
  getDisabledVendors: (): Promise<string[]> => {
    return RNConsentmanager.getDisabledVendors();
  },
  getDisabledPurposes: (): Promise<string[]> => {
    return RNConsentmanager.getDisabledPurposes();
  },
  getUSPrivacyString: (): Promise<string> => {
    return RNConsentmanager.getUSPrivacyString();
  },
  getGoogleACString: (): Promise<string> => {
    return RNConsentmanager.getGoogleACString();
  },
  configureConsentLayer: (screenConfig: CmpScreenConfig) => {
    RNConsentmanager.configureConsentLayer(screenConfig);
  },
  configurePresentationStyle: (
    style: CmpIosPresentationStyle
  ): Promise<void> => {
    if (Platform.OS !== 'ios') {
      return Promise.reject(
        new Error('configurePresentationStyle is only available on iOS')
      );
    }
    return RNConsentmanager.configurePresentationStyle(style);
  },
};

export { CmpConfig } from './CmpConfig';
export { CmpIosPresentationStyle } from './types/CmpIosPresentationStyle';
export { CmpAndroidPresentationStyle } from './types/CmpAndroidPresentationStyle';
export { CmpScreenConfig } from './types/CmpScreenConfig';
export * from './types/CmpTypes';
