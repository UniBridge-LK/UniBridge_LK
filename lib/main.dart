import 'package:chat_with_aks/routes/app_pages.dart';
import 'package:chat_with_aks/theme/app_theme.dart';
import 'package:chat_with_aks/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_with_aks/firebase_options.dart';
import 'package:get/get.dart';
import 'package:chat_with_aks/services/chat_hive_service.dart';
import 'package:chat_with_aks/services/chat_sync_service.dart';

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
        title: 'Chat with AKS',
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
