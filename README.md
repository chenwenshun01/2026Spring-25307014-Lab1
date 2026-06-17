# 鸿蒙音乐播放器 3.0

本项目基于 `avplayer-play-formatted-audio-arkts-master2.0` 改造，主要增加了：

- 大小屏适配（phone / tablet / 2in1）
- 自由流转（跨设备迁移播放状态）

## 目录说明

- `3.0/` — 改造后的完整鸿蒙 ArkTS 工程

## 主要改动

1. `module.json5` 声明支持 `phone`、`tablet`、`2in1`，并开启 `continuable: true`
2. `EntryAbility.ets` 实现 `onContinue` / `onNewWant`，保存并恢复播放状态
3. `PlayerInfoComponent.ets` 补充 MD 断点双栏布局

> 原始项目文件见 `C:\Users\wensh\Downloads\avplayer-play-formatted-audio-arkts-master2.0` 本地备份。
