
import 'package:desctop_app_origen/screens/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://uwugbsgjphmymwnctuwt.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dWdic2dqcGhteW13bmN0dXd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1NjI1ODQsImV4cCI6MjA3NjEzODU4NH0.jdjdH7yPZdOSzbtDFVwsqMH7DwJZJg4ow8AGXoDywrw",
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // iPhone X base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
      child: RootPage(), // ← ¡Esto es clave!
    );
  }
}

