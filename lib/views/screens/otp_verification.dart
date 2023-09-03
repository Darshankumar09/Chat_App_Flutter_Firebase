import 'package:chat_app/helpers/firebase_auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({super.key});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  TextEditingController phoneController = TextEditingController();
  int stackIndex = 0;
  String smsCode = "";

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: const Color.fromRGBO(0, 170, 0, 1.0),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.transparent,
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: IndexedStack(
        index: stackIndex,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Phone number",
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () async {
                    Map<String, dynamic> data = await FireBaseAuthHelper
                        .fireBaseAuthHelper
                        .phoneAuthentication(
                      phoneNumber: phoneController.text,
                    );
                    if (data['msg'] == null) {
                      setState(() {
                        stackIndex = 1;
                      });
                    } else {
                      Get.snackbar(
                        "Failed",
                        data['msg'],
                        backgroundColor: Colors.redAccent,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    "Verify OTP",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    androidSmsAutofillMethod:
                        AndroidSmsAutofillMethod.smsUserConsentApi,
                    showCursor: true,
                    onChanged: (val) {
                      smsCode = val;
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> data = await FireBaseAuthHelper
                          .fireBaseAuthHelper
                          .otpVerification(smsCode: smsCode);

                      if (data['user'] != null) {
                        Get.snackbar(
                          "Success",
                          "SignIn Successfully...",
                          backgroundColor: Colors.green,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        Get.offNamed(
                          "/home_page",
                        );
                      } else {
                        Get.snackbar(
                          "Failed",
                          data['msg'],
                          backgroundColor: Colors.redAccent,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text("Verify"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
