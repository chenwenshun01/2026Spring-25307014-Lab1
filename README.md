# HarmonyOS Music Player Labs

This repository contains two versions of the HarmonyOS ArkTS music player project.

## 2.0 - Original Version

The original base project located in the `2.0/` folder.

## 3.0 - Responsive & Distributed Version

The enhanced version located in the `3.0/` folder, featuring:

- **Large/Small Screen Adaptation**: supports phone, tablet, and 2-in-1 devices using breakpoint-based responsive layouts (SM / MD / LG).
- **Free Flow / Distributed Continuation**: saves and restores playback state (`selectIndex`, `progress`, `playMode`) across devices via `onContinue` / `onNewWant` lifecycle hooks.

## How to Use

1. Open DevEco Studio.
2. Choose either `2.0/` or `3.0/` folder as the project root.
3. Sync dependencies and run on a HarmonyOS device or emulator.
