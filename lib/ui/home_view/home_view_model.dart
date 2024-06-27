import 'dart:io';

import 'package:canvas_shapes/ui/home_view/widgets/custom_painter.dart';
import 'package:dxf/dxf.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel with Initialisable {
  Offset? startPosition;
  Offset? currentPosition;
  LShape? currentLShape;
  List<LShape> lShapes = [];
  final double fixedWidth = 100.0; // Fixed width for the rectangles
  final double strokeWidth = 2.0; // Stroke width for painting
  final dxf = DXF.create();

  Rect? currentRect;
  List<List<double>> vertices= [];
  @override
  void initialise() {}

  void updatePosition(DragUpdateDetails details) {

      currentPosition = details.localPosition;
      if (currentLShape != null) {
        currentLShape!.endHorizontal = Offset(currentPosition!.dx, startPosition!.dy);
        currentLShape!.endVertical = Offset(currentPosition!.dx, currentPosition!.dy);

        currentRect = Rect.fromPoints(currentRect!.topLeft, details.localPosition);
        // updateVertices();

      }
     rebuildUi();
  }

  void setStartPosition(DragStartDetails details) {
      startPosition = details.localPosition;
      currentPosition = details.localPosition;
      currentLShape = LShape(startPosition!);
      final startPoint = details.localPosition;
      currentRect = Rect.fromPoints(startPoint, startPoint);
      // updateVertices();

      rebuildUi();
  }

  void endDrag(DragEndDetails details) {
    if (currentLShape != null) {
      currentLShape!.endHorizontal = Offset(currentPosition!.dx, startPosition!.dy);
      currentLShape!.endVertical = Offset(currentPosition!.dx, currentPosition!.dy);

      if (!_isOverlapping(currentLShape!)) {
        lShapes.add(currentLShape!);
      }
      currentLShape = null;
    }
    startPosition = null;
    currentPosition = null;

    rebuildUi();
  }


  bool _isOverlapping(LShape newShape) {
    Rect newRect = _getRectFromLShape(newShape);
    for (var existingShape in lShapes) {
      Rect existingRect = _getRectFromLShape(existingShape);
      if (newRect.overlaps(existingRect)) {
        return true;
      }
    }
    return false;
  }

  Rect _getRectFromLShape(LShape lShape) {
    Offset start = lShape.start;
    Offset endHorizontal = lShape.endHorizontal!;
    Offset endVertical = lShape.endVertical!;
    double left = start.dx;
    double right = endHorizontal.dx;
    double top = start.dy;
    double bottom = endVertical.dy;
    return Rect.fromLTRB(
      left < right ? left : right,
      top < bottom ? top : bottom,
      left > right ? left : right,
      top > bottom ? top : bottom,
    ).inflate(0);
  }

  void updateVertices(endHorizontal,start,endVertical)  {
    vertices.clear();
    if (currentRect != null) {
    vertices.addAll([
        [start.dx,start.dy],
        [endHorizontal.dx, start.dy],
        [endHorizontal.dx, start.dy +fixedWidth],
        [endHorizontal.dx, endVertical.dy],
        [endHorizontal.dx - fixedWidth, endVertical.dy],
        [endHorizontal.dx - fixedWidth, start.dy + fixedWidth],
      ]);
    }
  }

  void saveAndShareDXF() async {
    try {

      var polyline = AcDbPolyline(
          vertices: vertices, isClosed: true, layerName: "Rectangle");
      dxf.addEntities(polyline);

      var text = AcDbText(
        x: 14.2,
        y: 16.7,
        textString: '',
      );

      dxf.addEntities(text);

      await saveDXFFile(dxf);
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = '${directory.path}/drawing.dxf';
        shareFile(filePath);
      } else {
      }
    } catch (e) {
      print('Error saving or sharing DXF file: $e');
    }
  }

  Future<void> saveDXFFile(DXF dxf) async {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/drawing.dxf';
    File file = File(filePath);

    // Write DXF content to the file
    await file.writeAsString(dxf.dxfString);
  }

  void shareFile(String filePath) {
    Share.shareFiles([filePath], text: 'Sharing DXF file');
  }


}

