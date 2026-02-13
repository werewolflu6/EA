import AVFoundation
import Vision
import CoreImage
import AppKit

@MainActor
final class CameraManager: NSObject, ObservableObject {
    @Published var latestImage: NSImage?
    @Published var faceBoxes: [CGRect] = []
    @Published var authorizationDenied = false
    @Published var sessionError: String?

    let session = AVCaptureSession()

    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "focuscare.camera.session")
    private let frameQueue = DispatchQueue(label: "focuscare.camera.frame")
    private let detector = FaceDetector()

    override init() {
        super.init()
        requestCameraPermissionAndSetup()
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    private func requestCameraPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStartSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    if granted {
                        self.configureAndStartSession()
                    } else {
                        self.authorizationDenied = true
                    }
                }
            }
        default:
            authorizationDenied = true
        }
    }

    private func configureAndStartSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            do {
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) ??
                        AVCaptureDevice.default(for: .video) else {
                    throw NSError(domain: "FocusCare", code: -1, userInfo: [NSLocalizedDescriptionKey: "未找到可用摄像头"])
                }

                let input = try AVCaptureDeviceInput(device: device)
                guard self.session.canAddInput(input) else {
                    throw NSError(domain: "FocusCare", code: -2, userInfo: [NSLocalizedDescriptionKey: "无法添加摄像头输入"])
                }
                self.session.addInput(input)

                self.videoOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.setSampleBufferDelegate(self, queue: self.frameQueue)

                guard self.session.canAddOutput(self.videoOutput) else {
                    throw NSError(domain: "FocusCare", code: -3, userInfo: [NSLocalizedDescriptionKey: "无法添加视频输出"])
                }
                self.session.addOutput(self.videoOutput)

                self.session.commitConfiguration()
                self.session.startRunning()
            } catch {
                self.session.commitConfiguration()
                Task { @MainActor in
                    self.sessionError = error.localizedDescription
                }
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let exif: CGImagePropertyOrientation = .leftMirrored
        let boxes = detector.detectFaceRects(in: pixelBuffer, orientation: exif)

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

        Task { @MainActor in
            self.latestImage = nsImage
            self.faceBoxes = boxes
        }
    }
}
