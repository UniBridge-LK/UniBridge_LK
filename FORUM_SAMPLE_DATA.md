# Forum Sample Data & Seeding Guide

## Overview

The forum system now includes comprehensive sample data for all four forum scopes:
- **Global Forum**: System-wide discussions
- **University Forum**: University-level topics
- **Faculty Forum**: Faculty-specific content
- **Department Forum**: Department-specific discussions

## Files

### 1. `lib/data/sample_forum_data.dart`
Contains all sample threads and replies organized by scope. Each thread includes:
- Title
- Question/Description
- Author name and ID
- Timestamp
- Multiple nested replies with authors and content

**Sample Data**:
- **Global**: 3 threads (Welcome, Learning Resources, Internship Tips)
- **University**: 3 threads (Course Registration, WiFi Issues, Student Organizations)
- **Faculty**: 3 threads (Research Lab, Programming Fundamentals, Capstone Projects)
- **Department**: 3 threads (CS Club, Database Systems, Senior Design)

### 2. `lib/services/forum_seeding_service.dart`
Provides utilities to seed Firestore with sample data:

**Key Methods**:
- `seedAllForums()` - Seeds all four forum scopes
- `seedGlobalForum()` - Seeds only global forum
- `seedUniversityForum(universityId)` - Seeds specific university forum
- `seedFacultyForum(universityId, facultyId)` - Seeds specific faculty forum
- `seedDepartmentForum(universityId, facultyId, departmentId)` - Seeds specific department forum
- `areForumsSeeded()` - Checks if data already exists
- `clearAllForums()` - Removes all forum data (for testing)

## How It Works

### Automatic Seeding
The `ForumController` automatically seeds the forums on app startup if they're not already populated:

```dart
@override
void onInit() {
  super.onInit();
  _initializeForumData();
}

Future<void> _initializeForumData() async {
  final isSeeded = await ForumSeedingService.areForumsSeeded();
  if (!isSeeded) {
    await ForumSeedingService.seedAllForums();
  }
}
```

### Manual Seeding
You can manually seed at any time:

```dart
// In any controller or service
await ForumSeedingService.seedAllForums();
```

### Clearing Data
To clear all forum data (useful for testing):

```dart
await ForumSeedingService.clearAllForums();
```

## Data Structure

Sample threads are stored with this structure in Firestore:

```
forums/
├── GLOBAL_GLOBAL/
│   └── threads/
│       ├── thread_id_1/
│       │   ├── id, title, question, authorId, authorName, timestamp
│       │   └── replies/
│       │       ├── reply_id_1/
│       │       │   └── replies/ (nested replies)
│       │       └── reply_id_2/
│       └── thread_id_2/
├── UNIVERSITY_<universityId>/
│   └── threads/
├── FACULTY_<universityId>_<facultyId>/
│   └── threads/
└── DEPARTMENT_<universityId>_<facultyId>_<departmentId>/
    └── threads/
```

## IDs Used in Sample Data

Default IDs for testing:
- **University**: `TECH_UNIVERSITY_ID`
- **Faculty**: `TECHNOLOGY_FACULTY_ID`
- **Department**: `CS_DEPT_ID`

Update these in `ForumSeedingService` methods if needed for your actual university structure.

## Migration to Production

When moving to production:
1. Keep this sample data in the file
2. Modify `_initializeForumData()` to only seed on first app launch
3. Implement proper data management UI (admin panel) for adding/managing forums
4. Consider moving to a separate admin API for data seeding

## Sample Thread Topics

### Global Forum
- Community guidelines and introductions
- Career and learning resources
- General announcements

### University Forum
- Course registration and academic policies
- Campus facilities and services
- Student organizations and events

### Faculty Forum
- Research opportunities
- Course-specific discussions
- Project ideas and collaboration

### Department Forum
- Club meetings and activities
- Course discussions with instructors
- Capstone and design projects

## Notes

- All timestamps are relative to the documentation date
- Author IDs follow pattern: `user_XXX` or `prof_XXX` or `admin_XXX`
- Replies support unlimited nesting depth
- Sample data includes realistic, diverse discussion topics
