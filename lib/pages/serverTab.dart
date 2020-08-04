// import 'package:draw/event/event.dart';
import 'package:draw/draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:draw/gdraw.dart';
// import '../bloc/serverBloc.dart';

String host;
int port;
String password;
String handle;

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
          Text("Handle"),
          TextField(
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) => {
              setState(() {
                handle = value;
              })
            },
          ),
          Text("Hostname"),
          TextField(
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) => {
              setState(() {
                host = value;
              })
            },
          ),
          Text("Port"),
          TextField(
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            onChanged: (value) => {
              setState(() {
                port = int.parse(value);
              })
            },
          ),
          Text("Password"),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
            onChanged: (value) => {
              setState(() {
                password = value;
              })
            },
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                // serverBloc.sink(ServerConnectEvent());
                gdraw = GDraw();
                gdraw.host = host;
                gdraw.port = port;
                gdraw.handle = handle;
                gdraw.password = password;
                gdraw.start();
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
