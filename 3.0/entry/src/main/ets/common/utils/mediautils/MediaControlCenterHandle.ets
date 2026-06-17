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

import { resourceManager } from '@kit.LocalizationKit';
import { DEFAULT_VOLUME, SILENT_ID, VOLUME_ID } from '../../constants/PlayerConstants';
import { PreferencesUtil } from '../PreferencesUtil';
import Logger from '../Logger';
import { AVPlayerController } from './AVPlayerController';
import { audio } from '@kit.AudioKit';

const TAG = 'MediaControlCenterHandle';

export class MediaControlCenterHandle {
  private static mediaControlCenterHandle: MediaControlCenterHandle;

  public static getInstance(): MediaControlCenterHandle {
    if (!MediaControlCenterHandle.mediaControlCenterHandle) {
      Logger.info(TAG, 'no mediaControlCenterHandle')
      MediaControlCenterHandle.mediaControlCenterHandle = new MediaControlCenterHandle();
    }
    return MediaControlCenterHandle.mediaControlCenterHandle;
  }

  async init() {
    // Initialize the playback instance class and place it in this method.
    await AVPlayerController.getInstance().initAVPlayer();
  }

  async loadSongAssent(songRawFileDescriptor: resourceManager.RawFileDescriptor) {
    // Load the current song information. The song information can be obtained from this interface, including fd length offset.
    await AVPlayerController.getInstance().loadSongAssent(songRawFileDescriptor);
  }

  // Execute play
  play() {
    try {
      AVPlayerController.getInstance().play();
    } catch (err) {
      Logger.error(TAG, `play failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
  }

  // Set speed
  setSpeed(speed: number) {
    try {
      AVPlayerController.getInstance().setSpeed(speed);
    } catch (err) {
      Logger.error(TAG,
        `set speed failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
  }

  // Get Volume
  getVolume() {
    let volume: number | undefined;
    volume = PreferencesUtil.getInstance().getValue(VOLUME_ID) as number;
    if (volume === undefined) {
      return DEFAULT_VOLUME;
    } else {
      return volume
    }
  }

  // Set Volume
  async setVolume(volume: number) {
    try {
      AVPlayerController.getInstance().setVolume(volume);
      if (!AppStorage.get('isSilentMode') || volume !== 0) {
        PreferencesUtil.getInstance().preferencesPut(VOLUME_ID, volume);
      }
    } catch (err) {
      Logger.error(TAG,
        `set volume failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
    Logger.info(TAG, `setVolume is ${volume}`)
  }

  // Set whether to mute
  setSilentMode(isSilentMode: boolean) {
    try {
      AVPlayerController.getInstance().setSilentMode(isSilentMode);
      PreferencesUtil.getInstance().preferencesPut(SILENT_ID, isSilentMode);
    } catch (err) {
      Logger.error(TAG,
        `set silentMode failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
  }

  // Execute pause
  pause() {
    try {
      AVPlayerController.getInstance().pause();
    } catch (err) {
      Logger.error(TAG, `pause failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
  }

  // Execute seek
  seek(ms: number) {
    try {
      AVPlayerController.getInstance().seek(ms);
    } catch (err) {
      Logger.error(TAG, `seek failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
  }

  // Execute stop
  async stop() {
    try {
      await AVPlayerController.getInstance().stop();
    } catch (err) {
      Logger.error(TAG, `stop failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
  }

  // Execute release
  release() {
    try {
      AVPlayerController.getInstance().release();
    } catch (err) {
      Logger.error(TAG, `release failed: code is ${JSON.stringify(err.code)},message is ${JSON.stringify(err.message)}`)
    }
  }
}