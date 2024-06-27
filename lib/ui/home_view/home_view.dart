import 'package:canvas_shapes/ui/home_view/widgets/custom_button.dart';
import 'package:canvas_shapes/ui/home_view/widgets/custom_painter.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../util/constants/screen_size.dart';
import 'home_view_model.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
           Row(
            children: [
              CustomButton(
                text: 'New Kitchen Counter top',
                onSubmit: () {},
              ),
              CustomButton(
                text: 'New Island Counter top',
                onSubmit: () {
                  viewModel.lShapes.clear();

                },
              ),
              CustomButton(
                text: 'Export to DXF file',
                onSubmit: () {
                  viewModel.saveAndShareDXF();
                },
              )
            ],
          ),
          SizedBox(
            width: ScreenSizeUtil.screenWidth,
            height: ScreenSizeUtil.screenHeight*0.7,
            child: GestureDetector(
              onPanStart: viewModel.setStartPosition,
              onPanUpdate: viewModel.updatePosition,
              onPanEnd: viewModel.endDrag,

              child: CustomPaint(
                painter: LShapePainter(viewModel),
              ),
            ),
          ),
        ],
      )),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
