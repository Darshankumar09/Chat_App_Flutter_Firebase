import 'package:chat_app/utils/helpers/firebase_auth_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  FireStoreHelper._();

  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future insertWhileSignIn({required Map<String, dynamic> data}) async {
    DocumentSnapshot<Map<String, dynamic>> docSnapShot =
        await db.collection("records").doc("users").get();

    Map<String, dynamic> res = docSnapShot.data() as Map<String, dynamic>;

    int id = res['id'];
    int length = res['length'];

    await db.collection("users").doc("${++id}").set(data);

    await db
        .collection("records")
        .doc("users")
        .update({'id': id, 'length': ++length});
  }

  Stream displayAllUsers() {
    Stream<QuerySnapshot<Map<String, dynamic>>> userData =
        db.collection("users").snapshots();

    return userData;
  }

  Future<void> sendChatMessage(
      {required String id, required String msg}) async {
    await db.collection("users").doc(id).collection("chat").add({
      "message": msg,
      "fromId": FireBaseAuthHelper.currentUser.uid,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Stream displayAllMessages({required String id}) {
    Stream<QuerySnapshot<Map<String, dynamic>>> userChat =
        db.collection("users").doc(id).collection("chat").snapshots();

    return userChat;
  }
}
