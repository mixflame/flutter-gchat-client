import 'dart:io';
import 'dart:ui';

import 'package:draw/gdraw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Draw extends StatefulWidget {
  Draw({Key key}) : super(key: key);
  final DrawState _drawState = DrawState();

  @override
  DrawState createState() => _drawState;
}

GDraw gdraw;

// drawing
Map<String, int> nameHash = Map(); // which layer is this handle on
List<String> layerOrder = List(); // which order to draw layers
Map<String, List<DrawingPoint>> layers = Map(); // which points are in a layer
List<DrawingPoint> points = List();

class DrawState extends State<Draw> with AutomaticKeepAliveClientMixin<Draw> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;

  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    gdraw.send(GMessage("GETPOINTS", [gdraw.token]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.greenAccent),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.album),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.StrokeWidth)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.StrokeWidth;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.opacity),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.Opacity)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.Opacity;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.color_lens),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.Color)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.Color;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              showBottomList = false;
                              points.clear();
                            });
                          }),
                    ],
                  ),
                  Visibility(
                    child: (selectedMode == SelectedMode.Color)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: getColorList(),
                          )
                        : Slider(
                            value: (selectedMode == SelectedMode.StrokeWidth)
                                ? strokeWidth
                                : opacity,
                            max: (selectedMode == SelectedMode.StrokeWidth)
                                ? 50.0
                                : 1.0,
                            min: 0.0,
                            onChanged: (val) {
                              setState(() {
                                if (selectedMode == SelectedMode.StrokeWidth)
                                  strokeWidth = val;
                                else
                                  opacity = val;
                              });
                            }),
                    visible: showBottomList,
                  ),
                ],
              ),
            )),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            makePoint(context, details.globalPosition, dragging: true);
          });
        },
        onPanStart: (details) {
          setState(() {
            makePoint(context, details.globalPosition, dragging: false);
          });
        },
        onPanEnd: (details) {
          setState(() {
            // points.add(null);
          });
        },
        child: CustomPaint(
          size: gdraw.canvasSizeY > 0
              ? Size(gdraw.canvasSizeX.toDouble(), gdraw.canvasSizeY.toDouble())
              : Size.infinite,
          painter: DrawingPainter(
            pointsList: points,
          ),
        ),
      ),
    );
  }

  void makePoint(BuildContext context, Offset globalPosition, {bool dragging}) {
    RenderBox renderBox = context.findRenderObject();

    Offset point = renderBox.globalToLocal(globalPosition);
    Color color = selectedColor.withOpacity(opacity);

    addClick(point, dragging, color, strokeWidth, gdraw.handle);

    Offset pout = convertFlutterPointToSwiftPoint(point);
    gdraw.sendPoint(pout, dragging, color, strokeWidth, gdraw.handle);
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          child: AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                enableLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() => selectedColor = pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.red, Colors.green, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }

  void addClick(Offset position, bool dragging, Color color, double rxWidth,
      String clickName) {
    setState(() {
      print("addClick $position");

      DrawingPoint pt = DrawingPoint(
          dragging: dragging,
          clickName: clickName,
          point: position,
          paint: Paint()
            ..strokeCap = StrokeCap.round
            ..isAntiAlias = false
            ..color = color
            ..strokeWidth = rxWidth);

      points.add(pt);

      String layerName = "";

      if (!nameHash.containsKey(clickName)) {
        int layer = 0;
        nameHash[clickName] = layer;
        layerName = "$clickName::!!::$layer";
        List<DrawingPoint> layerArray = List();
        layers[layerName] = layerArray;
      } else {
        if (!dragging) {
          int layer = nameHash[clickName] + 1;
          nameHash[clickName] = layer;
          layerName = "$clickName::!!::$layer";
          List<DrawingPoint> layerArray = List();
          layers[layerName] = layerArray;
        } else {
          int layer = nameHash[clickName];
          layerName = "$clickName::!!::$layer";
        }
      }

      List<DrawingPoint> tempLayer = layers[layerName];
      tempLayer.add(pt);
      layers[layerName] = tempLayer;

      if (!layerOrder.contains(layerName)) {
        layerOrder.add(layerName);
      }
    });
  }
}

class DrawingPainter extends CustomPainter {
  List<DrawingPoint> pointsList;
  List<Offset> offsetPoints = List();
  DrawingPainter({this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    layerOrder.forEach((layer) {
      List<DrawingPoint> layerArray = layers[layer];
      for (int i = 0; i < layerArray.length - 1; i++) {
        DrawingPoint thisObj = layerArray[i];
        Offset thisPoint = thisObj.point;
        if (thisObj.dragging && i > 0) {
          Offset lastPoint = layerArray[i - 1].point;
          drawLineTo(canvas, lastPoint, thisPoint, thisObj.paint);
        } else {
          Offset drawPoint = Offset(thisPoint.dx - 1, thisPoint.dy);
          drawLineTo(canvas, thisPoint, drawPoint, thisObj.paint);
        }
      }
    });
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

void drawLineTo(
    Canvas canvas, Offset lastPoint, Offset thisPoint, Paint paint) {
  canvas.drawLine(lastPoint, thisPoint, paint);
}

class DrawingPoint {
  bool dragging;
  String clickName = "";
  Paint paint;
  Offset point;
  DrawingPoint({this.dragging, this.point, this.paint, this.clickName});
}

Offset convertSwiftPointToFlutterPoint(Offset pt) {
  return pt.scale(1, -1).translate(0, gdraw.canvasSizeY.toDouble());
}

Offset convertFlutterPointToSwiftPoint(Offset pt) {
  return pt.translate(0, -gdraw.canvasSizeY.toDouble()).scale(1, -1);
}

enum SelectedMode { StrokeWidth, Opacity, Color }
