import 'package:chat_app/utils/globals.dart';
import 'package:chat_app/utils/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    QueryDocumentSnapshot<Map<String, dynamic>> data = ModalRoute.of(context)!
        .settings
        .arguments as QueryDocumentSnapshot<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: SizedBox(
              child: StreamBuilder(
                stream: FireStoreHelper.fireStoreHelper
                    .displayAllMessages(id: data.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error : ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData) {
                    QuerySnapshot<Map<String, dynamic>> data = snapshot.data;

                    List<QueryDocumentSnapshot<Map<String, dynamic>>>
                        allMessages = data.docs;

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      itemCount: allMessages.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text("${allMessages[index].data()['message']}"),
                      ),
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
                      await FireStoreHelper.fireStoreHelper.sendChatMessage(
                        id: data.id,
                        msg: chatController.text,
                      );
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
