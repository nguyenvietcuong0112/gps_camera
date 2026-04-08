import 'package:flutter/material.dart';
import '../core/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeViewModel extends ChangeNotifier {
  final PermissionService _permissionService;

  HomeViewModel(this._permissionService);

  bool _hasPermissions = false;
  bool get hasPermissions => _hasPermissions;

  Future<void> checkPermissions() async {
    final results = await _permissionService.requestAllPermissions();
    _hasPermissions = results.values.every((status) => status.isGranted);
    notifyListeners();
  }
}
