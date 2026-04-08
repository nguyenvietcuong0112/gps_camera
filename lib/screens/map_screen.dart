import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../core/models/photo_model.dart';
import '../view_models/map_view_model.dart';
import '../core/theme.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(10.762622, 106.660172); // Default
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().loadPhotos(_showPhotoDetail);
    });
  }

  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      return;
    }

    try {
      if (!mounted) return;
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
      }
    } catch (e) {
      debugPrint("Error getting current location: $e");
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showPhotoDetail(PhotoMetadata photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPhotoDetailCard(photo),
    );
  }

  Widget _buildPhotoDetailCard(PhotoMetadata photo) {
    final DateTime dateTime = photo.timestamp;
    final String formattedDate = DateFormat(
      'dd/MM/yyyy hh:mm a',
    ).format(dateTime);

    final String displayName =
        photo.address.isNotEmpty && photo.address.contains(',')
        ? photo.address.split(',')[0]
        : (photo.address.isNotEmpty ? photo.address : "Captured Location");

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child:
                    photo.filePath.isNotEmpty &&
                        File(photo.filePath).existsSync()
                    ? Image.file(
                        File(photo.filePath),
                        height: 200.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200.h,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Title & Date
          Text(
            displayName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14.w,
                color: Colors.grey[600],
              ),
              SizedBox(width: 6.w),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Address Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFD3D3D3).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        photo.address,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Coordinates row
          Row(
            children: [
              Expanded(
                child: _buildCoordinateContainer(
                  "Lat",
                  photo.latitude.toStringAsFixed(6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCoordinateContainer(
                  "Long",
                  photo.longitude.toStringAsFixed(6),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Save Button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.save_outlined, size: 20.w, color: Colors.white),
            label: Text(
              "Save",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildCoordinateContainer(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFD3D3D3).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Capture Location",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<MapViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation,
                  zoom: 15,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: viewModel.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              if (viewModel.isLoading || _isLoadingLocation)
                const Center(child: CircularProgressIndicator()),
              _buildMapControls(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapControls() {
    return Stack(
      children: [
        // Zoom Controls
        Positioned(
          right: 16.w,
          bottom: 150.h,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.add,
                onTap: () =>
                    _mapController?.animateCamera(CameraUpdate.zoomIn()),
              ),
              SizedBox(height: 8.h),
              _buildMapControl(
                icon: Icons.remove,
                onTap: () =>
                    _mapController?.animateCamera(CameraUpdate.zoomOut()),
              ),
            ],
          ),
        ),
        // Current Location
        Positioned(
          right: 16.w,
          bottom: 80.h,
          child: _buildMapControl(
            icon: Icons.my_location,
            onTap: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(_currentLocation),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
