import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  // ⚠️ Replace with your actual OneSignal credentials
  static const String _appId = 'bfd6bbd3-de11-4c38-9658-a533459a3301';
  static const String _restApiKey = 'os_v2_app_x7llxu66cfgdrfsyuuzulgrtagwcn7oz6kiet7vkbn2jxlbqvok2tf7lpyjb524b3dav4xkr63wy7ln6ueqd37ymc74bj4sr4dc7kaq';

  /// Broadcasts a push notification to all subscribed users via OneSignal REST API.
  /// Returns true if the notification was sent successfully.
  static Future<bool> sendPushNotification({
    required String title,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'included_segments': ['All'],
          'headings': {'en': title},
          'contents': {'en': message},
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Notification sent successfully');
        return true;
      } else {
        debugPrint('🔴 Notification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('🔴 Notification error: $e');
      return false;
    }
  }
}
