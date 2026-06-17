# HarmonyOS Music Player Labs

This repository contains three versions of the HarmonyOS ArkTS music player project.

## 1.0 - Original Version

The earliest base project located in the `1.0/` folder.

## 2.0 - Updated Base Version

The updated base project located in the `2.0/` folder.

## 3.0 - Responsive & Distributed Version

The enhanced version located in the `3.0/` folder, featuring:

- **Large/Small Screen Adaptation**: supports phone, tablet, and 2-in-1 devices using breakpoint-based responsive layouts (SM / MD / LG).
- **Free Flow / Distributed Continuation**: saves and restores playback state (`selectIndex`, `progress`, `playMode`) across devices via `onContinue` / `onNewWant` lifecycle hooks.

## How to Use

1. Open DevEco Studio.
2. Choose either `1.0/`, `2.0/`, or `3.0/` folder as the project root.
3. Sync dependencies and run on a HarmonyOS device or emulator.
