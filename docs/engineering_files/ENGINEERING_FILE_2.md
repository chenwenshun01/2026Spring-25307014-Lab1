# 工程文件2：新增功能说明

本文档汇总本次在基础工程 **avplayer-play-formatted-audio-arkts** 上新增的所有功能点（包含已完成的睡眠定时，以及新增的两个可在 UI 中直接看到的功能）。

> 工程根目录：
> `C:\Users\wensh\Downloads\avplayer-play-formatted-audio-arkts-master\avplayer-play-formatted-audio-arkts-master`

---

## 新增功能 1：睡眠定时（Sleep Timer）

### UI 表现
- 在播放控制区顶部图标行新增 **计时器（timer）** 图标。
- 点击弹出面板，可选择 **15/30/60 分钟**，并显示剩余时间。
- 倒计时归零后自动 **暂停播放**。

### 关键实现
- 新增：`entry/src/main/ets/common/utils/mediautils/SleepTimerManager.ets`
- 修改：`entry/src/main/ets/view/ControlAreaComponent.ets`
- 文案：`entry/src/main/resources/(zh_CN|en_US|base)/element/string.json`

---

## 新增功能 2：A-B 循环（A-B Loop）

### UI 表现
- 在播放控制区顶部图标行新增 **A-B 循环入口**（使用 repeat_1 图标）。
- 点击弹出面板：
  - **Set A**：把当前播放进度设为 A 点
  - **Set B**：把当前播放进度设为 B 点
  - **On/Off**：开启/关闭 A-B 循环
  - **Reset**：清除 A/B 点并关闭循环
- 开启后：播放进度到达 B 点时会自动跳回 A 点（循环播放 A~B 片段）。

### 关键实现
- 新增：`entry/src/main/ets/common/utils/mediautils/ABLoopManager.ets`
- 修改：
  - `entry/src/main/ets/common/utils/mediautils/AVPlayerController.ets`（在 timeUpdate 回调中挂载 AB 逻辑）
  - `entry/src/main/ets/view/ControlAreaComponent.ets`（新增 UI 面板、按钮、状态展示）
- 新增 AppStorage Key：`abA` / `abB` / `abEnabled`

---

## 新增功能 3：主题切换（Theme Switch）

### UI 表现
- 在播放控制区顶部图标行新增 **主题（palette）** 图标。
- 点击弹出主题面板，可选择：
  - **Auto**：默认（跟随原本的动态背景色 imageColor）
  - **Dark**：强制黑色背景
  - **Light**：强制白色背景
- 切换后播放器页面背景立刻变化，便于录屏展示“可见改动”。

### 关键实现
- 修改：
  - `entry/src/main/ets/view/ControlAreaComponent.ets`（主题选择面板，写入 `themeIndex`）
  - `entry/src/main/ets/view/PlayerInfoComponent.ets`（根据 `themeIndex` 决定 backgroundColor）
- 新增 AppStorage Key：`themeIndex`（0=Auto,1=Dark,2=Light）

---

## 录屏展示建议顺序

1. 打开应用并开始播放。
2. 点击 **计时器** → 设定 15 分钟（展示面板与剩余时间）。
3. 点击 **A-B 循环** → Set A → 播放几秒 → Set B → On（展示循环跳回）。
4. 点击 **主题** → 切换 Dark/Light（展示背景明显变化）。

---

## 文案资源新增 key（摘要）

- 睡眠定时：`sleep_timer*`、`remaining`、`cancel`
- A-B 循环：`ab_loop`、`set_a`、`set_b`、`turn_on`、`turn_off`、`reset`、`close`
- 主题：`theme`、`theme_auto`、`theme_dark`、`theme_light`
