# macOS 摄像头专注健康助手（开发指南）

## 你的目标（可落地版）
你想做一个 macOS 应用，实时读取摄像头视频，并完成：

1. 人脸识别（更准确说法：人脸检测 + 人脸状态跟踪）。
2. 检测眨眼频率；若过低，语音提醒。
3. 判断持续专注时长；连续看屏 45 分钟后语音提醒休息。
4. 统计工作期间的应用使用时长。

---

## 推荐技术栈（macOS 原生优先）

- **语言/UI**：Swift + SwiftUI。
- **摄像头采集**：AVFoundation（`AVCaptureSession`）。
- **人脸与关键点**：Vision（`VNDetectFaceLandmarksRequest`）。
- **语音提醒**：AppKit 的 `NSSpeechSynthesizer`。
- **应用使用统计**：`NSWorkspace` + `NSRunningApplication` + 定时采样。
- **本地存储**：SQLite（推荐 GRDB）或 Core Data。

> 备注：如果你必须跨平台，才考虑 Electron + Python（OpenCV/dlib）；但在 macOS 下，原生方案性能和权限体验更稳。

---

## 功能拆解与实现思路

### 1) 人脸识别 / 人脸状态检测

**建议先做“人脸检测+跟踪”，再考虑身份识别**：

- 使用 `VNDetectFaceRectanglesRequest` 获取人脸框。
- 使用 `VNDetectFaceLandmarksRequest` 获取眼睛关键点。
- 每帧处理建议降采样（如 10~15 FPS）减少 CPU 占用。

如果你确实要“识别人是谁”：
- 可以做本地人脸 embedding（如 ArcFace/CoreML 模型）。
- 首版建议不做人脸身份库，先把“有人/无人、是否疲劳”做稳定。

### 2) 眨眼频率检测与低频提醒

核心指标：**EAR（Eye Aspect Ratio）**。

- 从 Vision 关键点提取每只眼的上下/左右距离。
- EAR 低于阈值（例如 0.18~0.22，需实测）判定“闭眼帧”。
- 闭眼帧持续 > N 帧记一次 blink。
- 用滑动窗口（例如最近 60 秒）计算 blink/min。
- 当 blink/min < 阈值（例如 < 8 次/分钟）触发提醒：
  - “你可能用眼过久，请有意识眨眼并休息 20 秒。”
- 增加提醒冷却时间（例如 3~5 分钟），避免频繁打扰。

### 3) 专注时长与 45 分钟休息提醒

定义“连续看屏幕”的状态机：

- `activeFocus = true` 条件示例：
  - 前台有活动应用；
  - 摄像头检测到人脸；
  - 最近 X 分钟无长时间离开。
- 若 `activeFocus` 连续累计到 45 分钟：
  - 语音提醒“已连续工作 45 分钟，请起身休息 5 分钟。”
- 若中途离开（无人脸持续 > 3 分钟）或锁屏，则重置/暂停计时。

建议使用：
- `DispatchSourceTimer` 每秒 tick 更新状态。
- 持久化每段 focus session（开始、结束、时长、中断原因）。

### 4) 统计应用与使用时长

可行方案（不依赖私有 API）：

- 每 1~5 秒轮询 `NSWorkspace.shared.frontmostApplication`。
- 记录当前 bundle id + app 名称 + 时间戳。
- 同一个 app 连续采样聚合为一个时间段。
- 最终按天汇总：
  - 总工作时长
  - 各应用时长占比
  - 专注会话分布

可视化：
- SwiftUI + Charts（macOS 13+）做柱状图/饼图。

---

## 权限与合规（macOS 关键）

你需要处理以下权限：

- **Camera**：读取摄像头。
- **Microphone**：如果你未来要录音才需要（当前不必须）。
- **Accessibility / Screen Recording**：
  - 仅统计前台 app 通常不需要屏幕录制；
  - 若你要更细粒度行为（窗口标题、输入事件），可能需要辅助功能权限。

Info.plist 至少添加：
- `NSCameraUsageDescription`

并在首次启动时给出清晰说明：
- 数据是否本地存储
- 是否上传云端
- 如何删除数据

---

## 推荐项目结构

```text
FocusCare/
  App/
    FocusCareApp.swift
  Camera/
    CameraManager.swift
    FrameProcessor.swift
  Vision/
    FaceLandmarkService.swift
    BlinkDetector.swift
  Focus/
    FocusSessionManager.swift
    ReminderScheduler.swift
  Activity/
    FrontmostAppTracker.swift
    ActivityAggregator.swift
  Speech/
    VoiceAlertService.swift
  Storage/
    Database.swift
    Repositories/
  UI/
    DashboardView.swift
    StatsView.swift
    PermissionsView.swift
```

---

## 关键算法参数（首版建议）

- 视频处理帧率：10~15 FPS
- EAR 闭眼阈值：0.20（按设备调参）
- 眨眼低频阈值：< 8 次/分钟
- 眨眼提醒冷却：5 分钟
- 连续专注提醒：45 分钟
- 休息建议时长：5 分钟
- 人脸丢失重置阈值：180 秒

---

## MVP 开发路线（2~4 周）

### 第 1 周
- 打通摄像头预览与人脸框。
- 完成权限流。

### 第 2 周
- 加入眼部关键点与 EAR 眨眼检测。
- 增加语音提醒与冷却机制。

### 第 3 周
- 实现专注会话状态机（45 分钟提醒）。
- 实现前台应用时长统计与本地存储。

### 第 4 周
- 做统计看板、参数设置、稳定性优化（CPU/内存）。

---

## 先给你的实操建议

如果你现在立刻开工，按下面顺序最稳：

1. 先做“摄像头 + Vision 人脸框 + SwiftUI 预览”。
2. 再做“EAR + blink/min + 语音提醒”。
3. 再做“45 分钟会话计时”。
4. 最后加“应用使用统计 + 图表”。

这样你每一步都可验证，不会一开始就陷入复杂架构。
