import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/models/photo_model.dart';
import '../core/repositories/photo_repository.dart';
import 'dart:ui' as ui;
import 'dart:io' as io;
import 'dart:typed_data';

class MapViewModel extends ChangeNotifier {
  final PhotoRepository _photoRepository;

  MapViewModel(this._photoRepository);

  List<PhotoMetadata> _photos = [];
  Set<Marker> _markers = {};
  bool _isLoading = false;

  List<PhotoMetadata> get photos => _photos;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;

  Future<void> loadPhotos(Function(PhotoMetadata) onMarkerTapped) async {
    _isLoading = true;
    notifyListeners();

    _photos = await _photoRepository.getAllPhotos();
    _markers = await _generateMarkers(onMarkerTapped);

    _isLoading = false;
    notifyListeners();
  }

  Future<Set<Marker>> _generateMarkers(
    Function(PhotoMetadata) onMarkerTapped,
  ) async {
    final Set<Marker> markers = {};
    for (var photo in _photos) {
      final descriptor = await _createCustomMarkerDescriptor(photo.filePath);
      markers.add(
        Marker(
          markerId: MarkerId(photo.id.toString()),
          position: LatLng(photo.latitude, photo.longitude),
          icon: descriptor,
          onTap: () => onMarkerTapped(photo),
        ),
      );
    }
    return markers;
  }

  Future<BitmapDescriptor> _createCustomMarkerDescriptor(
    String imagePath,
  ) async {
    try {
      final Uint8List imageBytes = await io.File(imagePath).readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 100,
        targetHeight: 100,
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ui.Image image = fi.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      const double size = 120.0;
      const double radius = size / 2;

      // Draw white border circle
      final Paint borderPaint = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(radius, radius), radius, borderPaint);

      // Draw red dot at top right
      final Paint dotPaint = Paint()..color = Colors.red;
      canvas.drawCircle(const Offset(size - 15, 15), 10, dotPaint);

      // Clip and draw image
      final Path clipPath = Path()
        ..addOval(Rect.fromLTWH(5, 5, size - 10, size - 10));
      canvas.clipPath(clipPath);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(5, 5, size - 10, size - 10),
        Paint(),
      );

      final ui.Picture picture = recorder.endRecording();
      final ui.Image markerImage = await picture.toImage(
        size.toInt(),
        size.toInt(),
      );
      final ByteData? byteData = await markerImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }
}
