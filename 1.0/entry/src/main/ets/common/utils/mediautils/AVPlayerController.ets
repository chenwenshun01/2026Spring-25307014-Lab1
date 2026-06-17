import Logger from '../Logger';
import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';
import { MediaTools } from './MediaTools';
import { resourceManager } from '@kit.LocalizationKit';
import { AVSessionController } from './AVSessionController';
import { MediaControlCenterCallbackAction } from './MediaControlCenterCallbackAction';

const TAG = 'AVPlayerController'

export class AVPlayerController {
  public avPlayer?: media.AVPlayer;
  private avSessionController: AVSessionController | undefined = undefined;
  private currentState: media.AVPlayerState = 'idle';
  private waitPlay: boolean = false;
  static avPlayerController: AVPlayerController | undefined;
  private speedMap: Map<number, media.PlaybackSpeed> = new Map();

  // [Start loadSongAssent]
  async loadSongAssent(songRawFileDescriptor: resourceManager.RawFileDescriptor) {
    if (!songRawFileDescriptor) {
      Logger.error(TAG, `loadSongAssent faile : songRawFileDescriptor get failed`);
      return;
    }
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.fdSrc = songRawFileDescriptor;
    Logger.info(TAG, `set avPlayer url is ${this.avPlayer.fdSrc}, curState is ${this.avPlayer?.state}`);
  }
  // [End loadSongAssent]

  public static getInstance(): AVPlayerController {
    if (!AVPlayerController.avPlayerController) {
      Logger.info(TAG, 'no AVPlayerController')
      AVPlayerController.avPlayerController = new AVPlayerController();
    }
    return AVPlayerController.avPlayerController;
  }

  private genSpeedMap() {
    const SPEED_ARR = [
      [0.25, media.PlaybackSpeed.SPEED_FORWARD_0_25_X],
      [0.5, media.PlaybackSpeed.SPEED_FORWARD_0_50_X],
      [0.75, media.PlaybackSpeed.SPEED_FORWARD_0_75_X],
      [1, media.PlaybackSpeed.SPEED_FORWARD_1_00_X],
      [1.25, media.PlaybackSpeed.SPEED_FORWARD_1_25_X],
      [1.5, media.PlaybackSpeed.SPEED_FORWARD_1_50_X],
      [1.75, media.PlaybackSpeed.SPEED_FORWARD_1_75_X],
      [2, media.PlaybackSpeed.SPEED_FORWARD_2_00_X],
    ]
    SPEED_ARR.forEach((item, index) => {
      this.speedMap.set(item[0], item[1]);
    })
  }

  // [Start initAVPlayer]
  // Initialize the player
  public async initAVPlayer() {
    if (this.avPlayer) {
      Logger.info(TAG, 'avPlayer already created');
      return;
    }
    this.avPlayer = await media.createAVPlayer();
    this.genSpeedMap();
    Logger.info(TAG, `createAVPlayer success, curState is ${this.avPlayer?.state}`);
    this.setAVPlayerCallbacks();
    Logger.info(TAG, `setAVPlayerCallbacks success, curState is ${this.avPlayer?.state}`);
  }
  // [End initAVPlayer]

  // [Start prepare]
  // Prepare the player
  public async prepare() {
    if (!this.avPlayer) {
      Logger.info(TAG, 'avPlayer is undefined')
      return;
    }
    await this.avPlayer.prepare().then(() => {
      Logger.info(TAG, `prepare success , curState is ${this.avPlayer?.state}`);
      AppStorage.setOrCreate('totalTime', MediaTools.msToCountdownTime(this.avPlayer?.duration!));
      AppStorage.setOrCreate('totalMsTime', this.avPlayer?.duration!);
      AppStorage.setOrCreate('progressMax', this.avPlayer?.duration!);
    });
  }
  // [End prepare]

  private switchSpeed(speed: number): media.PlaybackSpeed {
    let avPlayerSpeed: media.PlaybackSpeed | undefined;
    avPlayerSpeed = this.speedMap.get(speed);
    if (!avPlayerSpeed) {
      avPlayerSpeed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X;
    }
    Logger.info(TAG, `avPlayerSpeed is ${avPlayerSpeed}`)
    return avPlayerSpeed
  }

