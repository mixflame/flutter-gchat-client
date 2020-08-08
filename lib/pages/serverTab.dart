import 'package:shared_preferences/shared_preferences.dart';

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

showAlertDialog(BuildContext context, String title, String message) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class _ServerTabState extends State<ServerTab>
    with AutomaticKeepAliveClientMixin<ServerTab> {
  @override
  bool get wantKeepAlive => true;
  var hostText;
  var portText;
  var handleText;

  _savePrefs(String host, String port, String handle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('host', host);
    await prefs.setString('port', port.toString());
    await prefs.setString('handle', handle);
  }

  _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      host = prefs.getString("host");
      port = int.parse(prefs.getString("port") ?? "9994");
      handle = prefs.getString("handle");
      hostText = TextEditingController(text: host);
      portText = TextEditingController(text: port.toString());
      handleText = TextEditingController(text: handle);
    });
  }

  @override
  void initState() {
    super.initState();
    //Global Variables gets initiated.
    _loadPrefs();
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
            controller: handleText,
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
            controller: hostText,
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
            controller: portText,
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
              _savePrefs(host, port.toString(), handle);
              setState(() {
                gdraw = GDraw(context: context);
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
