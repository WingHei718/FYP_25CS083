import 'package:permission_handler/permission_handler.dart';

class PermissionService {
	// Camera Permission
	static Future<bool> checkCameraPermission() async {
		var status = await Permission.camera.status;
		if (status.isGranted) return true;

		status = await Permission.camera.request();
		return status.isGranted;
	}

	// Open app settings for user to choose
	static Future<bool> openSettings() async {
		return openAppSettings();
	}
}
