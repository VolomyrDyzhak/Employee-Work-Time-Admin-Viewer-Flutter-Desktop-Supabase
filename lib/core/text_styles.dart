import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyles {
  
   static TextStyle get titleText => TextStyle(
        fontSize: 62.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 225, 255, 249),
      );

  static TextStyle get mainText => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 0, 72, 58),
      );

  static TextStyle get errorText => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 255, 0, 0),
      );

  static TextStyle get formText => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 0, 45, 135),
      );

  static TextStyle get nameText => TextStyle(
        fontSize: 25.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 20, 157, 1),
        decoration: TextDecoration.underline,
      );

  static TextStyle get btnText => TextStyle(
        fontSize: 58.sp,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 252, 253, 255),
      );
}
