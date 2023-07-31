import 'package:chat_app/controllers/signIn_controller.dart';
import 'package:chat_app/utils/globals.dart';
import 'package:chat_app/utils/helpers/fcm_helper.dart';
import 'package:chat_app/utils/helpers/firebase_auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSignUpPage extends StatefulWidget {
  const LoginSignUpPage({super.key});

  @override
  State<LoginSignUpPage> createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  SignInController signInController = Get.put(SignInController());

  int stackIndex = 0;

  GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  TextEditingController signInEmailController = TextEditingController();
  TextEditingController signInPasswordController = TextEditingController();

  String? signInEmail;
  String? signInPassword;

  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();

  TextEditingController signUpEmailController = TextEditingController();
  TextEditingController signUpPasswordController = TextEditingController();
  TextEditingController signUpConfirmPasswordController =
      TextEditingController();

  String? signUpEmail;
  String? signUpPassword;
  String? signUpConfirmPassword;

  String? fcmToken;

  @override
  initState() {
    super.initState();
    getToken();
  }

  getToken() async {
    fcmToken = await FCMHelper.fcmHelper.getFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: IndexedStack(
        index: stackIndex,
        children: [
          Form(
            key: signInFormKey,
            child: Padding(
              padding: EdgeInsets.all(height * 0.016),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: height * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: height * 0.024,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    TextFormField(
                      controller: signInEmailController,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) {
                        signInEmail = val;
                      },
                      validator: (val) =>
                          (val!.isEmpty) ? "Enter email address.." : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Email",
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: height * 0.024,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    TextFormField(
                      controller: signInPasswordController,
                      obscureText: true,
                      onSaved: (val) {
                        signInPassword = val;
                      },
                      validator: (val) =>
                          (val!.isEmpty) ? "Enter password.." : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Password",
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (signInFormKey.currentState!.validate()) {
                            signInFormKey.currentState!.save();

                            Map<String, dynamic> data = await FireBaseAuthHelper
                                .fireBaseAuthHelper
                                .signInWithEmailAndPassword(
                              email: signInEmail!,
                              password: signInPassword!,
                              fcmToken: fcmToken!,
                            );

                            if (data['user'] != null) {
                              Get.snackbar(
                                "Success",
                                "SignIn Successfully...",
                                backgroundColor: Colors.green,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              Get.offNamed(
                                "/home_page",
                                arguments: data['user'],
                              );
                              signInController.signIn();
                              signInEmailController.clear();
                              signInPasswordController.clear();
                            } else {
                              Get.snackbar(
                                "Failed",
                                data['msg'],
                                backgroundColor: Colors.redAccent,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          }
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: height * 0.02,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account?",
                              style: TextStyle(
                                fontSize: height * 0.02,
                              ),
                            ),
                            TextSpan(
                              text: " Sign Up",
                              recognizer: TapAndPanGestureRecognizer()
                                ..onTapUp = (details) {
                                  setState(() {
                                    signInEmailController.clear();
                                    signInPasswordController.clear();
                                    stackIndex = 1;
                                  });
                                },
                              style: TextStyle(
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.08,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton.extended(
                          onPressed: () async {
                            Map<String, dynamic> data = await FireBaseAuthHelper
                                .fireBaseAuthHelper
                                .signInAnonymously();
                            if (data['user'] != null) {
                              Get.snackbar(
                                "Success",
                                "SignIn Successfully...",
                                backgroundColor: Colors.green,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              Get.offNamed(
                                "/home_page",
                                arguments: data['user'],
                              );
                              signInController.signIn();
                            } else {
                              Get.snackbar(
                                "Failed",
                                data['msg'],
                                backgroundColor: Colors.redAccent,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          label: const Text("Guest"),
                          heroTag: null,
                          icon: const Icon(Icons.person),
                        ),
                        FloatingActionButton.extended(
                          onPressed: () async {
                            Map<String, dynamic> data = await FireBaseAuthHelper
                                .fireBaseAuthHelper
                                .signInWithGoogle(fcmToken: fcmToken!);
                            if (data['user'] != null) {
                              Get.snackbar(
                                "Success",
                                "SignIn Successfully...",
                                backgroundColor: Colors.green,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              Get.offNamed(
                                "/home_page",
                                arguments: data['user'],
                              );
                              signInController.signIn();
                            } else {
                              Get.snackbar(
                                "Failed",
                                data['msg'],
                                backgroundColor: Colors.redAccent,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          label: const Text("Google"),
                          heroTag: null,
                          icon: const Icon(Icons.person),
                        ),
                        FloatingActionButton.extended(
                          onPressed: () async {
                            Get.toNamed("/otp_page");
                          },
                          label: const Text("Phone"),
                          heroTag: null,
                          icon: const Icon(Icons.person),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Form(
            key: signUpFormKey,
            child: Padding(
              padding: EdgeInsets.all(height * 0.016),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: height * 0.03,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: height * 0.024,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    TextFormField(
                      controller: signUpEmailController,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) {
                        signUpEmail = val;
                      },
                      validator: (val) =>
                          (val!.isEmpty) ? "Enter email address.." : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Email",
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Text(
                      "Password",
                      style: TextStyle(
                        fontSize: height * 0.024,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    TextFormField(
                      controller: signUpPasswordController,
                      obscureText: true,
                      onSaved: (val) {
                        signUpPassword = val;
                      },
                      validator: (val) =>
                          (val!.isEmpty) ? "Enter password.." : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Password",
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontSize: height * 0.024,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    TextFormField(
                      controller: signUpConfirmPasswordController,
                      obscureText: true,
                      onSaved: (val) {
                        signUpConfirmPassword = val;
                      },
                      validator: (val) =>
                          (val!.isEmpty) ? "Enter confirm password.." : null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Confirm Password",
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (signUpFormKey.currentState!.validate()) {
                            signUpFormKey.currentState!.save();
                            if (signUpPassword != signUpConfirmPassword) {
                              Get.snackbar(
                                "Failed",
                                "Password and Confirm password not match..",
                                backgroundColor: Colors.redAccent,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Map<String, dynamic> data =
                                  await FireBaseAuthHelper.fireBaseAuthHelper
                                      .signUpWithEmailAndPassword(
                                          email: signUpEmail!,
                                          password: signUpPassword!);

                              if (data['user'] != null) {
                                Get.snackbar(
                                  "Success",
                                  "SignUp Successfully...",
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                stackIndex = 0;
                                signUpEmailController.clear();
                                signUpPasswordController.clear();
                                signUpConfirmPasswordController.clear();
                                setState(() {});
                              } else {
                                Get.snackbar(
                                  "Failed",
                                  data['msg'],
                                  backgroundColor: Colors.redAccent,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: height * 0.02,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account?",
                              style: TextStyle(
                                fontSize: height * 0.02,
                              ),
                            ),
                            TextSpan(
                              text: " Sign In",
                              recognizer: TapAndPanGestureRecognizer()
                                ..onTapUp = (details) {
                                  setState(() {
                                    signUpEmailController.clear();
                                    signUpPasswordController.clear();
                                    signUpConfirmPasswordController.clear();
                                    stackIndex = 0;
                                  });
                                },
                              style: TextStyle(
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
