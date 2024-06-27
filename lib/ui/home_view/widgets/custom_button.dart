import 'package:flutter/material.dart';
import '../../../util/constants/color_constants.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({super.key, required this.text,required this.onSubmit});
  final String text;
  final VoidCallback onSubmit;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          ),
          onPressed: widget.onSubmit,
          child: Text(widget.text,maxLines: 2,textAlign: TextAlign.center,),
        ),
      ),
    );;
  }
}
