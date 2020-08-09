import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  String chatText = "";
  List<Text> textChildren;

  @override
  void initState() {
    super.initState();
  }

  sendMessage() {
    print("get textfield and send contents");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(chatText),
          TextField(),
          RaisedButton(
            onPressed: () => sendMessage(),
            child: Text("Send"),
          )
        ],
      ),
    );
  }
}
