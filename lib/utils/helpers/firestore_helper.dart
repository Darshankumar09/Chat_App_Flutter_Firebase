import 'package:chat_app/utils/helpers/firebase_auth_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  FireStoreHelper._();

  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static String? toUid;
  static String? chatDocId;

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

  Future createDocumentInChatroom() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await db.collection("chatroom").get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = snapshot.docs;

    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    List<Map<String, dynamic>> userDetails = [
      {
        "first_user": user1,
      },
      {
        "second_user": user2,
      }
    ];

    bool documentExists = false;

    for (var element in allDocs) {
      String docId = element.id;
      List<String> splitList = docId.split("_");
      String u1 = splitList[0];
      String u2 = splitList[1];

      if ((u1 == user1 || u1 == user2) && (u2 == user1 || u2 == user2)) {
        documentExists = true;
        chatDocId = element.id;
        break;
      }
    }
    if (documentExists == false) {
      chatDocId = "${user1}_$user2";
      await db
          .collection("chatroom")
          .doc(chatDocId)
          .set({"UserDetails": FieldValue.arrayUnion(userDetails)});
    }
  }

  Future<void> sendChatMessage(
      {required String id, required String msg}) async {
    await db.collection("chatroom").doc(id).collection("chat").add({
      "msg": msg,
      "fromUid": FireBaseAuthHelper.currentUser!.uid,
      "toUid": toUid,
      "timeStamp": FieldValue.serverTimestamp(),
    });
  }

  Future<Stream> displayAllMessages() async {
    await createDocumentInChatroom();
    Stream<QuerySnapshot<Map<String, dynamic>>> userChat = db
        .collection("chatroom")
        .doc(chatDocId)
        .collection("chat")
        .orderBy("timeStamp", descending: true)
        .snapshots();

    return userChat;
  }

  Future<void> deleteMessage(
      {required String chatDocId, required String chatId}) async {
    await db
        .collection('chatroom')
        .doc(chatDocId)
        .collection('chat')
        .doc(chatId)
        .delete();
  }
}
