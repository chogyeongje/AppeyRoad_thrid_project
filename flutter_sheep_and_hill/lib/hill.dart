import 'package:flutter/cupertino.dart';
import 'package:flutter_sheep_and_hill/sheep_controller.dart';
import 'package:flutter_sheep_and_hill/utils.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:simple_animations/simple_animations.dart';


class Hill extends StatefulWidget {

  final Color color;
  final double velocity;
  final int total;
  final SheepController sheepController;

  Hill(this.color, this.velocity, this.total, {Key key, this.sheepController}) : super(key: key);

  @override
  _HillState createState() => _HillState(color, velocity, total, sheepController);
}

class _HillState extends State<Hill> {

  final Color color;
  final double velocity;
  final int total;
  final List<Offset> points = [];
  final SheepController sheepController;

  _HillState(this.color, this.velocity, this.total, this.sheepController);

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {

        var size = Size(constraints.biggest.width, 500);

        final num gap = (size.width / (total - 2)).ceil();

        for (int i = 0; i < total; i++) {
          points.add(Offset(i * gap, getY(size)));
        }

        return Container(
          height: 500,
          width: constraints.biggest.width,
          child: LoopAnimation<double>(
            duration: Duration(seconds: 5),
            tween: Tween()..begin = 0.0..end = 2 * pi,
            builder: (context, child, value) {
              return CustomPaint(
                foregroundPainter: BottomWavePainter(color, velocity, total, points, sheepController),
              );
            },
          ),
        );
      },
    );
  }
}


class BottomWavePainter extends CustomPainter {

  final Color color;
  final double velocity;
  final int total;
  final List<Offset> points;
  final SheepController sheepController;

  BottomWavePainter(this.color, this.velocity, this.total, this.points, this.sheepController);

  @override
  void paint(Canvas canvas, Size size) {

    var path = Path();
    var paint = Paint()
      ..color = color;

    points[0] = points[0].translate(velocity, 0);
    var cur = points[0];
    var prev = cur;
    var cx, cy;

    final num gap = (size.width / (total - 2)).ceil();

    if (cur.dx > -gap) {
      points.insert(0, Offset(-gap*2, getY(size)));
    } else if (cur.dx > size.width + gap) {
      points.removeLast();
    }

    path.moveTo(cur.dx, cur.dy);

    var prevCx = cur.dx;
    var prevCy = cur.dy;

    if (sheepController != null) {
      sheepController.resetOffset();
    }

    for (int i = 1; i < points.length; i++) {
      points[i] = points[i].translate(velocity, 0);
      cur = points[i];

      cx = (prev.dx + cur.dx) / 2;
      cy = (prev.dy + cur.dy) / 2;

      path.quadraticBezierTo(prev.dx, prev.dy, cx, cy);

      if (sheepController != null) {
        sheepController.addOffset(TripleOffset(prevCx, prevCy, prev.dx, prev.dy, cx, cy));
      }

      prevCx = cx;
      prevCy = cy;

      prev = cur;
    }

//    path.lineTo(prev.dx, prev.dy);
    path.lineTo(points.last.dx, size.height);
    path.lineTo(points[0].dx + velocity, size.height);
    path.lineTo(points[0].dx, points[0].dy);


    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double getY(Size size) {
  double min = size.height / 8;
  double max = size.height - min;
  final random = Random();
  return min + random.nextInt((max - min).toInt());
}