import 'package:draw/pages/serverTab.dart';
import 'package:flutter/material.dart';
import '../draw_screen.dart';
import '../chat_screen.dart';

final drawkey = new GlobalKey<DrawState>();

final chatkey = new GlobalKey<ChatScreenState>();

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with
        AutomaticKeepAliveClientMixin<HomePage>,
        SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Server'),
    new Tab(text: 'Chat'),
    new Tab(text: 'Draw'),
  ];

  TabController tabController;
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
    tabController = new TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      //Default tab controller wraps everything.
      length: 3, //Length of Tabs
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text("GlobalChat Draw")),
        body: Container(
          child: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            //Pages Switches on selection of the respective tabs.
            children: <Widget>[
              //TabView 1
              ServerTab(),

              //TabView 2
              ChatScreen(key: chatkey),

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
              controller: tabController,
              tabs: myTabs,
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
