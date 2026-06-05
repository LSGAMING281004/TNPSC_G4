import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final inputPath = 'assets/icons/icon_1024.png';
  final file = File(inputPath);
  if (!file.existsSync()) {
    print('Error: Source image $inputPath not found. Please place the 1024x1024 master icon PNG first.');
    return;
  }

  print('Reading source image $inputPath...');
  final imageBytes = await file.readAsBytes();
  final sourceImage = img.decodePng(imageBytes);

  if (sourceImage == null) {
    print('Error: Failed to decode source image.');
    return;
  }

  final exportsDir = Directory('assets/icons/exports');
  if (!exportsDir.existsSync()) {
    exportsDir.createSync(recursive: true);
  }

  // Define target sizes
  final androidSizes = [48, 72, 96, 144, 192, 512];
  final iosSizes = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024];
  final webSizes = [16, 32, 48, 64, 96, 128, 192, 512];

  print('Exporting Android sizes...');
  for (var size in androidSizes) {
    final resized = img.copyResize(sourceImage, width: size, height: size);
    final outFile = File('${exportsDir.path}/android_$size.png');
    await outFile.writeAsBytes(img.encodePng(resized));
    print('  -> Exported android_$size.png');
  }

  print('Exporting iOS sizes...');
  for (var size in iosSizes) {
    final resized = img.copyResize(sourceImage, width: size, height: size);
    final outFile = File('${exportsDir.path}/ios_$size.png');
    await outFile.writeAsBytes(img.encodePng(resized));
    print('  -> Exported ios_$size.png');
  }

  print('Exporting Web sizes...');
  for (var size in webSizes) {
    final resized = img.copyResize(sourceImage, width: size, height: size);
    final outFile = File('${exportsDir.path}/web_$size.png');
    await outFile.writeAsBytes(img.encodePng(resized));
    print('  -> Exported web_$size.png');
  }

  print('\nAll launcher icons exported successfully to ${exportsDir.path}!');
}
