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
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: widget.onSubmit,
          child: Text(widget.text,maxLines: 2,textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10),),
        ),
      ),
    );;
  }
}
