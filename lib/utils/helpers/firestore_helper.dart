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

  Future<void> deleteMessageForMe({required String chatDocId}) async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    await db
        .collection('chatroom')
        .doc(user1)
        .collection("${user1}_$user2")
        .doc(chatDocId)
        .delete();
  }

  Future<void> deleteMessageForEveryone({required String chatDocId}) async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    await db
        .collection('chatroom')
        .doc(user1)
        .collection("${user1}_$user2")
        .doc(chatDocId)
        .delete();

    await db
        .collection('chatroom')
        .doc(user2)
        .collection("${user2}_$user1")
        .doc(chatDocId)
        .delete();
  }

  Future<int> sendMessageId() async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;
    int msgId = 1;

    DocumentSnapshot<Map<String, dynamic>> chatRecords = await db
        .collection("chat_records")
        .doc(user1)
        .collection("${user1}_$user2")
        .doc("records")
        .get();

    Map<String, dynamic>? records = chatRecords.data();

    if (records == null) {
      await db
          .collection("chat_records")
          .doc(user1)
          .collection("${user1}_$user2")
          .doc("records")
          .set({"msgId": msgId});

      await db
          .collection("chat_records")
          .doc(user2)
          .collection("${user2}_$user1")
          .doc("records")
          .set({"msgId": msgId});
    } else {
      msgId = records['msgId'];
      await db
          .collection("chat_records")
          .doc(user1)
          .collection("${user1}_$user2")
          .doc("records")
          .update({"msgId": ++msgId});

      await db
          .collection("chat_records")
          .doc(user2)
          .collection("${user2}_$user1")
          .doc("records")
          .update({"msgId": msgId});
    }
    return msgId;
  }

  Future<void> sendMessage({required String msg}) async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;
    // int msgId = await sendMessageId();
    final FieldValue timeStamp = FieldValue.serverTimestamp();

    Map<String, dynamic> msgMap = {
      "msg": msg,
      "fromUid": user1,
      "toUid": user2,
      "timeStamp": timeStamp,
    };

    await db
        .collection("chatroom")
        .doc(user1)
        .collection("${user1}_$user2")
        .add({user1: msgMap, user2: msgMap});
  }

  Future<Stream> displayAllMessages() async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    Stream<QuerySnapshot<Map<String, dynamic>>> userChat = db
        .collection("chatroom")
        .doc(user1)
        .collection("${user1}_$user2")
        .orderBy("timeStamp", descending: true)
        .snapshots();

    return userChat;
  }
}
