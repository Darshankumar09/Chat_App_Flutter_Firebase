import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/views/screens/chat_page.dart';
import 'package:chat_app/views/screens/home_page.dart';
import 'package:chat_app/views/screens/login_signup_page.dart';
import 'package:chat_app/views/screens/otp_verification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      initialRoute: "/login_page",
      getPages: [
        GetPage(
          name: "/login_page",
          page: () => const LoginSignUpPage(),
        ),
        GetPage(
          name: "/home_page",
          page: () => const HomePage(),
        ),
        GetPage(
          name: "/chat_page",
          page: () => const ChatPage(),
        ),
        GetPage(
          name: "/otp_page",
          page: () => const OtpVerification(),
        ),
      ],
    ),
  );
}
