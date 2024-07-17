export interface CmpEventCallbacks {
  onOpen?: () => void;
  onClose?: () => void;
  onNotOpened?: () => void;
  onError?: (errorType: string, error: string) => void;
  onButtonClicked?: (buttonType: string) => void;
  onGoogleConsentUpdated?: (
    consentMap: Record<GoogleConsentType, GoogleConsentStatus>
  ) => void;
}

export interface CmpImportResult {
  success: boolean;
  message: string;
}

export enum GoogleConsentType {
  ANALYTICS_STORAGE = 'analytics_storage',
  AD_STORAGE = 'ad_storage',
  AD_USER_DATA = 'ad_user_data',
  AD_PERSONALIZATION = 'ad_personalization',
}

export enum GoogleConsentStatus {
  GRANTED = 'granted',
  DENIED = 'denied',
}
