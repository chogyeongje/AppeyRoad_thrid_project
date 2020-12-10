import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sheep_and_hill/sheep_controller.dart';
import 'package:flutter_sheep_and_hill/utils.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';

import 'hill.dart';

void main() {
  runApp(MyApp());
}

const sheepImage = '/images/sheep.png';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataWidget(),
    );
  }
}

class DataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    List<TripleOffset> dots = [];

    var sheepController = SheepController(imagePath: sheepImage, width: MediaQuery.of(context).size.width, dots: dots);
    sheepController.init2();

    List<Hill> hills = [
      Hill(Color(0xfffd6bea), 0.2, 12),
      Hill(Color(0xffff59c2), 0.5, 8),
      Hill(Color(0xffff4674), 1.4, 6, sheepController: sheepController,)
    ];

    return ChangeNotifierProvider(
        create: (_) => sheepController,
        child: InteractiveViewer(child: MyHomePage(hills: hills,))
    );
  }
}

class MyHomePage extends StatelessWidget {

  final List<Hill> hills;

  const MyHomePage({Key key, this.hills}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    var sheepController = Provider.of<SheepController>(context);

    return Stack(
      children: <Widget>[
        MirrorAnimation<Color>(
          duration: Duration(seconds: 10),
          tween: ColorTween()..begin = Colors.lightBlueAccent..end = Colors.black,
            builder: (context, child, value) {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: value,
              );
            },
        ),
        Align(
          alignment: Alignment.topRight,
          child: MirrorAnimation<Color>(
            tween: ColorTween()..begin = Colors.yellow..end = Colors.white,
            builder: (context, child, value) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value,
                ),
                height: 300,
                width: 300,
                margin: const EdgeInsets.all(100),
              );
            },
            duration: Duration(seconds: 10),
            curve: Curves.easeInOut,
          ),
        ),
        for(Hill hill in hills) ...[onBottom(hill)],
        LoopAnimation(
          duration: Duration(seconds: 3),
            builder: (context, child, value) {
              return onBottom(Container(height: 500, child: Stack(children: [...sheepController.getSheeps()],)));
            }, tween:Tween()..begin = 0.0..end = 2 * pi,),
      ],
    );
  }

  Widget onBottom(Widget child) => Positioned.fill(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: child,
    ),
  );
}

