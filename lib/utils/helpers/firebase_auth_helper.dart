import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FireBaseAuthHelper {
  FireBaseAuthHelper._();

  static final FireBaseAuthHelper fireBaseAuthHelper = FireBaseAuthHelper._();
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();
  static final User currentUser = firebaseAuth.currentUser!;
  static String verify = "";

  Future<Map<String, dynamic>> signInAnonymously() async {
    Map<String, dynamic> data = {};

    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();

      User? user = userCredential.user;

      data['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          data['msg'] = "This service temporarily not available..";
          break;
        case "network-request-failed":
          data['msg'] = "Internet connection not available..";
          break;
        default:
          data["msg"] = e.code;
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> phoneAuthentication(
      {required String phoneNumber}) async {
    Map<String, dynamic> data = {};

    firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        switch (error.code) {
          case "invalid-phone-number":
            data['msg'] = "Enter valid phone number..";
            break;
          default:
            data['msg'] = error.code;
            break;
        }
      },
      codeSent: (verificationId, forceResendingToken) async {
        verify = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
    return data;
  }

  Future<Map<String, dynamic>> otpVerification(
      {required String smsCode}) async {
    Map<String, dynamic> data = {};
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verify,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      User? user = userCredential.user;

      data['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-verification-code":
          data['msg'] = "Please enter valid otp";
          break;
        default:
          data['msg'] = e.code;
          break;
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    Map<String, dynamic> data = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      data['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          data['msg'] = "This service temporarily not available..";
          break;
        case "network-request-failed":
          data['msg'] = "Internet connection not available..";
          break;
        case "email-already-in-use":
          data['msg'] = "This E-mail address already in use..";
          break;
        case "invalid-email":
          data['msg'] = "Enter valid email address..";
          break;
        case "weak-password":
          data['msg'] = "Password length must be greater than 6 characters..";
          break;
        default:
          data["msg"] = e.code;
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      {required String email,
      required String password,
      required String fcmToken}) async {
    Map<String, dynamic> data = {};

    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      data['user'] = user;
      Map<String, dynamic> userData = {
        'email': user!.email,
        'uid': user.uid,
        'fcm-token': fcmToken,
      };

      await FireStoreHelper.fireStoreHelper.insertWhileSignIn(data: userData);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          data['msg'] = "This service temporarily not available..";
          break;
        case "user-not-found":
          data['msg'] = "Account does not exist or deleted..";
          break;
        case "wrong-password":
          data['msg'] = "The password you entered is incorrect..";
          break;
        case "network-request-failed":
          data['msg'] = "Internet connection not available..";
          break;
        case "user-disabled":
          data['msg'] = "User Disabled, contact admin..";
          break;
        default:
          data["msg"] = e.code;
      }
    }
    return data;
  }

  Future<Map<String, dynamic>> signInWithGoogle(
      {required String fcmToken}) async {
    Map<String, dynamic> data = {};

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);

      User? user = userCredential.user;

      data['user'] = user;
      Map<String, dynamic> userData = {
        'email': user!.email,
        'uid': user.uid,
        'fcm-token': fcmToken,
      };

      await FireStoreHelper.fireStoreHelper.insertWhileSignIn(data: userData);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          data['msg'] = "This service temporarily not available..";
          break;
        case "network-request-failed":
          data['msg'] = "Internet connection not available..";
          break;
        case "user-disabled":
          data['msg'] = "User Disabled, contact admin..";
          break;
        default:
          data["msg"] = e.code;
      }
    }
    return data;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}
