import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestMicrophonePermission(BuildContext context,
      {bool canOpenAppSetting = true}) async {
    bool isGranted = await Permission.microphone.status.then(
      (status) async {
        if (status.isGranted) {
          return true;
        } else if (status.isDenied) {
          if (context.mounted) {
            // Nếu người dùng từ chối cấp quyền
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'You need to grant microphone permission to use this feature'),
              duration: Duration(seconds: 2),
            ));
            await Future.delayed(const Duration(seconds: 2));
          }

          // Thử yêu cầu quyền lần nữa
          status = await Permission.microphone.request();
          if (status.isPermanentlyDenied) {
            // Nếu người dùng từ chối vĩnh viễn (và chọn "Don't ask again")
            // await openAppSettings(); // Mở cài đặt ứng dụng
            return false;
          } else if (status.isGranted) {
            return true;
          }
          return false;
        } else if (status.isPermanentlyDenied) {
          // Nếu quyền đã bị từ chối vĩnh viễn
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'You need to go to settings to grant microphone permission.'),
              duration: Duration(seconds: 2),
            ));
            await Future.delayed(const Duration(seconds: 2));
          }

          if (canOpenAppSetting) {
            await openAppSettings(); // Mở cài đặt ứng dụng
          }
          return false;
        } else {
          return false;
        }
      },
    );
    return isGranted;
  }
}
