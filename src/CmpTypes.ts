export interface CmpConfig {
  id: string;
  domain: string;
  appName: string;
  language: string;
  idfaOrGaid: String;
  timeout: number;
  jumpToSettingsPage: boolean;
  dialogBgColor: string;
  designId: string;
  isDebugMode: boolean;
}

export interface CmpEventCallbacks {
  onOpen?: () => void;
  onClose?: () => void;
  onNotOpened?: () => void;
  onError?: (errorType: string, error: string) => void;
  onButtonClicked?: (buttonType: string) => void;
}
