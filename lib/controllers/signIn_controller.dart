import 'package:chat_app/models/signIn_model.dart';
import 'package:chat_app/utils/globals.dart';
import 'package:get/get.dart';

class SignInController extends GetxController {
  SignInModel signInModel = SignInModel(isSignIn: false);

  signIn() {
    signInModel.isSignIn = true;

    getStorage.write("isSignIn", signInModel.isSignIn);
    update();
  }

  signOut() {
    signInModel.isSignIn = false;

    getStorage.write("isSignIn", signInModel.isSignIn);
    update();
  }
}
