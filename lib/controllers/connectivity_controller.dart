import 'package:chat_app/models/connectivity_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  Connectivity connectivity = Connectivity();

  ConnectivityModel connectivityModel =
      ConnectivityModel(connectivityStatus: false);

  checkConnectivity() {
    connectivityModel.connectivityStream = connectivity.onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) {
      switch (connectivityResult) {
        case ConnectivityResult.mobile:
          connectivityModel.connectivityStatus = true;
          update();
          break;
        case ConnectivityResult.wifi:
          connectivityModel.connectivityStatus = true;
          update();
          break;
        case ConnectivityResult.ethernet:
          connectivityModel.connectivityStatus = true;
          update();
          break;
        default:
          connectivityModel.connectivityStatus = false;
          update();
          break;
      }
    });
  }
}
