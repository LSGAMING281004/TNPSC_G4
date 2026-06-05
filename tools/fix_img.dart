import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/images/splash_bg.png');
  final image = img.decodeImage(file.readAsBytesSync());
  if (image != null) {
    print('Size: ${image.width} x ${image.height}, format: ${image.format}, channels: ${image.numChannels}');
    
    // Scale it down to a reasonable phone size like 1080x1920
    final scaled = img.copyResize(image, width: 1080, height: 1920);
    // Write it as standard PNG
    file.writeAsBytesSync(img.encodePng(scaled));
    print('Saved as 1080x1920 image.');
  }
}
