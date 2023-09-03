import 'dart:async';

class ConnectivityModel {
  bool connectivityStatus;
  StreamSubscription? connectivityStream;

  ConnectivityModel({
    required this.connectivityStatus,
    this.connectivityStream,
  });
}
