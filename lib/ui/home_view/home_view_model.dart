import 'dart:io';
import 'package:canvas_shapes/ui/home_view/widgets/custom_painter.dart';
import 'package:dxf/dxf.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:stacked/stacked.dart';
import '../../util/constants/constants.dart';

class HomeViewModel extends BaseViewModel with Initialisable {
  Offset? startPosition;
  Offset? currentPosition;
  LShape? currentLShape;
  List<LShape> lShapes = [];
  final double fixedWidth = 100.0; // Fixed width for the rectangles
  final double strokeWidth = 2.0; // Stroke width for painting
  final dxf = DXF.create();
  final double tolerance = 10.0;
  Rect? currentRect;
  List<List<double>> vertices = [];

  @override
  void initialise() {}

  void updatePosition(DragUpdateDetails details) {
    currentPosition = details.localPosition;
    if (currentLShape != null) {
      currentLShape!.endHorizontal = Offset(currentPosition!.dx, startPosition!.dy);
      currentLShape!.endVertical = Offset(currentPosition!.dx, currentPosition!.dy);

      currentRect = Rect.fromPoints(currentRect!.topLeft, details.localPosition);
    }
    rebuildUi();
  }

  void updateRectangleLength(LShape lShape, double newLength) {
    double delta = newLength - (lShape.endVertical!.dx - lShape.start.dx);
    lShape.endHorizontal = Offset(lShape.start.dx + newLength, lShape.start.dy);
    lShape.endVertical = Offset(lShape.start.dx + newLength, lShape.endVertical!.dy);
    rebuildUi();
  }

  void handleTap(Offset position, BuildContext context) async {
    for (var lShape in lShapes) {
      if (isOnLine(lShape, position)) {
        double? newLength = await showEditPopup(context);
        if (newLength != null) {
          updateRectangleLength(lShape, newLength);
          rebuildUi();
        }
        break;
      }
    }
  }

  bool isOnLine(LShape lShape, Offset position) {
    return isPointNearLine(lShape.start, lShape.endHorizontal!, position) ||
        isPointNearLine(lShape.endHorizontal!, lShape.endVertical!, position) ||
        isPointNearLine(lShape.endVertical!, Offset(lShape.endVertical!.dx - 100, lShape.endVertical!.dy), position) ||
        isPointNearLine(Offset(lShape.endVertical!.dx - 100, lShape.endVertical!.dy), Offset(lShape.endVertical!.dx - 100, lShape.start.dy + 100), position);
  }

  bool isPointNearLine(Offset start, Offset end, Offset point) {
    double distance = (point.dx - start.dx) * (end.dy - start.dy) - (point.dy - start.dy) * (end.dx - start.dx);
    distance = distance.abs() / (start - end).distance;
    return distance < tolerance;
  }

  void setStartPosition(DragStartDetails details) {
    startPosition = details.localPosition;
    currentPosition = details.localPosition;
    currentLShape = LShape(startPosition!);
    final startPoint = details.localPosition;
    currentRect = Rect.fromPoints(startPoint, startPoint);
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

  void updateVertices(endHorizontal, start, endVertical) {
    vertices.clear();
    if (currentRect != null) {
      vertices.addAll([
        [start.dx, start.dy],
        [endHorizontal.dx, start.dy],
        [endHorizontal.dx, start.dy + fixedWidth],
        [endHorizontal.dx, endVertical.dy],
        [endHorizontal.dx - fixedWidth, endVertical.dy],
        [endHorizontal.dx - fixedWidth, start.dy + fixedWidth],
      ]);
    }
  }

  void saveAndShareDXF() async {
    try {
      var polyline = AcDbPolyline(vertices: vertices, isClosed: true, layerName: "Rectangle");
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
      } else {}
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
