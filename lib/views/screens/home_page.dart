import 'package:chat_app/controllers/chat_delete_controller.dart';
import 'package:chat_app/controllers/signIn_controller.dart';
import 'package:chat_app/helpers/firebase_auth_helper.dart';
import 'package:chat_app/helpers/firestore_helper.dart';
import 'package:chat_app/utils/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  SignInController signInController = Get.find<SignInController>();

  ChatDeleteController chatDeleteController = Get.put(ChatDeleteController());
  User? userData = FireBaseAuthHelper.currentUser;
  String? userDocId = getStorage.read("userDocId");

  @override
  void initState() {
    super.initState();
    FireStoreHelper.fireStoreHelper.updateUserConnectivity(
      userDocId: userDocId,
      status: true,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      FireStoreHelper.fireStoreHelper.updateUserConnectivity(
        userDocId: userDocId,
        status: true,
      );
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      FireStoreHelper.fireStoreHelper.updateUserConnectivity(
        userDocId: userDocId,
        status: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.08,
            ),
            CircleAvatar(
              radius: height * 0.09,
              foregroundImage: (userData!.photoURL != null)
                  ? NetworkImage(userData!.photoURL!)
                  : const AssetImage("assets/images/user.png")
                      as ImageProvider?,
            ),
            SizedBox(
              height: height * 0.03,
            ),
            Text("Email : ${userData!.email}"),
            SizedBox(
              height: height * 0.03,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: height * 0.02,
                  ),
                ),
                SizedBox(
                  width: width * 0.05,
                ),
                IconButton(
                  onPressed: () async {
                    await FireBaseAuthHelper.fireBaseAuthHelper.signOut();
                    signInController.signOut();
                    Get.offNamedUntil("/login_page", (route) => false);
                  },
                  icon: const Icon(Icons.logout_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await FireBaseAuthHelper.fireBaseAuthHelper.deleteUser();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FireStoreHelper.fireStoreHelper.displayAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error : ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            QuerySnapshot<Map<String, dynamic>> data =
                snapshot.data as QuerySnapshot<Map<String, dynamic>>;

            List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                data.docs;

            List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = [];

            for (int i = 0; i < allDocs.length; i++) {
              if (userData!.uid != allDocs[i].data()['uid']) {
                documents.add(allDocs[i]);
              }
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) => ListTile(
                onLongPress: () {
                  FireStoreHelper.toUid = documents[index].data()['uid'];
                  chatDeleteController.chatDeleteModel.alsoDelete = false;
                  chatDeleteDialog(
                    context: context,
                    chatDeleteController: chatDeleteController,
                  );
                },
                onTap: () async {
                  FireStoreHelper.toUid = documents[index].data()['uid'];
                  allMessages = await FireStoreHelper.fireStoreHelper
                      .displayAllMessages();
                  Get.toNamed("/chat_page");
                  await FireStoreHelper.fireStoreHelper.nextUserDocId();
                },
                leading: Text("${index + 1}"),
                title: Text(documents[index].data()['email']),
                subtitle: Text(documents[index].data()['uid']),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

chatDeleteDialog({
  required BuildContext context,
  required ChatDeleteController chatDeleteController,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete chat"),
        titleTextStyle: TextStyle(
          color: const Color(0xff686868),
          fontSize: height * 0.018,
        ),
        elevation: 0,
        actionsPadding: EdgeInsets.all(height * 0.01),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height * 0.02),
        ),
        content: Row(
          children: [
            GetBuilder<ChatDeleteController>(builder: (context) {
              return Checkbox(
                  value: chatDeleteController.chatDeleteModel.alsoDelete,
                  onChanged: (val) {
                    chatDeleteController.alsoDelete(val: val!);
                  });
            }),
            Text(
              "Also delete for opposite user?",
              style: TextStyle(
                fontSize: height * 0.016,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (chatDeleteController.chatDeleteModel.alsoDelete) {
                Get.back();
                await FireStoreHelper.fireStoreHelper.deleteChatForBoth();
              } else {
                Get.back();
                await FireStoreHelper.fireStoreHelper.deleteChatForMe();
              }
            },
            child: Text(
              "Delete chat",
              style: TextStyle(
                fontSize: height * 0.016,
                fontWeight: FontWeight.w500,
                color: const Color(0xffd10000),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: height * 0.016,
                fontWeight: FontWeight.w500,
                color: const Color(0xff108654),
              ),
            ),
          ),
        ],
      );
    },
  );
}
