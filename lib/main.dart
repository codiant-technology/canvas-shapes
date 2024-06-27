import 'package:canvas_shapes/ui/home_view/home_view.dart';
import 'package:canvas_shapes/util/constants/screen_size.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    initializeUtilContexts(context);
    return const MaterialApp(
      home: HomeView(),
    );
  }
  void initializeUtilContexts(BuildContext context) {
    ScreenSizeUtil.context = context;
  }
}
