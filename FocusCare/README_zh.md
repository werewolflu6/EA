# FocusCare 阶段 1（摄像头 + Vision 人脸框 + SwiftUI 预览）

这是一个可直接放入 Xcode macOS App 工程的最小实现。

## 文件

- `App/FocusCareApp.swift`
- `Camera/CameraManager.swift`
- `Vision/FaceDetector.swift`
- `UI/ContentView.swift`
- `UI/CameraPreviewView.swift`

## 接入方式

1. 在 Xcode 新建 `macOS > App`（SwiftUI）工程。
2. 将上述文件复制到工程中。
3. 在 `Info.plist` 增加：
   - `NSCameraUsageDescription`：例如“用于检测人脸状态与专注时长”。
4. 运行后允许摄像头权限。

## 当前能力

- 打开前置摄像头并实时预览。
- 用 Vision 检测人脸框并叠加显示。
- 底部显示当前人脸数量。

## 下一步

- 接 `VNDetectFaceLandmarksRequest` 提取眼部关键点。
- 在此基础上实现 EAR 与眨眼率统计。
