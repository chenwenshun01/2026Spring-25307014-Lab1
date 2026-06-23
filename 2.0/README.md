# 基于 AVPlayer 播放格式化音频（ArkTS）

## 项目简介

本场景解决方案主要面向前台音频开发人员。指导开发者基于 AVPlayer 开发音频播放功能，AVPlayer 用于播放格式化音频（MP3、WAV、FLAC 等）。功能包括后台播放、和播控中心的交互、适配不同类型的焦点打断策略、切换输出设备、倍数播放、音量调节等基础音频常见功能。

## 2.0 版本新增功能

相比 1.0 版本，2.0 版本新增了以下三项增强功能：

### 1. 睡眠定时（Sleep Timer）

允许用户设置一个倒计时，在倒计时结束后自动暂停播放或关闭应用，适用于睡前听歌场景。

- 入口：播放界面中的睡眠定时入口（通常在设置或控制区菜单中）
- 支持：定时 15 分钟 / 30 分钟 / 45 分钟 / 60 分钟 / 自定义时长
- 实现：使用 ArkTS 定时器（`setTimeout` / `setInterval`）与后台任务机制，倒计时到达后调用 `AVPlayer` 暂停或停止

### 2. A-B 循环（A-B Loop）

用户可以标记歌曲中的 A 点和 B 点，播放器会在 A-B 区间内反复循环播放，适合用于音乐练习或片段复习。

- 入口：播放控制区 A-B 循环按钮
- 操作：
  - 第一次点击：设置 A 点（记录当前进度）
  - 第二次点击：设置 B 点（记录当前进度）并开启循环
  - 再次点击：取消循环，恢复正常播放
- 实现：通过监听 `AVPlayer` 播放进度事件，在进度达到 B 点时自动 seek 回 A 点

### 3. 主题切换（Theme Switch）

支持在浅色主题与深色主题之间切换，并持久化保存用户选择，提升夜间使用体验。

- 入口：播放界面或设置页中的主题切换按钮
- 支持：浅色模式 / 深色模式 / 跟随系统
- 实现：使用 `AppStorage` 或首选项（`Preferences`）保存主题状态，动态切换应用全局颜色配置

## 使用说明

1. 播放功能：运行工程，进入首页后，点击底部播放按钮，可播放音乐。
2. 切歌功能：播放按钮两侧有切歌按钮，点击切换上一首下一首。
3. 进度跳转功能：推动播放按钮上面的播放条，可以调整歌曲进度。
4. 循环模式：点击进度条上部，左侧第一个图标，可以切换不同播放模式，支持的模式有“顺序播放”、“单曲循环”、“随机播放”。
5. 歌单列表：点击进度条上部，左侧第二个图标，可以打开歌曲列表，点击歌曲名称，可以切换播放歌曲。
6. 静音播放：点击进度条上部，左侧第三个图标，可以打开静音播放功能。
7. 倍数设置：点击进度条上部，左侧第四个图标，可以调整歌曲播放速度。
8. 音量设置：点击进度条上部，左侧第五个图标，可以调整歌曲播放音量。
9. 收藏：点击页面“爱心”图标，将歌曲变成已收藏状态，可以同步至播控中心。
10. 睡眠定时：在设置或控制区菜单中打开，选择定时时间，倒计时结束后自动暂停播放。
11. A-B 循环：点击 A-B 循环按钮，依次设置 A 点和 B 点，播放器将在 A-B 区间重复播放。
12. 主题切换：点击主题切换按钮，在浅色/深色/跟随系统之间切换。

## 效果预览

| 主页面                                                | 歌词页                                                | 歌单列表                                                  | 倍数设置                                               |
|----------------------------------------------------|----------------------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| <img src="screenshots/device/index.png" width=320> | <img src="screenshots/device/lyric.png" width=320> | <img src="screenshots/device/songList.png" width=320> | <img src="screenshots/device/speed.png" width=320> |

## 工程目录

