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

import Logger from '../Logger';
import { MediaControlCenter } from './MediaControlCenter';

const TAG = 'SleepTimerManager';

/**
 * Sleep timer for auto-pausing playback after N minutes.
 *
 * AppStorage keys:
 * - sleepTimerRemainSec: number (remaining seconds)
 */
export class SleepTimerManager {
  private static instance: SleepTimerManager;

  private intervalId: number = -1;
  private remainSec: number = 0;

  public static getInstance(): SleepTimerManager {
    if (!SleepTimerManager.instance) {
      SleepTimerManager.instance = new SleepTimerManager();
    }
    return SleepTimerManager.instance;
  }

  /**
   * Set sleep timer.
   * @param minutes 0 means cancel.
   */
  public setTimer(minutes: number): void {
    if (!minutes || minutes <= 0) {
      this.cancel();
      return;
    }

    this.cancel();
    this.remainSec = Math.floor(minutes * 60);
    AppStorage.setOrCreate('sleepTimerRemainSec', this.remainSec);

    Logger.info(TAG, `Sleep timer set: ${minutes} min (${this.remainSec}s)`);

    this.intervalId = setInterval(() => {
      this.remainSec -= 1;
      if (this.remainSec < 0) {
        this.remainSec = 0;
      }
      AppStorage.setOrCreate('sleepTimerRemainSec', this.remainSec);

      if (this.remainSec === 0) {
        Logger.info(TAG, 'Sleep timer expired, pause playback');
        this.cancel(false);
        MediaControlCenter.getInstance().pause();
      }
    }, 1000);
  }

  /** Cancel sleep timer */
  public cancel(resetStorage: boolean = true): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId);
      this.intervalId = -1;
    }
    this.remainSec = 0;
    if (resetStorage) {
      AppStorage.setOrCreate('sleepTimerRemainSec', 0);
    }
  }

  public getRemainingSeconds(): number {
    return this.remainSec;
  }
}
