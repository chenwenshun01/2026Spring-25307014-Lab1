# 3.0 版本新增功能说明

## 概述

本版本（3.0）在原有 2.0 版本基础上，新增了**大小屏自适应布局**和**自由流转（分布式协同）**两大核心功能，使应用能够适配手机、平板、2合1设备等多种终端，并支持在不同鸿蒙设备间无缝迁移播放状态。

---

## 一、大小屏自适应布局

### 功能描述

应用通过监听窗口尺寸变化，自动识别当前设备类型（手机/平板/2合1），并动态切换为对应的响应式布局，确保在不同尺寸的屏幕上都能提供最佳的用户体验。

### 实现原理

- 使用 `BreakpointSystem` 工具类监听窗口宽度变化
- 定义三个断点（Breakpoint）：
  - **SM（Small）**：宽度 < 600vp，对应手机竖屏
  - **MD（Medium）**：宽度 600vp ~ 840vp，对应平板横屏 / 2合1 中等窗口
  - **LG（Large）**：宽度 ≥ 840vp，对应大屏 / PC / 折叠屏全展开
- 在 `PlayerInfoComponent` 中根据当前断点动态渲染不同布局

### 布局对照

| 断点 | 设备场景 | 布局方式 |
|---|---|---|
| SM | 手机竖屏 | 单列 Swiper 滑动切换（封面页 ↔ 歌词页） |
| MD | 平板横屏 / 2合1 | **双栏布局**：左4列封面+控制区，右4列歌词 |
| LG | 大屏 / PC / 折叠屏 | **双栏布局**：左4列封面+控制区，右6列歌词（更宽松） |

### 适配的设备类型

在 `module.json5` 中声明支持以下设备：

```json5
"deviceTypes": [
  "phone",
  "tablet",
  "2in1"
]
```

### 涉及修改的文件

| 文件 | 修改内容 |
|---|---|
| `entry/src/main/module.json5` | 扩展 `deviceTypes`，新增 `tablet` 和 `2in1` |
| `entry/src/main/ets/view/PlayerInfoComponent.ets` | 新增 MD 断点分支，实现双栏布局 |
| `entry/src/main/ets/common/utils/BreakpointSystem.ets` | （已有）断点监听工具类 |
| `entry/src/main/ets/common/constants/BreakpointConstants.ets` | （已有）断点常量定义 |

---

## 二、自由流转（分布式协同迁移）

### 功能描述

自由流转允许用户在一台鸿蒙设备上开始播放音乐后，通过系统级的"流转"入口，将应用状态**无缝迁移**到另一台鸿蒙设备上继续播放，无需手动记录进度或重新操作。

### 使用场景

- 手机上听歌，走到平板前，一键流转到平板继续播放
- 平板上看歌词，切换到台式机（2合1），自动恢复播放状态和进度

### 实现原理

利用鸿蒙 Ability 的 `onContinue` 生命周期回调，在应用迁移时保存关键状态数据，在目标设备上通过 `onCreate` 或 `onNewWant` 恢复状态。

#### 关键生命周期

| 生命周期 | 触发时机 | 作用 |
|---|---|---|
| `onContinue(wantParam)` | 源端同意迁移时 | 将播放状态写入 `wantParam`，供目标端恢复 |
| `onCreate(want, launchParam)` | 目标端冷启动时 | 检测是否为流转启动（`LaunchReason.CONTINUATION`），恢复状态 |
| `onNewWant(want)` | 目标端应用已运行时 | 直接接收流转数据，恢复状态 |

#### 迁移数据

| 数据项 | 说明 |
|---|---|
| `selectIndex` | 当前播放歌曲索引 |
| `progress` | 当前播放进度（毫秒） |
| `playMode` | 当前播放模式（顺序/单曲循环/随机） |

### 配置要求

在 `module.json5` 中声明 Ability 支持流转：

```json5
"abilities": [
  {
    "name": "EntryAbility",
    "continuable": true,
    // ...
  }
]
```

### 前置条件

- 源设备和目标设备登录**同一华为账号**
- 两台设备均开启 **Wi-Fi** 和 **蓝牙**
- 系统版本 ≥ **HarmonyOS API 9**
- 在系统设置中开启**多设备协同 / 自由流转**开关

### 涉及修改的文件

| 文件 | 修改内容 |
|---|---|
| `entry/src/main/module.json5` | 添加 `"continuable": true` |
| `entry/src/main/ets/entryability/EntryAbility.ets` | 实现 `onContinue`、`onNewWant`、`restoreContinuationState` |

---

## 三、编译与运行

### 编译环境

- **DevEco Studio**：6.0.0 Release 及以上
- **HarmonyOS SDK**：HarmonyOS 6.0.0 Release SDK 及以上
- **编译注意**：ArkTS 严格模式下禁止使用 `any`/`unknown` 类型，所有 `JSON.parse` 返回值需显式标注类型

### 运行设备

- 手机模拟器 / 真机
- 平板模拟器 / 真机（验证 MD 断点双栏布局）
- 2合1 设备模拟器 / 真机（验证 LG 断点布局）
- 两台鸿蒙设备（验证自由流转）

### 验证方法

#### 大小屏适配验证

1. 在 DevEco Studio 中打开 `Index.ets`
2. 使用 **Previewer** 预览器，切换不同设备（Phone / Tablet / 2in1）
3. 观察布局是否自动切换为单栏 / 双栏

或在虚拟机中运行后，**拖拽窗口边缘**改变宽度，观察布局实时变化。

#### 自由流转验证

1. 在设备 A 上启动应用并播放音乐（记录当前进度）
2. 从系统控制中心或最近任务中，点击**流转**按钮
3. 选择设备 B
4. 设备 B 自动启动应用，恢复到设备 A 的播放状态和进度

---

## 四、与 2.0 版本对比

| 功能 | 2.0 版本 | 3.0 版本 |
|---|---|---|
| 设备支持 | 仅手机（phone） | 手机 + 平板 + 2合1 |
| 布局适配 | 仅手机竖屏单列布局 | 响应式三断点布局（SM/MD/LG） |
| 自由流转 | 不支持 | 支持（跨设备状态迁移） |
| `module.json5` | `deviceTypes: ["phone"]` | `deviceTypes: ["phone","tablet","2in1"]` + `continuable: true` |

---

## 五、已知问题与限制

1. **模拟器限制**：DevEco Studio 模拟器可能不支持完整的分布式协同能力（无真实蓝牙硬件），自由流转建议在真机上验证。
2. **ArkTS 严格模式**：`JSON.parse` 返回值必须显式标注类型，否则编译报错（`arkts-no-any-unknown`）。
3. **账号依赖**：自由流转要求源设备和目标设备登录同一华为账号，且系统版本 ≥ API 9。

---

## 六、未来规划

- [ ] 支持更多断点（如折叠屏特殊形态）
- [ ] 优化 MD/LG 断点下的歌词显示效果
- [ ] 支持播控中心的跨设备同步
- [ ] 适配更多设备形态（车载、智慧屏等）
