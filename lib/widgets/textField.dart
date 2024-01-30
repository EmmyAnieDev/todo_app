import 'package:flutter/material.dart';
import 'package:todo_app/components/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.hintText,
    this.maxLine = 1,
    required this.controller,
  });

  final String hintText;
  final int maxLine;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLine,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: kTextStyle2,
        contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 2.w),
          borderRadius: BorderRadius.circular(5.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade500, width: 2.w),
          borderRadius: BorderRadius.circular(5.r),
        ),
      ),
    );
  }
}
