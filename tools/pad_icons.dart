import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final filesToPad = [
    'assets/icons/adaptive_icon_fg.png',
    'assets/icons/icon_1024.png',
    'assets/icons/icon_512.png',
    'assets/icons/icon_1024_with_bg.png' // maybe this too? wait, the user's icon has a black background, so I should pad it with black or transparent?
  ];

  for (final path in filesToPad) {
    final file = File(path);
    if (!file.existsSync()) continue;

    final image = img.decodeImage(file.readAsBytesSync());
    if (image == null) {
      print('Could not decode $path');
      continue;
    }

    final width = image.width;
    final height = image.height;
    
    // Create a new image of the same size
    // If it's icon_1024.png and it has a background, we might want to fill the background. 
    // Wait, let's just create a blank transparent image, and paste the scaled version in the center.
    // If it has a solid background, scaling it will leave a transparent border, which we might need to fill.
    
    // Let's check if the corners are black or transparent.
    final cornerPixel = image.getPixel(0, 0);
    
    final newImage = img.Image(width: width, height: height, format: img.Format.uint8, numChannels: 4);
    
    // Fill with corner pixel color (assuming it's the background color)
    img.fill(newImage, color: cornerPixel);
    
    // Scale down the original image to 75%
    final targetWidth = (width * 0.70).toInt();
    final targetHeight = (height * 0.70).toInt();
    
    final scaled = img.copyResize(image, width: targetWidth, height: targetHeight, interpolation: img.Interpolation.linear);
    
    final dx = (width - targetWidth) ~/ 2;
    final dy = (height - targetHeight) ~/ 2;
    
    img.compositeImage(newImage, scaled, dstX: dx, dstY: dy);
    
    file.writeAsBytesSync(img.encodePng(newImage));
    print('Padded $path');
  }
}
