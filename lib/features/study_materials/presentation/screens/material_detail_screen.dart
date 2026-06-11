import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MaterialDetailScreen extends StatelessWidget {
  final String materialId;
  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indian History'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: const Center(child: Text('PDF Viewer will be loaded here\n(flutter_pdfview)', textAlign: TextAlign.center)),
    );
  }
}
