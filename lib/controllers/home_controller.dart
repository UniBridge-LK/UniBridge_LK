import 'package:get/get.dart';
import '../models/mock_data.dart';

class HomeController extends GetxController {
  List<String> get universityNames => universityStructure.keys.toList();

  void openUniversity(String uniName) {
    final faculties = Map<String, List<String>>.from(universityStructure[uniName] ?? {});
    Get.toNamed('/home/university', arguments: {'uni': uniName, 'faculties': faculties});
  }
}
