import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../view_models/camera_view_model.dart';
import '../core/services/location_service.dart';
import 'preview_screen.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final locationService = context.read<LocationService>();
        context.read<CameraViewModel>().startLocationUpdates(locationService);
      }
    });
  }

  @override
  void dispose() {
    // ViewModel is provided by provider, so we don't dispose it here.
    // But we should stop location updates if needed.
    // Usually ViewModel's dispose would handle it, but it's shared.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // Camera Preview
              Center(child: CameraPreview(viewModel.controller!)),

              // Overlay Information
              Positioned(
                bottom: 120.h,
                left: 20.w,
                right: 20.w,
                child: _buildLocationOverlay(viewModel),
              ),

              // Camera Controls
              Positioned(
                bottom: 30.h,
                left: 0,
                right: 0,
                child: _buildCameraControls(viewModel),
              ),

              // Back Button
              Positioned(
                top: 40.h,
                left: 20.w,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationOverlay(CameraViewModel viewModel) {
    if (viewModel.currentLocation == null) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Text(
          "Fetching location...",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final loc = viewModel.currentLocation!;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loc.address,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            "${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}",
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          SizedBox(height: 2.h),
          Text(
            "${loc.city} | ${loc.timestamp}",
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControls(CameraViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery/Switch Camera (optional)
        const SizedBox(width: 60),

        // Capture Button
        GestureDetector(
          onTap: () async {
            final file = await viewModel.takePicture();
            if (file != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PreviewScreen(
                    mediaFile: File(file.path),
                    locationData: viewModel.currentLocation,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 4.w),
            ),
          ),
        ),

        // Settings or Flash
        const SizedBox(width: 60),
      ],
    );
  }
}
