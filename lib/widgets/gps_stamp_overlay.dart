import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/services/location_service.dart';
import '../core/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GpsStampOverlay extends StatelessWidget {
  final LocationData? locationData;

  const GpsStampOverlay({super.key, this.locationData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('dd/MM/yyyy').format(now);

    return Container(
      width: 280.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini Map Thumbnail
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?center=${locationData?.latitude},${locationData?.longitude}&zoom=15&size=100x100&key=YOUR_KEY",
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 32.w,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locationData?.city ?? "Locating...",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  locationData?.address ?? "Unknown Address",
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Lat ${locationData?.latitude.toStringAsFixed(6) ?? '0.000000'}",
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
                Text(
                  "Long ${locationData?.longitude.toStringAsFixed(6) ?? '0.000000'}",
                  style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                ),
                Text(
                  "$timeStr - $dateStr",
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
