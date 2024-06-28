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
  double canvasHeight = 0.0; // Add this to store the height of the canvas

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

  void handleTap(Offset position, BuildContext context) async {
    for (var lShape in lShapes) {
      if (isPointNearLine(lShape.start, lShape.endHorizontal!, position)) {
        double? newLength = await showEditPopup(context);
        updateRectangleWidth(lShape, newLength!);
        rebuildUi();

        break;
      } else if (isPointNearLine(lShape.endHorizontal!, lShape.endVertical!, position)) {
        double? newLength = await showEditPopup(context);
        updateRectangleHeight(lShape, newLength!);
        rebuildUi();
        break;
      } else if (isPointNearLine(lShape.endVertical!, Offset(lShape.endVertical!.dx - 100, lShape.endVertical!.dy), position)) {
        double? newLength = await showEditPopup(context);
        updateRectangleHeight(lShape, newLength!);
        rebuildUi();
        break;
      } else if (isPointNearLine(Offset(lShape.endVertical!.dx - 100, lShape.endVertical!.dy), Offset(lShape.endVertical!.dx - 100, lShape.start.dy + 100), position)) {
        double? newLength = await showEditPopup(context);
        updateRectangleWidth(lShape, newLength!);
        rebuildUi();
        break;
      }
    }
  }

  void updateRectangleWidth(LShape lShape, double newWidth) {
    lShape.endHorizontal = Offset(lShape.start.dx + newWidth, lShape.start.dy);
    lShape.endVertical = Offset(lShape.start.dx + newWidth, lShape.endVertical!.dy);
    rebuildUi();
  }

  void updateRectangleHeight(LShape lShape, double newHeight) {
    lShape.endVertical = Offset(lShape.endVertical!.dx, lShape.start.dy + newHeight);
    rebuildUi();
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

      if (!_isOverlapping(currentLShape!) && !isRectTooSmall(currentLShape!)) {
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
      if ((endVertical.dy - start.dy).abs() > fixedWidth) {
        if (endVertical.dy < start.dy) {
          vertices.addAll([
            [start.dx, start.dy],
            [endHorizontal.dx, endHorizontal!.dy],
            [endVertical!.dx, endVertical!.dy],
            [endVertical!.dx - fixedWidth, endVertical.dy],
            [endVertical!.dx - fixedWidth, start.dy - fixedWidth],
            [start.dx, start.dy - fixedWidth],
          ]);
        } else {
          vertices.addAll([
            [start.dx, start.dy],
            [endHorizontal.dx, endHorizontal!.dy],
            [endVertical!.dx, endVertical!.dy],
            [endVertical!.dx - fixedWidth, endVertical.dy],
            [endVertical!.dx - fixedWidth, start.dy + fixedWidth],
            [start.dx, start.dy + fixedWidth],
          ]);
        }
      }else{
        vertices.addAll([
          [start.dx, start.dy], // Top-left corner
          [endHorizontal.dx, start.dy], // Top-right corner
          [endHorizontal.dx, start.dy + fixedWidth], // Bottom-right corner
          [start.dx, start.dy + fixedWidth],
          // [start.dx, start.dy],
          // [endHorizontal.dx, endHorizontal!.dy],
          // [endVertical!.dx, endVertical!.dy],
          // [start.dx, start.dy + fixedWidth],
        ]);
      }
    }
  }






  bool isRectTooSmall(LShape lShape) {
    // Calculate the size of the rectangle
    double width = (lShape.endVertical!.dx - lShape.start.dx).abs();
    double height = (lShape.endVertical!.dy - lShape.start.dy).abs();

    // Define a threshold for what constitutes "very small"
    double minimumSizeThreshold = 10.0; // Adjust this threshold as needed

    // Check if either dimension is smaller than the threshold
    return width < minimumSizeThreshold || height < minimumSizeThreshold;
  }


  void saveAndShareDXF() async {
    try {
      for (var lShape in lShapes) {
        updateVertices(lShape.endHorizontal!, lShape.start, lShape.endVertical!);

        // Invert y-coordinates for DXF
        List<List<double>> invertedVertices = vertices.map((vertex) {
          return [vertex[0], canvasHeight - vertex[1]];
        }).toList();

        var polyline = AcDbPolyline(vertices: invertedVertices, isClosed: true, layerName: "Rectangle");
        dxf.addEntities(polyline);
      }
      await saveDXFFile(dxf);
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = '${directory.path}/drawing.dxf';
        shareFile(filePath);
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
