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

  Future<void> deleteMessageForMe({required String chatId}) async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    await db
        .collection('chatroom')
        .doc(chatDocId)
        .collection("messages")
        .doc(chatId)
        .delete();
  }

  Future<void> deleteMessageForEveryone({required String chatId}) async {
    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    await db
        .collection('chatroom')
        .doc(chatDocId)
        .collection("messages")
        .doc(chatId)
        .delete();
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
    final FieldValue timeStamp = FieldValue.serverTimestamp();

    Map<String, dynamic> msgMap = {
      "msg": msg,
      "fromUid": user1,
      "toUid": user2,
      "timeStamp": timeStamp,
    };

    await db
        .collection("chatroom")
        .doc(chatDocId)
        .collection("messages")
        .add({user1: msgMap, user2: msgMap});
  }

  Future<Stream> displayAllMessages() async {
    await createChatDocument();

    String user1 = FireBaseAuthHelper.currentUser!.uid;
    String user2 = toUid!;

    Stream<QuerySnapshot<Map<String, dynamic>>> userChat = db
        .collection("chatroom")
        .doc(chatDocId)
        .collection("messages")
        .snapshots();

    return userChat;
  }
}
