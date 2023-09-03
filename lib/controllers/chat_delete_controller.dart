import 'package:chat_app/models/chat_delete_model.dart';
import 'package:get/get.dart';

class ChatDeleteController extends GetxController {
  ChatDeleteModel chatDeleteModel = ChatDeleteModel(alsoDelete: false);

  alsoDelete({required bool val}) {
    chatDeleteModel.alsoDelete = val;
    update();
  }
}
