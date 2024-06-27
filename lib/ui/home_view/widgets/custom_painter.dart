import 'package:canvas_shapes/ui/home_view/home_view_model.dart';
import 'package:canvas_shapes/util/constants/color_constants.dart';
import 'package:flutter/material.dart';

class LShape {
  final Offset start;
  Offset? endHorizontal;
  Offset? endVertical;

  LShape(this.start);
}

class LShapePainter extends CustomPainter {
  HomeViewModel viewModel;

  LShapePainter(this.viewModel);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = viewModel.strokeWidth
      ..style = PaintingStyle.stroke;

    for (var lShape in viewModel.lShapes) {
      _drawLShape(canvas, paint, lShape);
    }

    if (viewModel.currentLShape != null) {
      _drawLShape(canvas, paint, viewModel.currentLShape!);
    }
  }

  void _drawLShape(Canvas canvas, Paint paint, LShape lShape) {
    Offset start = lShape.start;
    Offset endHorizontal = lShape.endHorizontal!;
    Offset endVertical = lShape.endVertical!;
    Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(endHorizontal.dx, start.dy); // Draw horizontal line
    bool isMovingUp = endVertical.dy < start.dy;
    double verticalMovement = (endVertical.dy - start.dy).abs();
    if (verticalMovement > viewModel.fixedWidth) {
      if (isMovingUp) {
        path.lineTo(endHorizontal.dx, start.dy - viewModel.fixedWidth); // Move up
        path.lineTo(endHorizontal.dx, endVertical.dy); // Continue up
        path.lineTo(endHorizontal.dx - viewModel.fixedWidth, endVertical.dy);
        path.lineTo(endHorizontal.dx - viewModel.fixedWidth, start.dy - viewModel.fixedWidth);
      } else {
        path.lineTo(endHorizontal.dx, start.dy + viewModel.fixedWidth); // Move down
        path.lineTo(endHorizontal.dx, endVertical.dy); // Continue down
        path.lineTo(endHorizontal.dx - viewModel.fixedWidth, endVertical.dy);
        path.lineTo(endHorizontal.dx - viewModel.fixedWidth, start.dy + viewModel.fixedWidth);
      }
    } else {
      if (isMovingUp) {
        path.lineTo(endHorizontal.dx, start.dy - viewModel.fixedWidth); // Continue horizontal up
      } else {
        path.lineTo(endHorizontal.dx, start.dy + viewModel.fixedWidth); // Continue horizontal down
      }
    }
    viewModel.updateVertices(endHorizontal, start, endVertical);
    path.lineTo(start.dx, start.dy + (isMovingUp ? -viewModel.fixedWidth : viewModel.fixedWidth));
    path.close();
    canvas.drawPath(path, paint);
// Draw lengths
    _drawText(canvas, (endHorizontal.dx - start.dx).toStringAsFixed(1), Offset((start.dx + endHorizontal.dx) / 2, start.dy - 10));
    _drawText(canvas, (verticalMovement).toStringAsFixed(1), Offset(endHorizontal.dx + 10, (start.dy + endVertical.dy) / 2), true);
    _drawText(canvas, (endHorizontal.dx - viewModel.fixedWidth - start.dx).toStringAsFixed(1),
        Offset((start.dx + endHorizontal.dx - viewModel.fixedWidth) / 2, start.dy + (isMovingUp ? -viewModel.fixedWidth - 10 : viewModel.fixedWidth + 10)));
    _drawText(canvas, (verticalMovement).toStringAsFixed(1),
        Offset(endHorizontal.dx - viewModel.fixedWidth - 10, (start.dy + (isMovingUp ? -viewModel.fixedWidth : viewModel.fixedWidth) + endVertical.dy) / 2), true);
  }

  void _drawText(Canvas canvas, String text, Offset position, [bool isVertical = false]) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(color: Colors.black, fontSize: 14),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    canvas.save();
    if (isVertical) {
      canvas.translate(position.dx, position.dy);
      canvas.rotate(-3.14 / 2); // Rotate 90 degrees counterclockwise
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    } else {
      final offset = Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2);
      textPainter.paint(canvas, offset);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