  // [Start setSpeed]
  // Set Speed
  public setSpeed(speed: number) {
    if (!this.avPlayer) {
      Logger.info(TAG, 'avPlayer is undefined')
      return;
    }
    Logger.info(TAG, `set speed is ${speed}`)
    this.avPlayer.setSpeed(this.switchSpeed(speed));
  }

  // [End setSpeed]

  // [Start setVolume]
  // Set Volume
  public setVolume(volume: number) {
    if (!this.avPlayer) {
      Logger.info(TAG, 'avPlayer is undefined')
      return;
    }
    Logger.info(TAG, `set volume is ${volume}`)
    this.avPlayer.setVolume(volume / 100);
  }

  // [End setVolume]

  // [Start play]
  public async play() {
    if (!this.avPlayer) {
      Logger.info(TAG, 'avPlayer is undefined')
      return;
    }
    if (this.currentState !== 'prepared' && this.currentState !== 'paused' && this.currentState !== 'stopped' &&
      this.currentState !== 'completed') {
      this.waitPlay = true;
      Logger.info(TAG, 'avPlayer current playState is not prepared')
      return;
    }
    await this.avPlayer.play();
    this.waitPlay = false;
    Logger.info(TAG, 'play success');
    this.updateIsPlay(true);
    Logger.info(TAG, `curState is ${this.avPlayer?.state}`);
  }

  // [End play]

  // [Start pause]
  public pause() {
    if (!this.avPlayer) {
      Logger.info(TAG, 'avPlayer is undefined')
      return;
    }
    this.avPlayer.pause();
    this.updateIsPlay(false);
  }
  // [End pause]

  // [Start seek]
  public seek(ms: number) {
    if (!this.avPlayer) {
      Logger.info(TAG, 'avPlayer is undefined')
      return;
    }
    this.avPlayer.seek(ms);
  }
  // [End seek]

  // [Start stop]
  public async stop() {
    if (!this.avPlayer) {
      Logger.error(TAG, 'avPlayer is undefined')
      return;
    }
    await this.avPlayer.stop();
    await this.avPlayer.reset();
    Logger.info(TAG, 'avPlayer stop success')
  }
  // [End stop]

  // [Start setSilentMode]
  public setSilentMode(isSilentMode: boolean) {
    if (!this.avPlayer) {
      Logger.error(TAG, 'avPlayer is undefined')
      return;
    }
    this.avPlayer.setMediaMuted(media.MediaType.MEDIA_TYPE_AUD, isSilentMode);
    Logger.info(TAG, `avPlayer setMediaMuted is ${isSilentMode} success`)
  }
  // [End setSilentMode]

  // [Start release]
  public release() {
    if (!this.avPlayer) {
      Logger.error(TAG, 'avPlayer is undefined')
      return;
    }
    this.avPlayer.release();
    Logger.error(TAG, 'avPlayer release success');
  }
  // [End release]

  // [Start setAVPlayerCallbacks]
  // Set callbacks
  private setAVPlayerCallbacks() {
    this.setAvSessionCallback();
    this.errorCallback();
    this.stateChangeCallback();
    this.audioInterruptCallback();
    this.durationUpdateCallback();
    this.timeUpdateCallback();
    this.outputDeviceChange();
    this.volumeChangeCallback();
  }
  // [End setAVPlayerCallbacks]

  // Update duration
  private durationUpdateCallback() {
    if (!this.avPlayer) {
      Logger.info(TAG, 'avPlayer already created')
      return;
    }
    this.avPlayer.on('durationUpdate', (duration: number) => {
      Logger.info(TAG, 'durationUpdate called,new duration is :' + duration);
    });
  }

