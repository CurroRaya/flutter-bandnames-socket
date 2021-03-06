import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus{
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier {
  
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;


  SocketService(){
    this._initConfig();
  }

  void _initConfig(){
    // Dart client
    this._socket = IO.io('http://192.168.1.33:3000',
         IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .enableAutoConnect()
            .build());

    this._socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    
    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    /* this._socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje:');
      print('nombre:' + payload['nombre']);
      print('mensaje:' + payload['mensaje']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : "no viene mensaje2");
      notifyListeners();
    }); */
  }

}