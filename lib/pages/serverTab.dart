import 'package:draw/event/event.dart';
import 'package:flutter/material.dart';

import '../bloc/serverBloc.dart';

class ServerTab extends StatefulWidget {
  //Tab 2
  @override
  _ServerTabState createState() => _ServerTabState();
}

class _ServerTabState extends State<ServerTab> {
  @override
  void initState() {
    super.initState();
    //Global Variables gets initiated.
    //myName = 'Bruce Wayne';
    //myImagePath = 'assets/images/bruce.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 45),
      child: Column(
        children: <Widget>[
          SizedBox(height: 30),
          RaisedButton(
            onPressed: () {
              setState(() {
                serverBloc.sink(ServerConnectEvent());
              });
            },
            child: Text('Connect'),
            elevation: 0,
          )
        ],
      ),
    );
  }
}
