import 'dart:async';
import 'dart:typed_data';

import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_sheep_and_hill/sheep.dart';
import 'package:flutter_sheep_and_hill/utils.dart';
import 'package:image/image.dart' as IMG;
import 'package:spritewidget/spritewidget.dart';

class SheepController extends ChangeNotifier {

  String imagePath;
  num width;
  List<TripleOffset> dots;

  final totalFrame = 8;
  final curFrame = 0;

  final imgWidth = 360;
  final imgHeight = 300;

  final double sheepWidth = 180;
  final double sheepHeight = 150;

  var sheepWidthHalf;
  var x, y, speed;

  final List<Offset> point = [];

  final fps = 24;
  final fpsTime = 1000 / 24;

  ui.Image image;
  bool isImageloaded = false;
  final List<Sheep> items = [];
  int cur = 0;

  static final SheepController _sheepController = SheepController._internal();

  SheepController._internal();

  factory SheepController({imagePath, width, dots}) {
    _sheepController.imagePath = imagePath;
    _sheepController.width = width;
    _sheepController.dots = dots;
    return _sheepController;
  }

  Future <Null> init() async {
    final ByteData data = await rootBundle.load(imagePath);
    image = await loadImage(new Uint8List.view(data.buffer));
  }

  Future <Null> init2() async {
    ImageMap images = new ImageMap(rootBundle);
    image = await images.loadImage(imagePath);
    print('loaded');
    loaded();
    notifyListeners();
  }

  Future init3() async {
    image = await Flame.images.load(imagePath);
    print('loaded');
    loaded();
    notifyListeners();
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final IMG.Image image = IMG.decodeImage(img);
    final IMG.Image resized = IMG.copyResize(image, height: sheepHeight.toInt(), width: sheepWidth.toInt());
    final List<int> resizedBytes = IMG.encodePng(resized);

    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(resizedBytes, (ui.Image img) {
      loaded();
//      notifyListeners();
      return completer.complete(img);
    });
    return completer.future;
  }

  void loaded() {
    isImageloaded = true;
    print("loaded");
//    addSheep();
  }

  List<Widget> getSheeps() {
    if (this.isImageloaded) {
      cur += 1;
      if (cur > 200) {
        cur = 0;
        this.addSheep();
      }

      var item;
      for (int i = items.length - 1; i >= 0; i--) {
        item = items[i];
        if (item.x < -item.width) {
          items.removeAt(i);
        }
      }
    }
    return items;
  }

  void addSheep() {
    items.add(Sheep(image, width));
  }

  addOffset(TripleOffset offset){
    dots.add(offset);
  }

  resetOffset() {
    dots.clear();
  }
}