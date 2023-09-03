import 'package:firebase_messaging/firebase_messaging.dart';

class FCMHelper {
  FCMHelper._();

  static final FCMHelper fcmHelper = FCMHelper._();

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    String? fcmToken = await firebaseMessaging.getToken();

    return fcmToken;
  }
}