```
├──entry/src/main/ets/
│  ├──common
│  │  ├──constants                                        // 常量
│  │  │  ├──BreakpointConstants.ets                       // 断点常量
│  │  │  ├──ContentConstants.ets                          // 内容常量
│  │  │  ├──LyricConst.ets                                // 歌词常量
│  │  │  ├──PlayerConstants.ets                           // 播放常量
│  │  │  └──StyleConstants.ets                            // 顶部区域组件
│  │  └──utils                                            // 工具函数
│  │     ├──mediautils                                    // 媒体方法
│  │     │  ├──AVPlayerController.ets                     // AVPlayerController播放类
│  │     │  ├──AVSessionController.ets                    // 播控中心控制类
│  │     │  ├──MediaControlCenter.ets                     // 媒体控制中心类
│  │     │  ├──MediaControlCenterCallbackAction.ets       // 媒体控制中心回调函数响应类
│  │     │  ├──MediaControlCenterHandle.ets               // 媒体控制中心句柄类
│  │     │  └──MediaTools.ets                             // 媒体工具处理类
│  │     ├──BackgroundUtil                                // 后台任务类
│  │     ├──BreakpointSystem                              // 断点系统类
│  │     ├──ColorConversion                               // 颜色转换类
│  │     ├──Logger                                        // 日志类
│  │     ├──LrcUtils                                      // 歌词工具类
│  │     ├──PreferencesUtil                               // 首选项工具类
│  │     └──ResourceConversion.ets                        // 资源工具类
│  ├──components                                          // 组件
│  │  └──CustomButton.ets                                 // 公共按钮
│  ├──entryability
│  │  ├──EntryAbility.ets                                 // Ability的生命周期回调内容
│  │  └──InsightIntentExecutorImpl.ets                    // 意图框架回调内容
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets                           // EntryBackupAbility的生命周期回调内容
│  ├──model
│  │  └──SongListData.ets                                 // 歌单列表数据
│  ├──pages
│  │  └──Index.ets                                        // 首页
│  ├──view
│  │  ├──ControlAreaComponent.ets                         // 控制区域组件
│  │  ├──LrcView.ets                                      // 歌词显示组件
│  │  ├──LyricsComponent.ets                              // 歌词组件
│  │  ├──MusicInfoComponent.ets                           // 音乐详情组件
│  │  └──PlayerInfoComponent.ets                        // 播放详情组件
│  └──viewmodel
│     ├──LrcEntry.ets                                     // 歌词数据类型
│     ├──SongData.ets                                     // 歌曲基础数据类型
│     ├──SongDataSource.ets                               // 歌曲列表数据源
│     └──SongItemBuilder.ets                              // 歌曲列表数据构造
└──entry/src/main/resources                               // 应用静态资源目录
```

## 具体实现

1. 播放功能：本文使用 AVPlayer 接口实现音频播放功能。从 rawfile 目录下获取音频文件后，通过 AVPlayerController 接口实现播放功能。
2. 倍速、音量、静音模式功能调用的是 AVPlayer 自身的接口，详细接口使用可见具体代码。
3. 循环模式和收藏模式的状态切换，依赖本地数据和 AVSession 交互，达到应用内界面和播控中心状态的同步。
4. 睡眠定时：通过定时任务与 AVPlayer 暂停接口组合，倒计时结束后自动停止播放。
5. A-B 循环：通过监听播放进度事件，在达到 B 点时自动回退到 A 点，实现区间循环。
6. 主题切换：通过 Preferences 或 AppStorage 持久化主题配置，动态切换 UI 颜色资源。

## 相关权限

1. 后台任务权限：`ohos.permission.KEEP_BACKGROUND_RUNNING`。

## 依赖

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：直板机。
2. HarmonyOS 系统：HarmonyOS 6.0.0 Release Release 及以上。
3. DevEco Studio 版本：DevEco Studio 6.0.0 Release 及以上。
4. HarmonyOS SDK 版本：HarmonyOS 6.0.0 Release SDK 及以上。

> 1.0 版本工程结构文档见仓库根目录下 `1.0/PROJECT_STRUCTURE.md`。
