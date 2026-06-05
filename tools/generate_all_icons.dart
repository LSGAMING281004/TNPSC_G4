import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final sourceIconPath = r'C:\Users\Lokesh\.gemini\antigravity\brain\1b828d2d-91b7-443d-879f-bfa98799454d\icon_1024_with_bg_1780572913873.png';
  final sourceSplashBgPath = r'C:\Users\Lokesh\.gemini\antigravity\brain\1b828d2d-91b7-443d-879f-bfa98799454d\splash_bg_1780572929757.png';

  final iconFile = File(sourceIconPath);
  final splashFile = File(sourceSplashBgPath);

  if (!iconFile.existsSync()) {
    print('Error: Source icon file not found at $sourceIconPath');
    return;
  }
  if (!splashFile.existsSync()) {
    print('Error: Source splash bg file not found at $sourceSplashBgPath');
    return;
  }

  // Create directories
  Directory('assets/icons').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);
  Directory('assets/logos').createSync(recursive: true);
  Directory('web/icons').createSync(recursive: true);

  print('Copying base files...');
  // 1. Copy icon_1024_with_bg
  await iconFile.copy('assets/icons/icon_1024_with_bg.png');
  // 2. Copy splash_bg
  await splashFile.copy('assets/images/splash_bg.png');
  print('Base files copied.');

  print('Decoding source icon...');
  final iconBytes = await iconFile.readAsBytes();
  final sourceImg = img.decodeImage(iconBytes);
  if (sourceImg == null) {
    print('Error: Failed to decode source icon.');
    return;
  }

  // 3. Generate icon_1024.png (Transparent background)
  // We will process the image to replace navy-like colors with transparency.
  print('Generating transparent icon_1024.png...');
  final transparentImg = img.Image.from(sourceImg);
  
  // Custom color replacement for transparency (Navy #0B1E36)
  for (var y = 0; y < transparentImg.height; y++) {
    for (var x = 0; x < transparentImg.width; x++) {
      final pixel = transparentImg.getPixel(x, y);
      // In package:image, pixel colors can be accessed by channel values
      final r = pixel.r;
      final g = pixel.g;
      final b = pixel.b;

      // Navy threshold check
      if ((r - 11).abs() < 24 && (g - 30).abs() < 24 && (b - 54).abs() < 24) {
        transparentImg.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
      }
    }
  }

  final transparentPng = img.encodePng(transparentImg);
  await File('assets/icons/icon_1024.png').writeAsBytes(transparentPng);
  await File('assets/logos/logo_mark_1024.png').writeAsBytes(transparentPng);
  print('  -> Generated assets/icons/icon_1024.png');

  // 4. Generate adaptive_icon_fg.png (1080x1080 transparent background, centered in 720x720)
  print('Generating adaptive_icon_fg.png...');
  final fgImg = img.Image(width: 1080, height: 1080, numChannels: 4);
  // Resize transparent logo to 720x720
  final resizedLogo = img.copyResize(transparentImg, width: 720, height: 720);
  // Draw onto center of 1080x1080 canvas
  img.compositeImage(fgImg, resizedLogo, dstX: 180, dstY: 180);
  await File('assets/icons/adaptive_icon_fg.png').writeAsBytes(img.encodePng(fgImg));
  print('  -> Generated assets/icons/adaptive_icon_fg.png');

  // 5. Generate adaptive_icon_bg.png (Solid #0B1E36)
  print('Generating adaptive_icon_bg.png...');
  final bgImg = img.Image(width: 1080, height: 1080);
  bgImg.clear(img.ColorRgb8(11, 30, 54)); // #0B1E36
  await File('assets/icons/adaptive_icon_bg.png').writeAsBytes(img.encodePng(bgImg));
  print('  -> Generated assets/icons/adaptive_icon_bg.png');

  // 6. Generate adaptive_icon_mono.png (1080x1080 black background with white logo silhouette)
  print('Generating adaptive_icon_mono.png...');
  final monoImg = img.Image(width: 1080, height: 1080);
  monoImg.clear(img.ColorRgb8(0, 0, 0)); // Black background
  
  // Make a white silhouette of the resized logo
  final whiteLogo = img.Image.from(resizedLogo);
  for (var y = 0; y < whiteLogo.height; y++) {
    for (var x = 0; x < whiteLogo.width; x++) {
      final pixel = whiteLogo.getPixel(x, y);
      if (pixel.a > 30) {
        whiteLogo.setPixel(x, y, img.ColorRgba8(255, 255, 255, 255));
      } else {
        whiteLogo.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
      }
    }
  }
  img.compositeImage(monoImg, whiteLogo, dstX: 180, dstY: 180);
  await File('assets/icons/adaptive_icon_mono.png').writeAsBytes(img.encodePng(monoImg));
  print('  -> Generated assets/icons/adaptive_icon_mono.png');

  // 7. Generate icon_512.png
  print('Generating icon_512.png...');
  final icon512 = img.copyResize(sourceImg, width: 512, height: 512);
  await File('assets/icons/icon_512.png').writeAsBytes(img.encodePng(icon512));
  print('  -> Generated assets/icons/icon_512.png');

  // 8. Generate splash_logo.png (288x288 transparent)
  print('Generating splash_logo.png...');
  final splashLogo = img.copyResize(transparentImg, width: 288, height: 288);
  await File('assets/icons/splash_logo.png').writeAsBytes(img.encodePng(splashLogo));
  print('  -> Generated assets/icons/splash_logo.png');

  // 9. Generate splash_branding.png (540x96 transparent branding wordmark)
  print('Generating splash_branding.png...');
  final brandingImg = img.Image(width: 540, height: 96, numChannels: 4);
  // We can write a fallback branding or draw simple text blocks
  // For now, let's keep it transparent or write a beautiful colored background
  await File('assets/images/splash_branding.png').writeAsBytes(img.encodePng(brandingImg));
  print('  -> Generated assets/images/splash_branding.png');

  // 10. Generate web/og-image.png and assets/images/og_image.png (1200x630)
  print('Generating og-image.png...');
  final ogBg = img.Image(width: 1200, height: 630);
  ogBg.clear(img.ColorRgb8(11, 30, 54)); // #0B1E36 background
  // Add logo to left side
  final ogLogo = img.copyResize(sourceImg, width: 320, height: 320);
  img.compositeImage(ogBg, ogLogo, dstX: 100, dstY: 155);
  final ogEncoded = img.encodePng(ogBg);
  await File('assets/images/og_image.png').writeAsBytes(ogEncoded);
  await File('web/og-image.png').writeAsBytes(ogEncoded);
  print('  -> Generated og-image.png');

  // 11. Copy favicon.png
  final favicon = img.copyResize(sourceImg, width: 64, height: 64);
  await File('web/favicon.png').writeAsBytes(img.encodePng(favicon));
  print('  -> Generated web/favicon.png');

  print('\nAll master icon variants generated successfully!');
}
