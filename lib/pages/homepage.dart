import 'package:draw/pages/serverTab.dart';
import 'package:flutter/material.dart';
import '../draw_screen.dart';
import '../chat_screen.dart';

final drawkey = new GlobalKey<DrawState>();

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  bool ignoring;

  setIgnoringFalse() {
    setState(() {
      ignoring = false;
    });
  }

  @override
  void initState() {
    super.initState();

    ignoring = true;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      //Default tab controller wraps everything.
      length: 3, //Length of Tabs
      child: Scaffold(
        appBar: AppBar(title: const Text("GlobalChat Draw")),
        body: Container(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            //Pages Switches on selection of the respective tabs.
            children: <Widget>[
              //TabView 1
              ServerTab(),

              //TabView 2
              ChatScreen(),

              //ChatTab(),

              //DrawTab(),
              Draw(key: drawkey)
            ],
          ),
        ),

        //Actual Tabs at the bottom.
        bottomNavigationBar: IgnorePointer(
          ignoring: ignoring,
          child: Container(
            //Container used for rounded Corners on top.
            child: TabBar(
              tabs: <Widget>[
                Tab(
                  //Tab 1
                  child: Text('Servers'),
                ),
                Tab(
                  //Tab 1
                  child: Text('Chat'),
                ),
                Tab(
                  //Tab 2
                  child: Text('Draw'),
                ),
              ],
            ),
            alignment: Alignment.center,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
