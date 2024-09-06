import { CmpAndroidPresentationStyle } from './types/CmpAndroidPresentationStyle';
import { CmpIosPresentationStyle } from './types/CmpIosPresentationStyle';
import { CmpScreenConfig } from './types/CmpScreenConfig';

export class CmpConfig {
  id: string;
  domain: string;
  appName: string;
  language: string;
  idfaOrGaid?: string;
  timeout: number;
  jumpToSettingsPage: boolean;
  isDebugMode: boolean;
  isAutomaticATTrackingRequest: boolean;
  screenConfig?: CmpScreenConfig;
  iosPresentationStyle?: CmpIosPresentationStyle;
  androidPresentationStyle?: CmpAndroidPresentationStyle;

  constructor(config: Partial<CmpConfig>) {
    this.id = config.id!;
    this.domain = config.domain!;
    this.appName = config.appName!;
    this.language = config.language!;
    this.idfaOrGaid = config.idfaOrGaid;
    this.timeout = config.timeout || 5000;
    this.jumpToSettingsPage = config.jumpToSettingsPage || false;
    this.isDebugMode = config.isDebugMode || false;
    this.isAutomaticATTrackingRequest =
      config.isAutomaticATTrackingRequest || false;
    this.screenConfig = config.screenConfig || CmpScreenConfig.FullScreen;
    this.iosPresentationStyle =
      config.iosPresentationStyle || CmpIosPresentationStyle.None;
    this.androidPresentationStyle =
      config.androidPresentationStyle ||
      CmpAndroidPresentationStyle.PopupWindow;
  }
}
