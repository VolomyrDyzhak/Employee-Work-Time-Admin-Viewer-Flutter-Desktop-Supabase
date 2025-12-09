import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BTNStyles {
  static ButtonStyle botonFinal = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
    backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 24, 71, 199)),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
    overlayColor: WidgetStatePropertyAll(Colors.black12),
    minimumSize: WidgetStatePropertyAll(Size(320.w, 100.h)),
    elevation: WidgetStatePropertyAll(0),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
  );

  static ButtonStyle botonCol1 = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
    backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 254, 32, 32)),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
    overlayColor: WidgetStatePropertyAll(Colors.black12),
    minimumSize: WidgetStatePropertyAll(Size(double.infinity, 70.h)),
    elevation: WidgetStatePropertyAll(0),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
  );

  static ButtonStyle botonDisabled = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
    backgroundColor: WidgetStatePropertyAll(Color.fromARGB(138, 146, 196, 186)),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
    minimumSize: WidgetStatePropertyAll(Size(double.infinity, 70.h)),
    elevation: WidgetStatePropertyAll(0),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
  );
  static ButtonStyle botonCSV = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    ),
    backgroundColor: WidgetStatePropertyAll(Color.fromARGB(136, 10, 157, 10)),
    foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 255, 255)),
    elevation: WidgetStatePropertyAll(0),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
  );
}
