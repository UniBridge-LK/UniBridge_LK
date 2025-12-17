# In-App Help & Onboarding Guide

## Overview
This document outlines the new in-app help features added to UniBridge LK to provide users with quick access to support and guidance.

## Features

### 1. Onboarding Screen
**Purpose**: Welcome new users and explain key features

**Trigger**: 
- Appears on first app launch
- Can be manually re-accessed from settings

**Content**: 5-page walkthrough covering:
1. **Welcome** - Introduction to UniBridge LK
2. **Messaging** - Real-time chat features with edit/delete
3. **Events** - Event discovery and attendance
4. **Forums** - Discussion and Q&A capabilities
5. **Getting Started** - Call-to-action to create account

**Navigation**:
- Back button to go to previous pages
- Next button to progress
- Skip button to dismiss
- Dots indicator showing current page

**Access Points**:
```dart
// Navigate to onboarding from anywhere
Get.toNamed(AppRoutes.onboarding);
```

### 2. Help & Support View
**Purpose**: Provide instant answers to common questions

**Location**: Settings > Help & Support

**Content**: 6 categories with 20+ FAQs:
1. **Getting Started** (3 items)
   - Account creation process
   - Email verification
   - Password recovery

2. **Messaging** (4 items)
   - Sending messages
   - Editing messages
   - Deleting messages
   - Message timestamps

3. **Connections** (3 items)
   - Finding other users
   - Understanding "Pending" status
   - Managing connections

4. **Events & Forums** (3 items)
   - Finding and attending events
   - Joining forums
   - Creating events

5. **Search & Discovery** (2 items)
   - Using search filters
   - Filtering by university/faculty

6. **Troubleshooting** (3 items)
   - App crashes/freezing
   - Messages not sending
   - Not receiving requests

**UI Design**:
- Expandable category cards
- Icon indicators for each category
- Clear Q&A formatting
- "Contact Support" section with email link
- Color-coded categories for visual organization

**Access Points**:
```dart
// Navigate from settings
Get.toNamed(AppRoutes.help);

// Or directly in settings
_buildSettingsTile(
  icon: Icons.help_outline,
  title: 'Help & Support',
  onTap: () => Get.toNamed(AppRoutes.help),
)
```

### 3. Settings Integration
**Location**: Profile > Settings

**New Options Added**:
```
Settings
├── Change Password
├── Rate App
├── Dark Theme
├── Notifications Settings
├── Buy Premium
├── Help & Support  ← NEW
├── Contact Support
└── Delete Account
```

**Help & Support Tile**:
- Icon: Question mark outline
- Title: "Help & Support"
- Subtitle: "View FAQs and troubleshooting guides"
- Tap action: Opens HelpView

## File Structure

```
lib/
├── views/
│   ├── onboarding_view.dart          # Onboarding screen (5 pages)
│   ├── help_view.dart                # Help & FAQ view
│   └── settings_view.dart            # Updated with Help link
├── routes/
│   ├── app_routes.dart               # Added onboarding & help routes
│   └── app_pages.dart                # Added route bindings
└── theme/
    └── app_theme.dart                # Uses existing color scheme
```

## Implementation Details

### OnboardingView
- **File**: `lib/views/onboarding_view.dart`
- **Key Features**:
  - PageView for smooth transitions
  - Animated page indicators
  - Skip/Back/Next navigation
  - Colorful category icons
  - Responsive design

### HelpView
- **File**: `lib/views/help_view.dart`
- **Key Features**:
  - Expandable category sections
  - SearchLike organization
  - Formatted Q&A content
  - Email support button
  - Icon-coded categories

### Routes
- **File**: `lib/routes/app_routes.dart`
  - Added: `static const String onboarding = '/onboarding';`
  - Added: `static const String help = '/help';`

- **File**: `lib/routes/app_pages.dart`
  - Added imports for OnboardingView and HelpView
  - Added GetPage for onboarding
  - Added GetPage for help

### Settings Integration
- **File**: `lib/views/settings_view.dart`
  - Imported AppRoutes
  - Added Help & Support tile
  - Positioned before Contact Support
  - Navigation triggers HelpView

## Usage Examples

### Open Onboarding from Anywhere
```dart
Get.toNamed(AppRoutes.onboarding);
```

### Open Help from Anywhere
```dart
Get.toNamed(AppRoutes.help);
```

### From Settings View
- Navigate to your profile
- Tap "Settings"
- Tap "Help & Support"
- Browse FAQs by category

### First-Time User Experience
1. App launches → SplashView
2. User signs up
3. Redirected to OnboardingView
4. 5-page intro walkthrough
5. Tap "Get Started" → Navigate to main app
6. User can access Help anytime via Settings

## Customization

### Modify Onboarding Content
Edit the `pages` list in `OnboardingView`:
```dart
final List<OnboardingPage> pages = [
  OnboardingPage(
    title: 'Your Title',
    description: 'Your Description',
    icon: Icons.your_icon,
    color: Color(0xFFYourColor),
  ),
  // Add more pages...
];
```

### Modify Help Categories
Edit the `categories` list in `HelpView`:
```dart
final List<HelpCategory> categories = [
  HelpCategory(
    title: 'Category Name',
    icon: Icons.category_icon,
    items: [
      HelpItem(
        question: 'Q: Your Question?',
        answer: 'A: Your Answer',
      ),
      // Add more items...
    ],
  ),
  // Add more categories...
];
```

## Future Enhancements

1. **Search Functionality**: Add search bar in HelpView to filter FAQs
2. **In-App Chat**: Integrate real-time support chat
3. **Video Tutorials**: Embed tutorial videos in help sections
4. **Offline Help**: Cache help content locally
5. **Analytics**: Track which FAQs users access most
6. **Ratings**: Allow users to rate help usefulness
7. **Feedback**: Collect feedback on help quality
8. **Multi-Language**: Support for Sinhala, Tamil, and English

## Testing Checklist

- [ ] Onboarding displays on first launch
- [ ] Can navigate between onboarding pages
- [ ] Skip button dismisses onboarding
- [ ] Help view opens from settings
- [ ] All categories expand/collapse
- [ ] Email support link works
- [ ] Navigation back from help works
- [ ] Onboarding can be re-accessed

## Deployment Notes

1. Ensure all imports are correct in app_pages.dart
2. Test navigation flow on target devices
3. Verify URL launcher for email support
4. Check theme colors match app design
5. Test on low-memory devices (UI performance)
6. Verify responsive layout on tablets

## Dependencies

- **GetX**: For navigation and state management
- **Flutter**: Material UI and basic widgets
- **url_launcher**: For email support link (already in your pubspec.yaml)

No additional dependencies required!
