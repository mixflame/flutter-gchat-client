import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:draw/gdraw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

int canvasSizeX;
int canvasSizeY = 0;
int totalPoints;

// drawing
Map<String, int> nameHash = Map(); // which layer is this handle on
List<String> layerOrder = List(); // which order to draw layers
Map<String, List<DrawingPoint>> layers = Map(); // which points are in a layer
List<DrawingPoint> points = List();

class _DrawState extends State<Draw> {
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

  GDraw gdraw;

  @override
  void initState() {
    super.initState();

    gdraw = GDraw();

    gdraw.registerProtocolHandler("CANVAS", (msg) {
      var sizeArr = msg.arguments[0].split("x");
      canvasSizeX = int.parse(sizeArr[0]);
      canvasSizeY = int.parse(sizeArr[1]);
      totalPoints = int.parse(msg.arguments[1]);
      setState(() {
        print("set the canvas size $canvasSizeX $canvasSizeY plz redrwa");
      });
      gdraw.send(GMessage("GETPOINTS", [gdraw.token]));
    });

    gdraw.registerProtocolHandler("POINT", (msg) {
      var parr = msg.arguments;
      double x = double.tryParse(parr[0]);
      double y = double.tryParse(parr[1]);
      if (x == null || y == null) {
        return;
      }
      bool dragging = parr[2] == "true" ? true : false;
      int red = (double.tryParse(parr[3]) * 255.0).round();
      int green = (double.tryParse(parr[4]) * 255.0).round();
      int blue = (double.tryParse(parr[5]) * 255.0).round();

      double opacity = double.tryParse(parr[6]);
      double width = double.tryParse(parr[7]);
      String clickName = parr[8];
      RenderBox renderBox = context.findRenderObject();
      setState(() {
        addClick(renderBox, x, y, dragging, red, green, blue, opacity, width,
            clickName);
      });
    });

    gdraw.registerProtocolHandler("ENDPOINTS", (msg) {
      setState(() {
        points.add(null);
        print("endpoints set state wrote?");
      });
    });

    gdraw.start();
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
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoint(
                point: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoint(
                point: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
            pointsList: points,
          ),
        ),
      ),
    );
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

  void addClick(RenderBox renderBox, double x, double y, bool dragging, int red,
      int green, int blue, alpha, double rxWidth, String clickName) {
    DrawingPoint pt = DrawingPoint(
        dragging: dragging,
        clickName: clickName,
        point: renderBox.globalToLocal(Offset(x, y)),
        paint: Paint()
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = false
          ..color = Color.fromRGBO(red, green, blue, opacity)
          ..strokeWidth = rxWidth);

    points.add(pt);

    String layerName = "";

    if (!nameHash.containsKey(clickName)) {
      int layer = 0;
      nameHash[clickName] = layer;
      layerName = "$clickName::!!::$layer";
      List<DrawingPoint> layerArray = List();
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
  }
}

class DrawingPainter extends CustomPainter {
  List<DrawingPoint> pointsList;
  List<Offset> offsetPoints = List();
  DrawingPainter({this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    if (canvasSizeY > 0) {
      canvas.translate(0, canvasSizeY.toDouble());
      canvas.scale(1, -1);
    }

    // for (int i = 0; i < pointsList.length - 1; i++) {
    //   if (pointsList[i] != null && pointsList[i + 1] != null) {
    //     canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
    //         pointsList[i].paint);
    //   } else if (pointsList[i] != null && pointsList[i + 1] == null) {
    //     offsetPoints.clear();
    //     offsetPoints.add(pointsList[i].points);
    //     offsetPoints.add(Offset(
    //         pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
    //     canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
    //   }
    // }

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

enum SelectedMode { StrokeWidth, Opacity, Color }
