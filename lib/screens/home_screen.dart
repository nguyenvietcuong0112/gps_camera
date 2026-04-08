import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../view_models/home_view_model.dart';
import 'camera_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeViewModel>().checkPermissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "GPS Camera",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1C1E),
            fontSize: 22.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                if (!viewModel.hasPermissions)
                  _buildPermissionNotice(viewModel),
                Expanded(
                  child: _buildMainCard(
                    title: "Camera & Photo",
                    icon: Icons.add_a_photo_outlined,
                    backgroundColor: const Color(0xFFFFF5F0),
                    borderColor: const Color(0xFFFF5722),
                    iconBackgroundColor: const Color(0xFFFF5722),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CameraScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: _buildMainCard(
                    title: "Capture Location",
                    icon: Icons.map_outlined,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFF00BCD4),
                    iconBackgroundColor: const Color(0xFF00BCD4),
                    backgroundImage: "assets/images/map_bg.png",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionNotice(HomeViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "Access required for camera and location.",
                style: GoogleFonts.outfit(
                  fontSize: 14.sp,
                  color: Colors.red[800],
                ),
              ),
            ),
            TextButton(
              onPressed: () => viewModel.checkPermissions(),
              child: Text(
                "Enable",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconBackgroundColor,
    String? backgroundImage,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(48.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(48.r),
          border: Border.all(color: borderColor, width: 2.5.w),
          image: backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.2),
                    BlendMode.dstATop,
                  ),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconBackgroundColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, size: 48.w, color: Colors.white),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1C1E),
                letterSpacing: -0.5,
              ),
            ),
          ],`1
        ),
      ),
    );
  }
}
