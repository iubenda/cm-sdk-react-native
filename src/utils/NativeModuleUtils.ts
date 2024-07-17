import { NativeModules, NativeEventEmitter, Platform } from 'react-native';

export const LINKING_ERROR =
  `The package 'cmp-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

export const RNConsentmanager = NativeModules.Consentmanager
  ? NativeModules.Consentmanager
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export const eventEmitter = new NativeEventEmitter(RNConsentmanager);
