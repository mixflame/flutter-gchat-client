import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:convert' show utf8;

import 'package:flutter/cupertino.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:rxdart/rxdart.dart';
import 'pages/homepage.dart';
import 'draw_screen.dart';
import 'pages/serverTab.dart';
import 'main.dart';

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
  BuildContext context;
  GDraw({this.context});

  Socket sock;
  final subject = BehaviorSubject<GMessage>();
  String serverPublicKey;
  var ourKeyPair = Sodium.cryptoBoxKeypair();
  String token;
  Map<String, Function> handlers = Map<String, Function>();

  var buf = "";

  String host;
  int port;
  String handle;
  String password; // plaintext password

  String server_name;

  int canvasSizeX;
  int canvasSizeY = 0;
  int totalPoints;

  Draw draw;

  void start() {
    registerProtocolHandler("ALERT", (msg) {
      var message = msg.arguments[0];
      showAlertDialog(context, "Server Alert", message);
      homekey.currentState.tabController.animateTo(0);
    });

    registerProtocolHandler("CANVAS", (msg) {
      var sizeArr = msg.arguments[0].split("x");
      canvasSizeX = int.parse(sizeArr[0]);
      canvasSizeY = int.parse(sizeArr[1]);
      totalPoints = int.parse(msg.arguments[1]);
    });

    registerProtocolHandler("POINT", (msg) {
      var parr = msg.arguments;
      double x = double.tryParse(parr[0]);
      double y = double.tryParse(parr[1]);

      if (x == null || y == null) {
        return;
      }

      Offset position = convertSwiftPointToFlutterPoint(Offset(x, y));
      bool dragging = parr[2] == "true" ? true : false;
      int red = (double.tryParse(parr[3]) * 255.0).round();
      int green = (double.tryParse(parr[4]) * 255.0).round();
      int blue = (double.tryParse(parr[5]) * 255.0).round();

      double opacity = double.tryParse(parr[6]);
      double width = double.tryParse(parr[7]);
      String clickName = parr[8];

      Color color = Color.fromRGBO(red, green, blue, opacity);

      drawkey.currentState
          .addClick(position, dragging, color, width, clickName);
    });

    registerProtocolHandler("TOKEN", (GMessage msg) {
      token = msg.arguments[0];
      handle = msg.arguments[1];
      server_name = msg.arguments[2];
      homekey.currentState.setIgnoringFalse();
      homekey.currentState.tabController.animateTo(1);
    });

    registerProtocolHandler("KEY", (GMessage msg) {
      serverPublicKey = msg.arguments[0].trim();
      if (password != "" && password != null) {
        List<int> passwordBytes = utf8.encode(password);
        var encryptedPassword =
            Sodium.cryptoBoxSeal(passwordBytes, base64Decode(serverPublicKey));
        var passwordB64 = base64Encode(encryptedPassword);
        send(GMessage("SIGNON", [handle, passwordB64]));
      } else {
        send(GMessage("SIGNON", [handle]));
      }
    });

    registerProtocolHandler("SAY", (GMessage msg) {
      var pk = ourKeyPair.pk;
      var ciphertext = base64.normalize(msg.arguments[1]);
      List<int> messageBytes = base64Decode(ciphertext);
      var handle = msg.arguments[0];
      var decryptedText =
          Sodium.cryptoBoxSealOpen(messageBytes, pk, ourKeyPair.sk);
      var message = utf8.decode(decryptedText);

      chatkey.currentState.addMessage(handle, message);
    });

    // gdraw.registerProtocolHandler("ENDPOINTS", (msg) {});

    Socket.connect(host, port).then((Socket _sock) {
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

      send(GMessage("KEY", [base64Encode(ourKeyPair.pk)]));
      // showAlertDialog(context, "connected to globalchat server", "connected.");
    }).catchError((e) {
      print("unable to connect: $e");
      // showAlertDialog(context, "failed to connect", "connection failed.");
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
    String out = msg.toString();
    print("Client: $out");
    sock.write(out);
  }

  void registerProtocolHandler(
      String command, Null Function(GMessage msg) handler) {
    handlers[command] = handler;
  }

  void sendPoint(
      Offset pout, bool dragging, Color color, double width, String handle) {
    double x = pout.dx;
    double y = pout.dy;
    List<String> point = List();
    point.add(x.toString());
    point.add(y.toString());
    point.add(dragging.toString());
    point.add((color.red / 255.0).toString());
    point.add((color.green / 255.0).toString());
    point.add((color.blue / 255.0).toString());
    point.add(color.opacity.toString());
    point.add(width.toString());
    point.add(token);
    send(GMessage("POINT", point));
  }

  void setHost(String s) {
    this.host = s;
  }

  void setPort(int i) {
    this.port = i;
  }

  void setHandle(String s) {
    this.handle = s;
  }
}
