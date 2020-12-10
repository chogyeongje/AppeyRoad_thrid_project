import 'dart:ui' as ui;
import 'dart:math';

import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sheep_and_hill/sheep_controller.dart';
import 'package:flutter_sheep_and_hill/utils.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';


class SheepPainter extends CustomPainter {

  final ui.Image image;
  final double sheepWidth;
  final double sheepHeight;
  final List<Offset> point;
  final SheepController sheepController;
  final double speed;
  final int curFrame;

  SheepPainter(this.image, this.sheepWidth, this.sheepHeight, this.point, this.sheepController, this.speed, this.curFrame);

  @override
  Future paint(Canvas canvas, Size size) async {

    canvas.save();

    point[0] = point[0].translate(-speed, 0);
    var closest = getY2(point[0].dx, sheepController.dots);
    point[0] = Offset(point[0].dx, closest.offset.dy);

    double sheepWidthHalf = sheepWidth / 2;

    canvas.translate(point[0].dx, point[0].dy);
    canvas.rotate(closest.rotation);

    Sprite sprite = Sprite.fromImage(image, x: 360.0 * curFrame, y: 0, width: 360, height: 360);
    sprite.renderPosition(canvas, Position(-sheepWidthHalf, -sheepHeight + 20), size: Position(180, 180));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Sheep extends StatelessWidget {

  final ui.Image image;
  final num width;
  final List<Offset> point = [];

  final totalFrame = 8;
  final curFrame = 0;

  final imgWidth = 360;
  final imgHeight = 300;

  final double sheepWidth = 180;
  final double sheepHeight = 150;

  final fps = 24;
  final fpsTime = 100 / 24;

  var sheepWidthHalf;
  var x, y, speed;

  Sheep(this.image, this.width){
    this.sheepWidthHalf = sheepWidth / 2;
    x = width + sheepWidth;
    y = 0;
    var random = Random();
    speed = random.nextDouble() * 2 + 1;
    point.add(Offset(x, y));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var sheepController = Provider.of<SheepController>(context);
        return Container(
          height: 500,
          width: constraints.biggest.width,
          child: LoopAnimation<double>(
            duration: Duration(seconds: 1),
            tween: Tween()..begin = 0..end = 23,
            builder: (context, child, value) {
              return CustomPaint(
                foregroundPainter: SheepPainter(image, sheepWidth, sheepHeight, point, sheepController, speed, (value % 8).floor()),
              );
            },
          ),
        );
      },
    );
  }
}

OffsetRotation getY2(double x, List<TripleOffset> dots) {
  for (int i = 1; i < dots.length; i++) {
    if (x >= dots[i].x1 && x <= dots[i].x3) {
      return getY3(x, dots[i]);
    }
  }

  return OffsetRotation(Offset(0, 0), 0);
}

OffsetRotation getY3(double x, TripleOffset dot) {
  const total = 200;
  var pt = getPointOnQuad(dot.x1, dot.y1, dot.x2, dot.y2, dot.x3, dot.y3, 0);
  var prevX = pt.offset.dx;
  var t;
  for (int i = 1; i < total; i++) {
    t = i / total;
    pt = getPointOnQuad(dot.x1, dot.y1, dot.x2, dot.y2, dot.x3, dot.y3, t);

    if (x >= prevX && x <= pt.offset.dx) {
      return pt;
    }
    prevX = pt.offset.dx;
  }
  return pt;
}

double getQuadValue(p0, p1, p2, t) {
  return (1-t) * (1-t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
}

OffsetRotation getPointOnQuad(x1, y1, x2, y2, x3, y3, t) {
  var tx = quadTangent(x1, x2, x3, t);
  var ty = quadTangent(y1, y2, y3, t);
  var rotation = -atan2(tx, ty) + (90 * pi / 180);
  return OffsetRotation(Offset(getQuadValue(x1, x2, x3, t), getQuadValue(y1, y2, y3, t)), rotation);
}

double quadTangent(a, b, c, t){
  return 2 * (1-t)*(b-a) + 2*(c-b)*t;
}

class OffsetRotation {
  final Offset offset;
  final double rotation;

  OffsetRotation(this.offset, this.rotation);
}