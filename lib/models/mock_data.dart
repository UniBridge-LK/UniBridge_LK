import 'thread_model.dart';
import 'event_model.dart';

final universityStructure = {
  'University of Moratuwa': {
    'Faculty of Engineering': ['Civil Engineering', 'Computer Science & Engineering', 'Electrical Engineering'],
    'Faculty of Information & Technology': ['IT'],
    'Faculty of Building Economy': ['Building & Property Management'],
  },
  'University of Colombo': {
    'Faculty of Medicine': ['MBBS', 'Physiotherapy'],
    'Faculty of Law': ['Law'],
    'Faculty of Science': ['Physics', 'Chemistry'],
  },
};



final mockGlobalThreads = [
  ThreadModel(id: '101', title: "Which degree to choose after A/L?", author: "Student X", timestamp: DateTime.now().subtract(Duration(hours:1)), content: "I'm confused about which science degree offers the best career path. Please share advice.", userId: 'u1_mock', uni: "University of Moratuwa", course: "General", replyCount: 15, likes: []),
  ThreadModel(id: '102', title: "Is the IT job market saturated in 2026?", author: "Alumni Y", timestamp: DateTime.now().subtract(Duration(hours:2)), content: "Alumni perspective needed: How competitive is the IT sector expected to be in the next few years?", userId: 'u2_mock', uni: "University of Peradeniya", course: "Medicine", replyCount: 8, likes: []),
  ThreadModel(id: '103', title: "General guidance on campus life balance.", author: "Dr. Z", timestamp: DateTime.now().subtract(Duration(hours:3)), content: "Tips on balancing studies, social life, and mental health during your undergraduate years.", userId: 'u1_mock', uni: "University of Colombo", course: "Arts", replyCount: 25, likes: []),
];
