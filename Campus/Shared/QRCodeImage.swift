import SwiftUI
import CoreImage.CIFilterBuiltins

/// Black-on-white QR code drawn with sharp modules, filling its frame (no quiet zone).
/// Error correction "M": the Student ID QR in the reference uses level M.
struct QRCodeImage: View {
    let text: String

    var body: some View {
        if let image = QRCode.image(for: text) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .accessibilityLabel(Text(verbatim: "QR code: \(text)"))
        } else {
            Color.white
        }
    }
}

enum QRCode {
    /// One pixel per module, cropped to the modules so the caller decides the margin.
    static func image(for text: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage,
              let cgImage = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: trimmed(cgImage) ?? cgImage)
    }

    /// Core Image adds a white border; crop to the dark modules. The border is equal on all sides,
    /// so the bitmap's row order does not matter.
    private static func trimmed(_ image: CGImage) -> CGImage? {
        let width = image.width, height = image.height
        var pixels = [UInt8](repeating: 255, count: width * height)
        let drawn: Bool = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height,
                                          bitsPerComponent: 8, bytesPerRow: width,
                                          space: CGColorSpaceCreateDeviceGray(),
                                          bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        var minX = width, minY = height, maxX = -1, maxY = -1
        for y in 0..<height {
            for x in 0..<width where pixels[y * width + x] < 128 {
                minX = min(minX, x); maxX = max(maxX, x)
                minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        guard maxX >= minX else { return nil }
        return image.cropping(to: CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1))
    }
}
