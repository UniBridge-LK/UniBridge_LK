import 'package:unibridge_lk/routes/app_pages.dart';
import 'package:unibridge_lk/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unibridge_lk/firebase_options.dart';
import 'package:unibridge_lk/controllers/settings_controller.dart';
import 'package:get/get.dart';
import 'package:unibridge_lk/services/chat_hive_service.dart';
import 'package:unibridge_lk/services/chat_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ChatHiveService.init();

  // Initialize chat sync service for offline support
  ChatSyncService.start();

  Get.put(SettingsController());
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(
      () => GetMaterialApp(
        title: 'UniBridge LK',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsController.darkThemeEnabled.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
