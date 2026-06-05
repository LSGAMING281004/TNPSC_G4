import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Generates all required branding assets for Thiral app.
/// Run: dart tools/generate_assets.dart
void main() async {
  // 1. Create directories
  Directory('assets/icons').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);
  Directory('assets/lottie').createSync(recursive: true);

  // Brand colors
  final navy = img.ColorRgba8(11, 30, 54, 255);       // #0B1E36
  final orange = img.ColorRgba8(240, 112, 32, 255);    // #F07020
  final gold = img.ColorRgba8(245, 197, 24, 255);      // #F5C518
  final white = img.ColorRgba8(255, 255, 255, 255);

  // ── 1. Main icon 1024×1024 ──────────────────────────────────────────
  final icon1024 = img.Image(width: 1024, height: 1024);
  img.fill(icon1024, color: navy);
  // Draw flame shape (simplified polygon)
  _drawFlame(icon1024, 512, 520, 380, orange, gold);
  // Draw "T" letter overlay
  _drawLetter(icon1024, 'T', 512, 480, white, 220);
  await File('assets/icons/icon_1024.png').writeAsBytes(img.encodePng(icon1024));
  print('✅ icon_1024.png');

  // ── 2. Icon 512×512 ─────────────────────────────────────────────────
  final icon512 = img.copyResize(icon1024, width: 512, height: 512);
  await File('assets/icons/icon_512.png').writeAsBytes(img.encodePng(icon512));
  print('✅ icon_512.png');

  // ── 3. Adaptive icon background ─────────────────────────────────────
  final adaptiveBg = img.Image(width: 1024, height: 1024);
  img.fill(adaptiveBg, color: navy);
  await File('assets/icons/adaptive_icon_bg.png').writeAsBytes(img.encodePng(adaptiveBg));
  print('✅ adaptive_icon_bg.png');

  // ── 4. Adaptive icon foreground (flame + T on transparent) ──────────
  final adaptiveFg = img.Image(width: 1024, height: 1024);
  // transparent background (RGBA)
  _drawFlame(adaptiveFg, 512, 520, 380, orange, gold);
  _drawLetter(adaptiveFg, 'T', 512, 470, white, 220);
  await File('assets/icons/adaptive_icon_fg.png').writeAsBytes(img.encodePng(adaptiveFg));
  print('✅ adaptive_icon_fg.png');

  // ── 5. Adaptive icon monochrome ──────────────────────────────────────
  final adaptiveMono = img.Image(width: 1024, height: 1024);
  final monoWhite = img.ColorRgba8(255, 255, 255, 255);
  _drawFlame(adaptiveMono, 512, 520, 380, monoWhite, monoWhite);
  _drawLetter(adaptiveMono, 'T', 512, 470, img.ColorRgba8(0, 0, 0, 255), 220);
  await File('assets/icons/adaptive_icon_mono.png').writeAsBytes(img.encodePng(adaptiveMono));
  print('✅ adaptive_icon_mono.png');

  // ── 6. Splash logo (centered flame + wordmark) ───────────────────────
  final splashLogo = img.Image(width: 600, height: 300);
  // transparent bg for splash logo
  _drawFlame(splashLogo, 90, 150, 100, orange, gold);
  // wordmark "THIRAL" text placeholder blocks
  _drawWordmark(splashLogo, 'THIRAL', 340, 120, white, 80);
  _drawWordmark(splashLogo, 'TNPSC GROUP 4', 340, 200, gold, 30);
  await File('assets/icons/splash_logo.png').writeAsBytes(img.encodePng(splashLogo));
  print('✅ splash_logo.png');

  // ── 7. Splash background ─────────────────────────────────────────────
  final splashBg = img.Image(width: 1080, height: 1920);
  img.fill(splashBg, color: navy);
  // Subtle radial glow in center
  _drawGlow(splashBg, 540, 960, 600, orange, 30);
  await File('assets/images/splash_bg.png').writeAsBytes(img.encodePng(splashBg));
  print('✅ splash_bg.png');

  // ── 8. Splash branding ───────────────────────────────────────────────
  final splashBranding = img.Image(width: 800, height: 100);
  _drawWordmark(splashBranding, 'Tamil Nadu\'s #1 Exam Prep App', 400, 50, 
      img.ColorRgba8(255, 255, 255, 180), 28);
  await File('assets/images/splash_branding.png').writeAsBytes(img.encodePng(splashBranding));
  print('✅ splash_branding.png');

  print('\n🎉 All assets generated! Now run:');
  print('  dart run flutter_launcher_icons');
  print('  dart run flutter_native_splash:create');
}

void _drawFlame(img.Image canvas, int cx, int cy, int size, 
    img.Color outerColor, img.Color innerColor) {
  // Outer flame
  for (int y = cy - size; y <= cy + size ~/ 3; y++) {
    final progress = (y - (cy - size)) / (size * 4 / 3);
    final halfWidth = (size * 0.6 * math.sin(progress * math.pi) * (1 - progress * 0.3)).toInt();
    for (int x = cx - halfWidth; x <= cx + halfWidth; x++) {
      if (x >= 0 && x < canvas.width && y >= 0 && y < canvas.height) {
        canvas.setPixel(x, y, outerColor);
      }
    }
  }
  // Inner flame (smaller, gold)
  final innerSize = (size * 0.55).toInt();
  for (int y = cy - innerSize + size ~/ 4; y <= cy + size ~/ 3; y++) {
    final progress = (y - (cy - innerSize + size ~/ 4)) / (innerSize * 4 / 3);
    final halfWidth = (innerSize * 0.5 * math.sin(progress * math.pi) * (1 - progress * 0.3)).toInt();
    for (int x = cx - halfWidth; x <= cx + halfWidth; x++) {
      if (x >= 0 && x < canvas.width && y >= 0 && y < canvas.height) {
        canvas.setPixel(x, y, innerColor);
      }
    }
  }
}

void _drawLetter(img.Image canvas, String letter, int cx, int cy, img.Color color, int size) {
  // Simple block letter T
  final thickness = size ~/ 6;
  // Horizontal bar
  img.fillRect(canvas, 
    x1: cx - size ~/ 2, y1: cy - size ~/ 2,
    x2: cx + size ~/ 2, y2: cy - size ~/ 2 + thickness,
    color: color);
  // Vertical bar
  img.fillRect(canvas,
    x1: cx - thickness ~/ 2, y1: cy - size ~/ 2,
    x2: cx + thickness ~/ 2, y2: cy + size ~/ 2,
    color: color);
}

void _drawWordmark(img.Image canvas, String text, int cx, int cy, img.Color color, int size) {
  // Placeholder: draw a rectangle representing text block
  final w = text.length * size ~/ 2;
  img.fillRect(canvas,
    x1: cx - w ~/ 2, y1: cy - size ~/ 2,
    x2: cx + w ~/ 2, y2: cy + size ~/ 2,
    color: color);
}

void _drawGlow(img.Image canvas, int cx, int cy, int radius, img.Color color, int maxAlpha) {
  for (int y = cy - radius; y <= cy + radius; y++) {
    for (int x = cx - radius; x <= cx + radius; x++) {
      final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
      if (dist <= radius && x >= 0 && x < canvas.width && y >= 0 && y < canvas.height) {
        final alpha = (maxAlpha * (1 - dist / radius)).toInt();
        canvas.setPixel(x, y, img.ColorRgba8(color.r.toInt(), color.g.toInt(), color.b.toInt(), alpha));
      }
    }
  }
}
