import 'package:chat_app/utils/globals.dart';
import 'package:chat_app/utils/helpers/firebase_auth_helper.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
                                          ['timeStamp'] ??
                                      Timestamp.fromDate(DateTime.now()))
                                  .toDate();

                              DateTime timeStamp =
                                  DateFormat('dd/MM/yyyy, HH:mm').parse(
                                      '${timeStampFromDb.day}/${timeStampFromDb.month}/${timeStampFromDb.year}, ${timeStampFromDb.hour}:${timeStampFromDb.minute}');
                              String formattedTimeStamp =
                                  DateFormat('hh:mm a').format(timeStamp);

                              if (allMessages[index]['fromUid'] ==
                                  FireBaseAuthHelper.currentUser!.uid) {
                                return sendMessage(
                                  data: allMessages[index],
                                  chatDocId:
                                      FireStoreHelper.chatDocId.toString(),
                                  chatId: allMessages[index].id,
                                  formattedTimeStamp: formattedTimeStamp,
                                );
                              } else {
                                return receivedMessage(
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
                        await FireStoreHelper.fireStoreHelper.sendChatMessage(
                          id: FireStoreHelper.chatDocId.toString(),
                          msg: msg,
                        );
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
  required String chatId,
  required String formattedTimeStamp,
}) {
  return Align(
    alignment: Alignment.centerRight,
    child: GestureDetector(
      onLongPress: () {
        Get.dialog(
          CupertinoAlertDialog(
            title: const Text("Delete Message"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Delete"),
                onPressed: () async {
                  Get.back();
                  await FireStoreHelper.fireStoreHelper.deleteMessage(
                    chatDocId: chatDocId,
                    chatId: chatId,
                  );
                },
              ),
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
      child: ConstrainedBox(
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
    ),
  );
}

Widget receivedMessage({
  required data,
  required String formattedTimeStamp,
}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: ConstrainedBox(
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
  );
}
