import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin<ChatScreen> {
  String chatText = "";
  List<Text> textChildren;
  List<String> chat_buffer = [];

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  sendMessage() {
    print("get textfield and send contents");
  }

  addMessage(handle, message) {
    setState(() {
      chat_buffer.add("$handle: $message");
    });
  }

  _buildListItem(String message, BuildContext context, int index) {
    return Card(
        child: GestureDetector(onTap: () {}, child: Text(message ?? "")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext ctxt, int index) {
                return _buildListItem(chat_buffer[index], ctxt, index);
              },
              itemCount: chat_buffer.length,
            ),
          ),
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
