# Integration Guide: First-Time User Onboarding

## Quick Summary
Three new features have been added to improve user experience:
1. **OnboardingView** - 5-page intro tutorial for new users
2. **HelpView** - In-app FAQ with 20+ Q&As
3. **Settings Integration** - Help accessible from Settings

## Code Changes Made

### 1. Routes Added
**File**: `lib/routes/app_routes.dart`
```dart
static const String onboarding = '/onboarding';
static const String help = '/help';
```

### 2. Pages Registered
**File**: `lib/routes/app_pages.dart`
```dart
// Imports added
import 'package:chat_with_aks/views/onboarding_view.dart';
import 'package:chat_with_aks/views/help_view.dart';

// Routes added
GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
GetPage(name: AppRoutes.help, page: () => const HelpView()),
```

### 3. Settings Link Added
**File**: `lib/views/settings_view.dart`
```dart
// Import added
import 'package:chat_with_aks/routes/app_routes.dart';

// Tile added
_buildSettingsTile(
  icon: Icons.help_outline,
  title: 'Help & Support',
  subtitle: 'View FAQs and troubleshooting guides',
  onTap: () => Get.toNamed(AppRoutes.help),
)
```

## How to Trigger Onboarding

### Option 1: For First-Time Users (Recommended)
Add to your SplashView or AuthController after successful registration:
```dart
// After user successfully signs up
Get.toNamed(AppRoutes.onboarding);
```

### Option 2: Add to Settings for Manual Access
Add a "View Onboarding Again" option in settings:
```dart
_buildSettingsTile(
  icon: Icons.school,
  title: 'Tutorial',
  subtitle: 'Watch the onboarding tutorial',
  onTap: () => Get.toNamed(AppRoutes.onboarding),
)
```

### Option 3: Check First-Time Status
Store in Hive/SharedPreferences:
```dart
// In splash screen
final hasSeenOnboarding = Get.find<HiveService>().get('onboarding_seen');
if (!hasSeenOnboarding) {
  Get.toNamed(AppRoutes.onboarding);
} else {
  Get.toNamed(AppRoutes.main);
}
```

## Files Created

| File | Purpose | Lines |
|------|---------|-------|
| `lib/views/onboarding_view.dart` | 5-page intro tutorial | 240 |
| `lib/views/help_view.dart` | FAQ and help center | 340 |
| `ONBOARDING_HELP_GUIDE.md` | Feature documentation | 400+ |
| `INTEGRATION_GUIDE.md` | This file | - |

## Navigation Flow

```
User Opens App
    ↓
SplashView
    ↓
    ├─ First Time? → OnboardingView → MainView
    │
    └─ Returning? → LoginView → MainView
                        ↓
                    SettingsView → Help & Support → HelpView
```

## Testing the Features

### Test Onboarding
1. Open app
2. Navigate to: `Get.toNamed(AppRoutes.onboarding)`
3. Click through all 5 pages
4. Test Skip, Back, Next buttons
5. Verify page indicators update

### Test Help View
1. Go to Profile > Settings
2. Scroll to "Help & Support"
3. Tap to open HelpView
4. Expand each category
5. Verify Q&A text displays correctly
6. Test email button (shows snackbar)

### Test Settings Link
1. Go to Profile > Settings
2. Verify "Help & Support" appears before "Contact Support"
3. Tap to open HelpView
4. Tap back to return to settings

## Customization Tips

### Change Onboarding Colors
Edit `onboarding_view.dart`:
```dart
OnboardingPage(
  title: 'Welcome to UniBridge LK',
  description: 'Connect with students...',
  icon: Icons.people,
  color: Color(0xFF6C5CE7),  // Change this color
)
```

### Add More Help Categories
Edit `help_view.dart`:
```dart
HelpCategory(
  title: 'New Category',
  icon: Icons.new_icon,
  items: [
    HelpItem(
      question: 'Q: Example?',
      answer: 'A: Example answer here',
    ),
  ],
)
```

### Change Help Access Point
Instead of Settings, add button in MainView:
```dart
FloatingActionButton(
  onPressed: () => Get.toNamed(AppRoutes.help),
  child: Icon(Icons.help),
)
```

## Performance Notes

- OnboardingView: Light weight (PageView with simple widgets)
- HelpView: Uses expandable cards (minimal rendering)
- No database queries - all data is hardcoded
- Recommended for all devices (minimal memory usage)

## Analytics Tracking (Future)

Consider adding event tracking:
```dart
// In OnboardingView
_pageController.onPageChanged = (index) {
  // Analytics.logEvent('onboarding_page_$index');
};

// In HelpView
void _expandCategory(int index) {
  // Analytics.logEvent('help_category_${categories[index].title}');
}
```

## Troubleshooting

### Onboarding Not Showing
- Verify route is added to app_pages.dart
- Check if AppRoutes.onboarding constant exists
- Ensure navigation logic is calling Get.toNamed(AppRoutes.onboarding)

### Help Not Loading
- Verify help_view.dart has no syntax errors
- Check if HelpView is imported in app_pages.dart
- Ensure Settings import of AppRoutes is correct

### Settings Link Not Working
- Verify app_routes.dart is imported in settings_view.dart
- Check if _buildSettingsTile parameters are correct
- Ensure onTap callback uses Get.toNamed(AppRoutes.help)

## Next Steps

1. **Implement First-Time Check**: Add logic to show onboarding only once
2. **Add In-App Analytics**: Track which help items users access most
3. **Create Video Tutorials**: Link tutorial videos from help sections
4. **Multi-Language Support**: Add Sinhala/Tamil translations
5. **Feedback System**: Let users rate help usefulness
6. **Live Chat**: Integrate real support agent chat
7. **Search in Help**: Add search functionality to find FAQs

## Support

For questions or issues with these features:
1. Check ONBOARDING_HELP_GUIDE.md for detailed info
2. Review onboarding_view.dart and help_view.dart code
3. Test navigation with Get.toNamed() commands
4. Verify all imports and routes are correctly configured
