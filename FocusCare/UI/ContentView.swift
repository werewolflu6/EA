import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var cameraManager: CameraManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FocusCare - 阶段 1：摄像头 + Vision 人脸框 + 预览")
                .font(.title3)
                .bold()

            if cameraManager.authorizationDenied {
                Text("未获得摄像头权限，请到 系统设置 > 隐私与安全性 > 摄像头 开启权限。")
                    .foregroundStyle(.red)
            } else if let sessionError = cameraManager.sessionError {
                Text("摄像头初始化失败：\(sessionError)")
                    .foregroundStyle(.red)
            }

            CameraPreviewView(image: cameraManager.latestImage, faceBoxes: cameraManager.faceBoxes)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(12)

            Text("检测到人脸数量：\(cameraManager.faceBoxes.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}
