import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unibridge_lk/theme/app_theme.dart';

class PremiumPopup extends StatelessWidget {
  const PremiumPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.workspace_premium, color: Colors.amber, size: 48),
          SizedBox(height: 12),
          Text('Unlock Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text('Access features like Event creation and unlimited connections.', textAlign: TextAlign.center),
          SizedBox(height: 16),
          ElevatedButton(onPressed: () { Get.back(); Get.snackbar('Premium', 'Purchase flow (mock)'); }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: Text('Buy Premium')),
        ]),
      ),
    );
  }
}
