import Vision
import AVFoundation

final class FaceDetector {
    private let sequenceHandler = VNSequenceRequestHandler()

    func detectFaceRects(in pixelBuffer: CVPixelBuffer,
                         orientation: CGImagePropertyOrientation) -> [CGRect] {
        let request = VNDetectFaceRectanglesRequest()

        do {
            try sequenceHandler.perform([request], on: pixelBuffer, orientation: orientation)
            let observations = request.results as? [VNFaceObservation] ?? []
            return observations.map(\.boundingBox)
        } catch {
            return []
        }
    }
}
