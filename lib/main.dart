import 'dart:async';

import 'package:draw/draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

final data =
    '''POINT::!!::132.0::!!::168.0::!!::false::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::132.0::!!::167.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::132.0::!!::166.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::133.0::!!::165.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::134.0::!!::163.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::136.0::!!::161.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::138.0::!!::159.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::141.0::!!::156.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::144.0::!!::153.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::148.0::!!::149.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::152.0::!!::144.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::157.0::!!::139.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::161.0::!!::135.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::166.0::!!::129.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::171.0::!!::123.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::177.0::!!::117.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::182.0::!!::112.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::186.0::!!::108.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::189.0::!!::104.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::192.0::!!::102.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::194.0::!!::101.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
POINT::!!::195.0::!!::100.0::!!::true::!!::0.0::!!::0.0::!!::0.0::!!::1.0::!!::1.0::!!::keyvan_osx
ENDPOINTS::!!::''';

final roomSubject = BehaviorSubject<String>();

void main() {
  final timer = new Timer(const Duration(seconds: 2), () {
    print("timer trigger");
    data.split("\n").forEach((element) {
      print(element);
      roomSubject.add(element);
    });
  });

  runApp(DrawApp());
}

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Draw(),
    );
  }
}
