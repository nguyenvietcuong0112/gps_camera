import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../core/models/photo_model.dart';
import '../core/repositories/photo_repository.dart';
import 'dart:io';

class PreviewScreen extends StatefulWidget {
  final File mediaFile;
  final PhotoMetadata? locationData;
  final List<double>? colorFilterMatrix;

  const PreviewScreen({
    super.key,
    required this.mediaFile,
    this.locationData,
    this.colorFilterMatrix,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  Future<void> _saveToGallery() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final bytes = await _screenshotController.capture();

      if (bytes != null) {
        final result = await ImageGallerySaver.saveImage(
          bytes,
          quality: 100,
          name: "GPS_CAM_${DateTime.now().millisecondsSinceEpoch}",
        );

        if (result['isSuccess'] == true) {
          if (!mounted) return;
          final photoRepo = context.read<PhotoRepository>();
          final metadata = PhotoMetadata(
            filePath: widget.mediaFile.path,
            latitude: widget.locationData?.latitude ?? 0.0,
            longitude: widget.locationData?.longitude ?? 0.0,
            address: widget.locationData?.address ?? "",
            city: widget.locationData?.city ?? "",
            timestamp: DateTime.now(),
            filterName: widget.colorFilterMatrix != null ? "custom" : null,
          );
          await photoRepo.savePhoto(metadata);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Saved to gallery with GPS stamp!")),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Preview"),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveToGallery,
            ),
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Stack(
          children: [
            Center(
              child: widget.colorFilterMatrix != null
                  ? ColorFiltered(
                      colorFilter: ColorFilter.matrix(
                        widget.colorFilterMatrix!,
                      ),
                      child: Image.file(widget.mediaFile),
                    )
                  : Image.file(widget.mediaFile),
            ),
            if (widget.locationData != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.locationData!.address,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.locationData!.latitude.toStringAsFixed(6)}, ${widget.locationData!.longitude.toStringAsFixed(6)}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.locationData!.city} | ${widget.locationData!.timestamp}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
