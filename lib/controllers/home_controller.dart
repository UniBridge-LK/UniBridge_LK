import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mock_data.dart';
import '../models/university_model.dart';

class HomeController extends GetxController {
  final RxList<UniversityModel> _universities = <UniversityModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<UniversityModel> get universities => _universities;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _loadUniversities();
  }

  void _loadUniversities() {
    _isLoading.value = true;
    _error.value = '';

    _universities.bindStream(
      FirebaseFirestore.instance
          .collection('universities')
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          return UniversityModel.fromMap(doc.id, data);
        }).toList();
        _isLoading.value = false;
        return items;
      }),
    );
  }

  void openUniversity(UniversityModel uni) {
    Get.toNamed('/home/university', arguments: {'uni': uni.name, 'uniId': uni.id});
  }
}
