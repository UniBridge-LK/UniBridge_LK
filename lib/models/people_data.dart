// Dummy data for People directory - will be replaced with Firestore later

class PersonData {
  final String id;
  final String name;
  final String profileHeadline;
  final String avatarLetter;
  final String avatarColor;
  final String about;
  final String userType; // 'student', 'staff', 'alumnus'
  final String university;
  final String? faculty;
  final String? department;
  final String? photoUrl;

  PersonData({
    required this.id,
    required this.name,
    required this.profileHeadline,
    required this.avatarLetter,
    required this.avatarColor,
    required this.about,
    required this.userType,
    required this.university,
    this.faculty,
    this.department,
    this.photoUrl,
  });
}

final List<PersonData> dummyPeople = [
  PersonData(
    id: 'p1',
    name: 'Ahasa S.',
    profileHeadline: 'University of Moratuwa | 2023',
    avatarLetter: 'A',
    avatarColor: 'E8D5F5',
    about: 'Passionate about software engineering and AI. Currently pursuing Computer Science degree.',
    userType: 'student',
    university: 'University of Moratuwa',
    faculty: 'Faculty of Information Technology',
    department: 'Computer Science & Engineering',
  ),
  PersonData(
    id: 'p2',
    name: 'Dr. S. K. Silva',
    profileHeadline: 'University of Colombo | Senior Lecturer',
    avatarLetter: 'D',
    avatarColor: 'D5E0F5',
    about: 'Senior Lecturer specializing in Database Systems and Software Architecture. 15+ years of teaching experience.',
    userType: 'staff',
    university: 'University of Colombo',
    faculty: 'Faculty of Science',
    department: 'Computer Science',
  ),
  PersonData(
    id: 'p3',
    name: 'Zain M.',
    profileHeadline: 'SLIIT | Alumnus',
    avatarLetter: 'Z',
    avatarColor: 'F5D5E8',
    about: 'Software engineer at leading tech company. SLIIT Computer Science graduate. Interested in mentoring students.',
    userType: 'alumnus',
    university: 'SLIIT',
    faculty: 'Faculty of Computing',
    department: 'Computer Science',
  ),
  PersonData(
    id: 'p4',
    name: 'Priya R.',
    profileHeadline: 'University of Peradeniya | Computer Science',
    avatarLetter: 'P',
    avatarColor: 'D5F5E8',
    about: 'Third year undergraduate exploring data science and machine learning. Looking to connect with industry professionals.',
    userType: 'student',
    university: 'University of Peradeniya',
    faculty: 'Faculty of Science',
    department: 'Computer Science',
  ),
  PersonData(
    id: 'p5',
    name: 'Kumar J.',
    profileHeadline: 'University of Moratuwa | Engineering Faculty',
    avatarLetter: 'K',
    avatarColor: 'F5E8D5',
    about: 'Mechanical Engineering student interested in robotics and automation.',
    userType: 'student',
    university: 'University of Moratuwa',
    faculty: 'Faculty of Engineering',
    department: 'Mechanical Engineering',
  ),
];
