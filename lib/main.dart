import 'package:chat_with_aks/routes/app_pages.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_with_aks/firebase_options.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/instance_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chat with AKS',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );       
  }
}