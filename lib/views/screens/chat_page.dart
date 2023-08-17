import 'package:chat_app/utils/globals.dart';
import 'package:chat_app/utils/helpers/firebase_auth_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatController = TextEditingController();
  String user1 = FireBaseAuthHelper.firebaseAuth.currentUser!.uid;
  String user2 = FireStoreHelper.toUid!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: SizedBox(
              child: StreamBuilder(
                stream: allMessages,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error : ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    QuerySnapshot<Map<String, dynamic>> data = snapshot.data;

                    List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        allMessages = data.docs;

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
                                          [user1]['timeStamp'] ??
                                      Timestamp.fromDate(DateTime.now()))
                                  .toDate();

                              DateTime timeStamp =
                                  DateFormat('dd/MM/yyyy, HH:mm').parse(
                                      '${timeStampFromDb.day}/${timeStampFromDb.month}/${timeStampFromDb.year}, ${timeStampFromDb.hour}:${timeStampFromDb.minute}');
                              String formattedTimeStamp =
                                  DateFormat('hh:mm a').format(timeStamp);

                              if (allMessages[index][user1]['fromUid'] ==
                                  FireBaseAuthHelper.currentUser!.uid) {
                                return sendMessage(
                                  context: context,
                                  data: allMessages[index][user1],
                                  chatDocId: allMessages[index].id,
                                  formattedTimeStamp: formattedTimeStamp,
                                );
                              } else {
                                return receivedMessage(
                                  context: context,
                                  data: allMessages[index][user2],
                                  chatDocId: allMessages[index].id,
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
  required String chatDocId,
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
                        chatId: chatDocId,
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
                        chatId: chatDocId,
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
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width * 0.85,
            minHeight: height * 0.045,
          ),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(height * 0.01),
            ),
            color: const Color(0xff108654),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 80,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Text(
                    data['msg'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Row(
                    children: [
                      Text(
                        formattedTimeStamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      const Icon(
                        Icons.done_all,
                        size: 14,
                        color: Color(0xff00d4ff),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget receivedMessage({
  required data,
  required String chatDocId,
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
                        chatId: chatDocId,
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
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width * 0.85,
            minHeight: height * 0.045,
          ),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(height * 0.01),
            ),
            color: Colors.black.withOpacity(0.6),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 66,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Text(
                    data['msg'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Row(
                    children: [
                      Text(
                        formattedTimeStamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