  private timeUpdateCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('timeUpdate', (time: number) => {
      MediaControlCenterCallbackAction.getInstance().doUpdateProgressAction(time);
    });
  }

  private setAudioRendererInfo() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.audioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
      rendererFlags: 0,
      volumeMode: audio.AudioVolumeMode.SYSTEM_GLOBAL
    }
  }

  private setAvSessionCallback() {
    this.avSessionController = AVSessionController.getInstance();
  }

  // [Start errorCallback]
  private errorCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('error', (error: BusinessError) => {
      Logger.error(TAG, `errorCallback , code is ${error.code} message is ${error.message}`);
    });
  }
  // [End errorCallback]

  // [Start stateChangeCallback]
  // Watch state
  private stateChangeCallback() {
    if (!this.avPlayer) {
      Logger.error(TAG, `stateChangeCallback , avPlayer is undefined`);
      return;
    }
    this.avPlayer.on('stateChange', async (state: media.AVPlayerState, reason: media.StateChangeReason) => {
      this.currentState = state;
      switch (state) {
        case 'idle':
          Logger.info(TAG, `state idle called , resson is ${reason}`);
          break;
        case 'initialized':
          Logger.info(TAG, `state initialized called , resson is ${reason}`);
          this.setAudioRendererInfo();
          this.prepare();
          break;
        case 'prepared':
          Logger.info(TAG, `state prepared called , resson is ${reason}`);
          if (this.waitPlay) {
            this.play();
          }
          break;
        // [StartExclude stateChangeCallback]
        case 'playing':
          Logger.info(TAG, `state playing called , resson is ${reason}`);
          break;
        case 'paused':
          Logger.info(TAG, `state paused called , resson is ${reason}`);
          break;
        case 'completed':
          MediaControlCenterCallbackAction.getInstance().doPlayNextAction();
          break;
        case 'stopped':
          Logger.info(TAG, `state stopped called , resson is ${reason}`);
          break;
        case 'released':
          Logger.info(TAG, `state released called , resson is ${reason}`);
          break;
        case 'error':
          Logger.info(TAG, `state error called , resson is ${reason}`);
          break;
        default:
          Logger.info(TAG, `state unknown called , resson is ${reason}`);
          break;
        // [EndExclude stateChangeCallback]
      }
    });
    Logger.info(TAG, `set stateChangeCallback success`);
  }
  // [End stateChangeCallback]

  private audioInterruptCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioInterrupt', (interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            MediaControlCenterCallbackAction.getInstance().doPauseAction();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            MediaControlCenterCallbackAction.getInstance().doPauseAction();
            break;
          case audio.InterruptHint.INTERRUPT_HINT_DUCK:
            break;
          case audio.InterruptHint.INTERRUPT_HINT_UNDUCK:
            break;
          default:
            break;
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            MediaControlCenterCallbackAction.getInstance().doPlayAction();
            break;
          default:
            break;
        }
      }
    });
  }

  private volumeChangeCallback() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('volumeChange',  (volume) => {
    })
  }

  private outputDeviceChange() {
    if (!this.avPlayer) {
      return;
    }
    this.avPlayer.on('audioOutputDeviceChangeWithInfo', (deviceChangeInfo: audio.AudioStreamDeviceChangeInfo) => {
      Logger.info(TAG, `DeviceInfo id: ${deviceChangeInfo.devices[0].id}`);
      Logger.info(TAG, `DeviceInfo name: ${deviceChangeInfo.devices[0].name}`);
      Logger.info(TAG, `DeviceInfo address: ${deviceChangeInfo.devices[0].address}`);
      Logger.info(TAG, `Device change reason: ${deviceChangeInfo.changeReason}`);
      if (deviceChangeInfo.changeReason === audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        Logger.info(TAG, `Device change reason: ${deviceChangeInfo.changeReason}`);
        MediaControlCenterCallbackAction.getInstance().doPauseAction();
      }
    })
  }

  // Update play state
  private updateIsPlay(isPlay: boolean) {
    AppStorage.setOrCreate<boolean>('isPlay', isPlay);
    if (!this.avSessionController) {
      return;
    }
    this.avSessionController.setPlayState(isPlay);
  }
}