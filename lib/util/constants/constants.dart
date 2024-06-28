import 'package:canvas_shapes/util/constants/color_constants.dart';
import 'package:flutter/material.dart';

showEditPopup(BuildContext context) async {
  TextEditingController controller = TextEditingController();

  double? newLength = await showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Rectangle Length'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter new length',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Submit',
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              double? length = double.tryParse(controller.text);
              Navigator.of(context).pop(length);
            },
          ),
        ],
      );
    },
  );
  return newLength;
}
