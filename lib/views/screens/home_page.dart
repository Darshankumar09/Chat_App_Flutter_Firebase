import 'package:chat_app/controllers/signIn_controller.dart';
import 'package:chat_app/utils/globals.dart';
import 'package:chat_app/utils/helpers/firebase_auth_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SignInController signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    User? userData = ModalRoute.of(context)!.settings.arguments as User?;

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
                  ? NetworkImage(userData.photoURL!)
                  : const AssetImage("assets/images/user.png")
                      as ImageProvider?,
            ),
            SizedBox(
              height: height * 0.03,
            ),
            Text("Email : ${userData.email}"),
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
      appBar: AppBar(),
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

            Set<String> uniqueSet = {};
            List<QueryDocumentSnapshot<Map<String, dynamic>>> uniqueList =
                allDocs.where((e) => uniqueSet.add(e.data()['uid'])).toList();

            List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = [];
            for (int i = 0; i < uniqueList.length; i++) {
              if (userData!.uid != uniqueList[i].data()['uid']) {
                documents.add(uniqueList[i]);
              }
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  Get.toNamed("/chat_page", arguments: documents[index]);
                },
                child: ListTile(
                  leading: Text("${index + 1}"),
                  title: Text(documents[index].data()['email']),
                  subtitle: Text(documents[index].data()['uid']),
                ),
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
