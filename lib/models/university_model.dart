class UniversityModel {
  final String id;
  final String name;

  UniversityModel({required this.id, required this.name});

  factory UniversityModel.fromMap(String id, Map<String, dynamic> map) {
    final name = (map['name'] ?? '').toString();
    return UniversityModel(id: id, name: name);
  }
}
// 💡 University Model
class University {
  final String id;
  final String name;

  University({required this.id, required this.name});

  // Method to map the object to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}

// 💡 Faculty Model
class Faculty {
  final String id;
  final String name;
  final String universityId; // The reference to the parent university

  Faculty({required this.id, required this.name, required this.universityId});

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'universityId': universityId,
    };
  }
}

// 💡 Department Model
class Department {
  final String id;
  final String name;
  final String facultyId; // The reference to the parent faculty

  Department({required this.id, required this.name, required this.facultyId});

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'facultyId': facultyId,
    };
  }
}