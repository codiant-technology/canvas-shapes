import 'package:canvas_shapes/ui/home_view/widgets/custom_button.dart';
import 'package:canvas_shapes/ui/home_view/widgets/custom_painter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        resizeToAvoidBottomInset: false,
          body: Column(
        children: [
           Row(
            children: [
          CustomButton(
          text: 'New Kitchen Counter top',
            onSubmit: () {
              viewModel.lShapes.clear();
              viewModel.fixedWidth=100.0;
              viewModel.rebuildUi();
            },
          ),
        CustomButton(
          text: 'New Island Counter top',
          onSubmit: () {
            viewModel.lShapes.clear();
            viewModel.fixedWidth=150.0;
            viewModel.rebuildUi();
          },),
              CustomButton(
                text: 'Export to DXF file',
                onSubmit: () {
                  if(viewModel.lShapes.isNotEmpty){
                    viewModel.saveAndShareDXF();
                  }else{
                    Fluttertoast.showToast(
                        msg: "No, Drawings found",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 12.0
                    );
                  }

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
              onTapUp: (tap){
                viewModel.handleTap(tap.localPosition, context);
              },

              child: CustomPaint(
                painter: LShapePainter(viewModel),
              ),
            ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            viewModel.lShapes.clear();
          },
          tooltip: 'Clear',
          child: Icon(Icons.delete_forever),
        ),
      ),



    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();
}
