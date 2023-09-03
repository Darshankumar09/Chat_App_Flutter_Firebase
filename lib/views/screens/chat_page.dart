import 'dart:developer';

import 'package:chat_app/utils/globals.dart';
import 'package:chat_app/helpers/firebase_auth_helper.dart';
import 'package:chat_app/helpers/firestore_helper.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatController = TextEditingController();

  String user1 = FireBaseAuthHelper.firebaseAuth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: FireStoreHelper.fireStoreHelper.connectionStatus(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DocumentSnapshot<Map<String, dynamic>>? data = snapshot.data;
              Map<String, dynamic>? nextUserData = data!.data();

              if (nextUserData != null) {
                return Text(
                  (nextUserData['isOnline'] ?? false) ? "Online" : "",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                );
              } else {
                return const Text("");
              }
            }
            return const Text("");
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: StreamBuilder(
              stream: allMessages,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  QuerySnapshot<Map<String, dynamic>> ss = snapshot.data;

                  List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                      ss.docs;

                  List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      allMessages = [];

                  for (var element in allDocs) {
                    if (element.data()[user1] == true) {
                      allMessages.add(element);
                    }
                  }

                  return (allMessages.isEmpty)
                      ? const Center(
                          child: Text("No Message available..."),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          reverse: true,
                          itemCount: allMessages.length,
                          itemBuilder: (context, index) {
                            DateTime timeStampFromDb = (allMessages[index]
                                        ['timeStamp'] ??
                                    Timestamp.fromDate(DateTime.now()))
                                .toDate();

                            DateTime timeStamp = DateFormat('dd/MM/yyyy, HH:mm')
                                .parse(
                                    '${timeStampFromDb.day}/${timeStampFromDb.month}/${timeStampFromDb.year}, ${timeStampFromDb.hour}:${timeStampFromDb.minute}');
                            String formattedTimeStamp =
                                DateFormat('hh:mm a').format(timeStamp);

                            if (allMessages[index]['fromUid'] ==
                                FireBaseAuthHelper.currentUser!.uid) {
                              return SwipeTo(
                                onRightSwipe: () {
                                  log("swipe");
                                },
                                iconOnRightSwipe: const IconData(
                                  0xe528,
                                  fontFamily: 'MaterialIcons',
                                ),
                                child: sendMessage(
                                  context: context,
                                  data: allMessages[index],
                                  formattedTimeStamp: formattedTimeStamp,
                                ),
                              );
                            } else {
                              return receivedMessage(
                                context: context,
                                data: allMessages[index],
                                formattedTimeStamp: formattedTimeStamp,
                              );
                            }
                          },
                        );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.012),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Enter message..",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      String msg = chatController.text;

                      if (msg.isNotEmpty) {
                        chatController.clear();
                        await FireStoreHelper.fireStoreHelper
                            .sendMessage(msg: msg);
                      }
                      chatController.clear();
                    },
                    child: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget sendMessage({
  required data,
  required String formattedTimeStamp,
  required BuildContext context,
}) {
  return GestureDetector(
    onLongPress: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete message?"),
            titleTextStyle: TextStyle(
              color: const Color(0xff686868),
              fontSize: height * 0.018,
            ),
            elevation: 0,
            actionsPadding: EdgeInsets.all(height * 0.01),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(height * 0.02),
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      Get.back();
                      await FireStoreHelper.fireStoreHelper
                          .deleteMessageForEveryone(
                        chatId: data.id,
                      );
                    },
                    child: Text(
                      "Delete for everyone",
                      style: TextStyle(
                        fontSize: height * 0.016,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff108654),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Get.back();
                      await FireStoreHelper.fireStoreHelper.deleteMessageForMe(
                        chatId: data.id,
                      );
                    },
                    child: Text(
                      "Delete for me",
                      style: TextStyle(
                        fontSize: height * 0.016,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff108654),
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
              ),
            ],
          );
        },
      );
    },
    child: BubbleSpecialThree(
      text: data['msg'],
      color: const Color(0xff108654),
      tail: false,
      isSender: true,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}

Widget receivedMessage({
  required data,
  required String formattedTimeStamp,
  required BuildContext context,
}) {
  return GestureDetector(
    onLongPress: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete message?"),
            titleTextStyle: TextStyle(
              color: const Color(0xff686868),
              fontSize: height * 0.018,
            ),
            elevation: 0,
            actionsPadding: EdgeInsets.all(height * 0.01),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(height * 0.02),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      Get.back();
                      await FireStoreHelper.fireStoreHelper.deleteMessageForMe(
                        chatId: data.id,
                      );
                    },
                    child: Text(
                      "Delete for me",
                      style: TextStyle(
                        fontSize: height * 0.016,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff108654),
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
              ),
            ],
          );
        },
      );
    },
    child: BubbleSpecialThree(
      text: data['msg'],
      color: Colors.black.withOpacity(0.6),
      tail: false,
      isSender: false,
      textStyle: const TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}
