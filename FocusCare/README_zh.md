# FocusCare 阶段 1（摄像头 + Vision 人脸框 + SwiftUI 预览）

现在仓库已包含可直接打开的 **Xcode 工程文件**：`FocusCare.xcodeproj`。

## 已包含文件

- `FocusCare.xcodeproj`（可直接编译/调试）
- `FocusCare/Resources/Info.plist`（已配置 `NSCameraUsageDescription`）
- `FocusCare/App/FocusCareApp.swift`
- `FocusCare/Camera/CameraManager.swift`
- `FocusCare/Vision/FaceDetector.swift`
- `FocusCare/UI/ContentView.swift`
- `FocusCare/UI/CameraPreviewView.swift`

## 在 Xcode 运行

1. 用 Xcode 打开 `FocusCare.xcodeproj`。
2. 选择 `FocusCare` scheme。
3. 在 target 的 **Signing & Capabilities** 中设置你的 Team（首次运行需要）。
4. 运行（`⌘R`），首次弹窗允许摄像头权限。

## 当前能力

- 打开前置摄像头并实时预览。
- 使用 Vision 检测人脸框并叠加到预览画面。
- 显示当前检测到的人脸数量。

## 注意事项

- 本项目依赖 macOS 原生框架（SwiftUI/AVFoundation/Vision），请在 macOS + Xcode 环境编译。
- 如果遇到签名错误，先在 Xcode 中选择开发者 Team。

## 下一步

- 接入 `VNDetectFaceLandmarksRequest` 提取眼部关键点。
- 在此基础上实现 EAR 与眨眼率统计和提醒。
