export interface CmpEventCallbacks {
  onOpen?: () => void;
  onClose?: () => void;
  onNotOpened?: () => void;
  onError?: (errorType: string, error: string) => void;
  onButtonClicked?: (buttonType: string) => void;
}

export interface CmpImportResult {
  success: boolean;
  message: string;
}

export class CmpConfig {
  id: string;
  domain: string;
  appName: string;
  language: string;
  idfaOrGaid?: string;
  timeout: number;
  jumpToSettingsPage: boolean;
  dialogBgColor?: string;
  designId?: string;
  isDebugMode: boolean;
  isAutomaticATTrackingRequest: boolean;

  constructor(config: Partial<CmpConfig>) {
    this.id = config.id!;
    this.domain = config.domain!;
    this.appName = config.appName!;
    this.language = config.language!;
    this.idfaOrGaid = config.idfaOrGaid;
    this.timeout = config.timeout || 5000;
    this.jumpToSettingsPage = config.jumpToSettingsPage || false;
    this.dialogBgColor = config.dialogBgColor;
    this.designId = config.designId;
    this.isDebugMode = config.isDebugMode || false;
    this.isAutomaticATTrackingRequest =
      config.isAutomaticATTrackingRequest || false;
  }
}
