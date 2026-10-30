import CoreGraphics
import WebGraphics
extension Image {
    public init(_bitmap bitmap: DisplayBitmap, size: CGSize, scale: CGFloat) {
        let commands = [DisplayCommand.drawBitmap(bitmap, rect: CGRect(origin: .zero, size: size))]
        self.init(source: .drawing(_ImageDrawing(commands: commands, size: size, scale: scale)), label: nil)
    }
}
