import 'package:draw/pages/serverTab.dart';
import 'package:flutter/material.dart';
import '../draw_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              ServerTab(),

              //ChatTab(),

              //DrawTab(),
              Draw()
            ],
          ),
        ),

        //Actual Tabs at the bottom.
        bottomNavigationBar: Container(
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
    );
  }
}
