/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';

const DOMAIN = 0x0000;

/**
 * 自由流转数据键常量
 * 用于在迁移时保存和恢复播放状态
 */
const CONTINUATION_KEY_SELECT_INDEX = 'selectIndex';
const CONTINUATION_KEY_PROGRESS = 'progress';
const CONTINUATION_KEY_PLAY_MODE = 'playMode';

export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      AppStorage.setOrCreate('context', this.context)
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // ===== 自由流转：恢复迁移数据 =====
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN, 'testTag', 'Launched by continuation, restoring state...');
      this.restoreContinuationState(want);
    }
  }

  /**
   * 自由流转：当本设备作为源端，系统调用此方法收集迁移数据
   * 返回 AGREE 表示同意迁移，同时把当前播放状态写入 wantParam
   */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, 'testTag', 'onContinue called, saving playback state...');
    try {
      // 读取当前播放状态（AppStorage 中的值）
      const selectIndex: number = AppStorage.get<number>('selectIndex') ?? 0;
      const progress: number = AppStorage.get<number>('progress') ?? 0;
      const playMode: number = AppStorage.get<number>('playMode') ?? 0;
      const playModeStr: string = JSON.stringify(playMode);

      wantParam[CONTINUATION_KEY_SELECT_INDEX] = selectIndex;
      wantParam[CONTINUATION_KEY_PROGRESS] = progress;
      wantParam[CONTINUATION_KEY_PLAY_MODE] = playModeStr;

      hilog.info(DOMAIN, 'testTag',
        `Continuation data saved: selectIndex=${selectIndex}, progress=${progress}`);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to save continuation state: %{public}s', JSON.stringify(err));
    }
    return AbilityConstant.OnContinueResult.AGREE;
  }

  /**
   * 自由流转：当本设备作为目标端，应用重新启动并恢复状态
   * 系统会再次调用 onCreate 并传入 CONTINUATION 类型的 launchParam
   * 同时也可能调用 onNewWant（如应用已在运行）
   */
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', 'onNewWant called, launchReason: %{public}d', launchParam.launchReason);
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      this.restoreContinuationState(want);
    }
  }

  /**
   * 从 Want 的参数中恢复播放状态到 AppStorage
   */
  private restoreContinuationState(want: Want): void {
    try {
      const params = want.parameters;
      if (!params) {
        return;
      }
      if (params[CONTINUATION_KEY_SELECT_INDEX] !== undefined) {
        const idx = params[CONTINUATION_KEY_SELECT_INDEX] as number;
        AppStorage.setOrCreate<number>('selectIndex', idx);
        hilog.info(DOMAIN, 'testTag', `Restored selectIndex: ${idx}`);
      }
      if (params[CONTINUATION_KEY_PROGRESS] !== undefined) {
        const prog = params[CONTINUATION_KEY_PROGRESS] as number;
        AppStorage.setOrCreate<number>('progress', prog);
        hilog.info(DOMAIN, 'testTag', `Restored progress: ${prog}`);
      }
      if (params[CONTINUATION_KEY_PLAY_MODE] !== undefined) {
        try {
          const playModeStr = params[CONTINUATION_KEY_PLAY_MODE] as string;
          const playMode: number = JSON.parse(playModeStr) as number;
          AppStorage.setOrCreate<number>('playMode', playMode);
        } catch (e) {
          hilog.warn(DOMAIN, 'testTag', 'Failed to parse playMode, using default');
        }
      }
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to restore continuation state: %{public}s', JSON.stringify(err));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  private updateBreakpoint(windowWidth: number): void {
    let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
    let curBp: string = '';
    if (windowWidthVp < BreakpointConstants.BREAKPOINT_VALUE_NUMBER[1]) {
      curBp = BreakpointConstants.BREAKPOINT_SM;
    } else if (windowWidthVp < BreakpointConstants.BREAKPOINT_VALUE_NUMBER[2]) {
      curBp = BreakpointConstants.BREAKPOINT_MD;
    } else {
      curBp = BreakpointConstants.BREAKPOINT_LG;
    }
    AppStorage.setOrCreate('currentBreakpoint', curBp);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      AppStorage.setOrCreate('windowStage', windowStage)
      windowStage.getMainWindow().then((data: window.Window) => {
        this.windowObj = data;
        AppStorage.setOrCreate<window.Window>('window', data);
        data.setWindowLayoutFullScreen(true);
        const uiContext = data.getUIContext();
        AppStorage.setOrCreate("uiContext", uiContext);
        let topArea = this.windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        let bottomArea = this.windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        let topHeight: number;
        let bottomHeight: number;
        if (!topArea) {
          topHeight = 0;
        } else {
          topHeight = uiContext.px2vp(topArea.topRect.height)
        }
        if (!bottomArea) {
          bottomHeight = 0;
        } else {
          bottomHeight = uiContext.px2vp(bottomArea.bottomRect.height)
        }
        AppStorage.setOrCreate('topHeight', topHeight)
        AppStorage.setOrCreate('bottomHeight', bottomHeight)
        this.updateBreakpoint(this.windowObj.getWindowProperties().windowRect.width);
        this.windowObj.on('windowSizeChange', (windowSize: window.Size) => {
          this.updateBreakpoint(windowSize.width);
        })
      })
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
