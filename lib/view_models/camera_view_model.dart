import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../core/models/photo_model.dart';
import '../core/services/location_service.dart';
import 'dart:async';

class CameraViewModel extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  int _cameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  PhotoMetadata? _currentLocation;
  StreamSubscription? _locationSubscription;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  FlashMode get flashMode => _flashMode;
  PhotoMetadata? get currentLocation => _currentLocation;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      await _initController(_cameras[_cameraIndex]);
    }
  }

  Future<void> _initController(CameraDescription description) async {
    _isInitialized = false;
    notifyListeners();

    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  void startLocationUpdates(LocationService locationService) {
    _locationSubscription?.cancel();
    _locationSubscription = locationService.locationStream.listen((
      locationData,
    ) {
      _currentLocation = PhotoMetadata(
        filePath: "", // Will be set on capture
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        address: locationData.address,
        city: locationData.city,
        timestamp: DateTime.now(),
      );
      notifyListeners();
    });
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) return null;
    if (_controller!.value.isTakingPicture) return null;

    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint("Error taking picture: $e");
      return null;
    }
  }

  Future<void> toggleCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _controller?.dispose();
    await _initController(_cameras[_cameraIndex]);
  }

  Future<void> toggleFlash() async {
    if (!_isInitialized) return;

    _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller?.setFlashMode(_flashMode);
    notifyListeners();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
