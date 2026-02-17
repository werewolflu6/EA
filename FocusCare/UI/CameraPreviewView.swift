import SwiftUI
import AppKit

struct CameraPreviewView: View {
    let image: NSImage?
    let faceBoxes: [CGRect]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black)

                    FaceOverlayView(faceBoxes: faceBoxes)
                        .stroke(Color.green, lineWidth: 2)
                        .padding(1)
                } else {
                    ZStack {
                        Color.black
                        ProgressView("正在启动摄像头…")
                            .tint(.white)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

private struct FaceOverlayView: Shape {
    let faceBoxes: [CGRect]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for box in faceBoxes {
            let converted = CGRect(
                x: box.minX * rect.width,
                y: (1 - box.maxY) * rect.height,
                width: box.width * rect.width,
                height: box.height * rect.height
            )
            path.addRect(converted)
        }

        return path
    }
}
