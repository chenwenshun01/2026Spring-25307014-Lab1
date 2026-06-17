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

const TAG = 'ABLoopManager';

/**
 * A-B loop feature based on progress (ms).
 *
 * AppStorage keys:
 * - abA: number
 * - abB: number
 * - abEnabled: boolean
 */
export class ABLoopManager {
  private static instance: ABLoopManager;
  private aMs: number = -1;
  private bMs: number = -1;
  private enabled: boolean = false;

  public static getInstance(): ABLoopManager {
    if (!ABLoopManager.instance) {
      ABLoopManager.instance = new ABLoopManager();
    }
    return ABLoopManager.instance;
  }

  public setA(ms: number): void {
    this.aMs = ms;
    AppStorage.setOrCreate('abA', this.aMs);
    Logger.info(TAG, `Set A: ${ms}`);
    this.ensureValid();
  }

  public setB(ms: number): void {
    this.bMs = ms;
    AppStorage.setOrCreate('abB', this.bMs);
    Logger.info(TAG, `Set B: ${ms}`);
    this.ensureValid();
  }

  public setEnabled(enabled: boolean): void {
    this.enabled = enabled;
    AppStorage.setOrCreate('abEnabled', this.enabled);
    Logger.info(TAG, `AB enabled: ${enabled}`);
    this.ensureValid();
  }

  public reset(): void {
    this.aMs = -1;
    this.bMs = -1;
    this.enabled = false;
    AppStorage.setOrCreate('abA', this.aMs);
    AppStorage.setOrCreate('abB', this.bMs);
    AppStorage.setOrCreate('abEnabled', this.enabled);
  }

  public isReady(): boolean {
    return this.enabled && this.aMs >= 0 && this.bMs > this.aMs;
  }

  private ensureValid(): void {
    if (this.aMs >= 0 && this.bMs >= 0 && this.bMs <= this.aMs) {
      // if invalid range, disable.
      this.enabled = false;
      AppStorage.setOrCreate('abEnabled', false);
    }
  }

  /**
   * Called by timeUpdate callback.
   */
  public onProgress(timeMs: number): void {
    if (!this.isReady()) {
      return;
    }
    if (timeMs >= this.bMs) {
      Logger.info(TAG, `AB loop hit B (${this.bMs}), seek to A (${this.aMs})`);
      MediaControlCenter.getInstance().seek(this.aMs);
    }
  }
}
