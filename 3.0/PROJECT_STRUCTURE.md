# avplayer-play-formatted-audio-arkts 工程目录文档

> 基于 AVPlayer 播放格式化音频（ArkTS）。支持 MP3/WAV/FLAC 等；包含后台播放、播控中心交互、焦点打断策略、切换输出设备、倍速、音量、静音、收藏同步等。

- 工程路径：`C:\Users\wensh\Downloads\avplayer-play-formatted-audio-arkts-master\avplayer-play-formatted-audio-arkts-master`
- 运行环境要求（来自 README）：
  - DevEco Studio：**6.0.0 Release** 及以上
  - HarmonyOS SDK：**6.0.0 Release SDK** 及以上
  - 设备/模拟器：phone（直板机）
- 构建配置（build-profile.json5）：
  - `targetSdkVersion`: `6.0.0(20)`
  - `compatibleSdkVersion`: `6.0.0(20)`

---

## 1. 顶层结构（建议关注）

```
.
├─ AppScope/                 # 应用级配置与资源（跨 module）
├─ entry/                    # 主 HAP module（业务代码、页面、资源）
├─ hvigor/                   # Hvigor 构建工具配置
├─ oh_modules/               # ohpm 依赖缓存（安装依赖后生成/更新）
├─ screenshots/              # README 用到的效果图
├─ build-profile.json5       # 工程构建配置（target/compatible SDK 等）
├─ hvigorfile.ts             # 工程级构建脚本入口
├─ oh-package.json5          # 工程/包依赖声明
├─ oh-package-lock.json5     # 依赖锁定文件
├─ code-linter.json5         # 代码规范/静态检查配置
├─ local.properties          # 本机路径配置（通常是 SDK 路径等）
└─ README.md                 # 示例说明与功能介绍
```

> 说明：`.hvigor/`、`entry/build/` 等目录是构建/同步过程中生成的缓存与产物；用于排障时可看，但不建议写入业务说明。

---

## 2. AppScope（应用级）

```
AppScope/
├─ app.json5                 # 应用包信息（bundleName、version、label 等）
└─ resources/                # 应用级资源
   └─ base/
      ├─ element/string.json # 字符串资源
      └─ media/*             # 图标、背景等
```

- `AppScope/app.json5`
  - `bundleName`: `com.example.AVPlayerPlayFormattedAudioArkts`

---

## 3. entry Module（核心业务代码）

### 3.1 module 配置与权限

```
entry/
├─ src/main/module.json5     # module 配置（Ability、权限、后台模式等）
├─ build-profile.json5       # module 构建配置
├─ hvigorfile.ts             # module 构建脚本
├─ oh-package.json5          # module 级依赖
└─ src/main/ets/             # ArkTS 源码
```

`entry/src/main/module.json5` 关键点：
- `deviceTypes`: `phone`
- 权限：`ohos.permission.KEEP_BACKGROUND_RUNNING`（后台任务/后台播放相关）
- `EntryAbility`：配置了 `backgroundModes: ["audioPlayback"]`

### 3.2 ArkTS 源码目录（entry/src/main/ets）

```
entry/src/main/ets/
├─ entryability/
│  ├─ EntryAbility.ets                 # Ability 生命周期与入口
│  └─ InsightIntentExecutorImpl.ets    # 意图框架回调
├─ pages/
│  └─ Index.ets                        # 首页（UI 入口）
├─ view/                               # UI 视图组件
│  ├─ ControlAreaComponent.ets         # 控制区（播放/切歌/进度等）
│  ├─ LrcView.ets                      # 歌词显示
│  ├─ LyricsComponent.ets              # 歌词组件
│  ├─ MusicInfoComponent.ets           # 音乐信息
│  └─ PlayerInfoComponent.ets          # 播放信息/详情
├─ viewmodel/                          # 数据与业务状态（MVVM）
│  ├─ LrcEntry.ets
│  ├─ SongData.ets
│  ├─ SongDataSource.ets
│  └─ SongItemBuilder.ets
├─ model/
│  └─ SongListData.ets                 # 歌单数据
├─ component/
│  └─ CustomButton.ets                 # 公共按钮组件
└─ common/
   ├─ constants/                       # 常量定义
   │  ├─ BreakpointConstants.ets
   │  ├─ ContentConstants.ets
   │  ├─ LyricConst.ets
   │  ├─ PlayerConstants.ets
   │  └─ StyleConstants.ets
   └─ utils/                           # 工具类
      ├─ BackgroundUtil.ets
      ├─ BreakpointSystem.ets
      ├─ ColorConversion.ets
      ├─ Logger.ets
      ├─ LrcUtils.ets
      ├─ PreferencesUtil.ets
      ├─ ResourceConversion.ets
      └─ mediautils/                   # 媒体播放/播控中心封装（重点）
         ├─ AVPlayerController.ets                 # AVPlayer 播放控制封装
         ├─ AVSessionController.ets                # AVSession / 播控中心交互
         ├─ MediaControlCenter.ets                 # 媒体控制中心
         ├─ MediaControlCenterCallbackAction.ets   # 播控中心回调响应
         ├─ MediaControlCenterHandle.ets           # 播控中心句柄
         └─ MediaTools.ets                         # 媒体工具/通用能力
```

**建议阅读顺序（快速理解业务链路）：**
1. `pages/Index.ets`（UI 如何触发播放、切歌、进度、倍速、音量等）
2. `common/utils/mediautils/AVPlayerController.ets`（真正调用 AVPlayer 的地方）
3. `common/utils/mediautils/AVSessionController.ets` + `MediaControlCenter*.ets`（与系统播控中心、收藏同步等）
4. `viewmodel/SongDataSource.ets`（歌单与数据源）

### 3.3 entry 资源目录（entry/src/main/resources）

```
entry/src/main/resources/
├─ base/
│  ├─ element/               # 颜色/尺寸/字符串等
│  ├─ media/                 # UI 图标、背景等
│  └─ profile/               # 配置文件（页面路由、备份、意图等）
├─ dark/element/             # 深色模式资源
├─ en_US/element/            # 英文资源
├─ zh_CN/element/            # 中文资源
└─ rawfile/                  # 原始资源（音频、歌词等）——播放源来自这里
   ├─ boisterous.wav
   ├─ power.wav
   ├─ world.wav
   ├─ Delacey - Dream It Possible.flac
   └─ lrcfiles/
      └─ DreamItPossible.lrc
```

> README 提到：示例从 `rawfile` 获取音频文件，然后通过 `AVPlayerController` 进行播放。

---

## 4. 构建/产物/缓存目录（了解即可）

- `.hvigor/`：Hvigor 同步/构建缓存、日志与报告（如 `outputs/build-logs/build.log`）。
- `entry/build/`：编译中间产物、资源合并结果、打包输出等。
  - 例如：`entry/build/outputs/default/entry-default-unsigned.hap`
- `oh_modules/`：ohpm 依赖目录（包含 `@ohos/hypium` 等）。

---

## 5. screenshots（文档配图）

```
screenshots/device/
├─ index.png
├─ lyric.png
├─ songList.png
└─ speed.png
```

---

## 6. 快速定位“播放相关”的关键文件

- 播放器封装：`entry/src/main/ets/common/utils/mediautils/AVPlayerController.ets`
- 播控中心：
  - `entry/src/main/ets/common/utils/mediautils/AVSessionController.ets`
  - `entry/src/main/ets/common/utils/mediautils/MediaControlCenter*.ets`
- 播放界面入口：`entry/src/main/ets/pages/Index.ets`
- 播放资源：`entry/src/main/resources/rawfile/*`

---

（由娅娅根据你本地目录扫描生成）
