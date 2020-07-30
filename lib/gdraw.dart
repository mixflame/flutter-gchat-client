import 'dart:convert';
import 'dart:io';

import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:rxdart/rxdart.dart';

class GMessage {
  String command = "";
  List<String> arguments = [];

  GMessage(this.command, this.arguments);

  String toString() {
    return command + "::!!::" + arguments.join("::!!::") + "\x00";
  }

  static GMessage fromString(String line) {
    var arr = line.split("::!!::");
    return new GMessage(arr[0], arr.sublist(1));
  }
}

class GDraw {
  Socket sock;
  final subject = BehaviorSubject<GMessage>();
  String serverPublicKey;
  var ourKeyPair = Sodium.cryptoBoxKeypair();
  String token;
  Map<String, Function> handlers = Map<String, Function>();

  var buf = "";

  void start() {
    Socket.connect("64.225.115.44", 9617).then((Socket _sock) {
      sock = _sock;
      sock.listen(handleData, onError: (error, StackTrace trace) {
        print(error);
      }, onDone: () {
        print("destroy socket");
        sock.destroy();
      }, cancelOnError: false);

      subject.listen((value) {
        print("Server: $value");
        String command = value.command;
        Function handler = handlers[value.command];
        if (handler != null) {
          handler(value);
        } else {
          print("WARNING: No handler defined for command $command");
        }
      });

      registerProtocolHandler("TOKEN", (GMessage msg) {
        token = msg.arguments[0];
      });

      registerProtocolHandler("KEY", (GMessage msg) {
        serverPublicKey = msg.arguments[0];
      });

      send(GMessage("KEY", [base64Encode(ourKeyPair.pk)]));
      send(GMessage("SIGNON", ["flutter"]));
    }).catchError((e) {
      print("unable to connect: $e");
    });
  }

  void handleData(data) {
    for (var i = 0; i < data.length; i++) {
      var char = String.fromCharCode(data[i]);
      if (char == "\x00") {
        if (buf.length > 0) {
          subject.add(GMessage.fromString(buf));
        }
        buf = "";
      } else {
        buf += char;
      }
    }
  }

  void send(GMessage msg) {
    print("Client: $msg");
    sock.write(msg.toString());
  }

  void registerProtocolHandler(
      String command, Null Function(GMessage msg) handler) {
    handlers[command] = handler;
  }
}
