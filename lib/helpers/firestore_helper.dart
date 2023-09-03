import 'package:chat_app/helpers/firebase_auth_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  FireStoreHelper._();

  static final FireStoreHelper fireStoreHelper = FireStoreHelper._();
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static String? toUid;
  static String? chatDocId;
  static String? nextUserDocumentId;

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

  Future<void> createChatDocument() async {
    String uid1 = FireBaseAuthHelper.currentUser!.uid;
    String uid2 = toUid!;

    String user1 = "${uid1}_$uid2";
    String user2 = "${uid2}_$uid1";
    bool chatDocExists = false;

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await db.collection("chatroom").get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> chatDocList =
        snapshot.docs;

    if (chatDocList.isNotEmpty) {
      for (var element in chatDocList) {
        if (element.id == user1 || element.id == user2) {
          chatDocExists = true;
          chatDocId = element.id;
          break;
        } else {
          chatDocId = user1;
        }
      }

      if (chatDocExists == false) {
        await db.collection("chatroom").doc(user1).set({
          "users": [uid1, uid2]
        });
      }
    } else {
      chatDocId = user1;

      await db.collection("chatroom").doc(user1).set({
        "users": [uid1, uid2]
      });
    }
  }

  Future<void> sendMessage({required String msg}) async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    Map<String, dynamic> msgMap = {
      "msg": msg,
      "fromUid": user1,
      "toUid": user2,
      "timeStamp": FieldValue.serverTimestamp(),
      user1: true,
      user2: true,
    };

    await db
        .collection("chatroom")
        .doc(chatDocId)
        .collection("messages")
        .add(msgMap);
  }

  Future<Stream> displayAllMessages() async {
    await createChatDocument();

    Stream<QuerySnapshot<Map<String, dynamic>>> userChat = db
        .collection("chatroom")
        .doc(chatDocId)
        .collection("messages")
        .orderBy("timeStamp", descending: true)
        .snapshots();

    return userChat;
  }

  Future<void> deleteMessageForMe({required String chatId}) async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    await db
        .collection('chatroom')
        .doc(chatDocId)
        .collection("messages")
        .doc(chatId)
        .update({user1: false});

    DocumentSnapshot<Map<String, dynamic>> message = await db
        .collection("chatroom")
        .doc(chatDocId)
        .collection("messages")
        .doc(chatId)
        .get();

    if ((message.data()![user1] == false) &&
        (message.data()![user2] == false)) {
      await db
          .collection('chatroom')
          .doc(chatDocId)
          .collection("messages")
          .doc(chatId)
          .delete();
    }
  }

  Future<void> deleteMessageForEveryone({required String chatId}) async {
    await db
        .collection('chatroom')
        .doc(chatDocId)
        .collection("messages")
        .doc(chatId)
        .delete();
  }

  Future<void> deleteChatForMe() async {
    String uid1 = FireBaseAuthHelper.currentUser!.uid;
    String uid2 = toUid!;
    final batch = db.batch();

    await createChatDocument();

    QuerySnapshot<Map<String, dynamic>> ss =
        await db.collection('chatroom/$chatDocId/messages').get();

    for (var doc in ss.docs) {
      (doc.data()[uid2] == false)
          ? batch.delete(doc.reference)
          : batch.update(doc.reference, {uid1: false});
    }

    await batch.commit();
  }

  Future<void> deleteChatForBoth() async {
    await createChatDocument();
    final batch = db.batch();

    QuerySnapshot<Map<String, dynamic>> ss =
        await db.collection('chatroom/$chatDocId/messages').get();

    for (var doc in ss.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future updateUserConnectivity(
      {String? userDocId, required bool status}) async {
    await db.collection("users").doc(userDocId).update({"isOnline": status});
  }

  Future nextUserDocId() async {
    QuerySnapshot<Map<String, dynamic>> collectionSnapShot =
        await db.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> data =
        collectionSnapShot.docs;

    for (var element in data) {
      if (element['uid'] == toUid) {
        nextUserDocumentId = element.id;
        break;
      }
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> connectionStatus() {
    Stream<DocumentSnapshot<Map<String, dynamic>>> data =
        db.collection("users").doc(nextUserDocumentId).snapshots();

    return data;
  }
}
