import 'package:get/get.dart';
import '../services/persistence_service.dart';

class MainController extends GetxController {
  final index = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Restore last tab on app launch
    final lastTab = PersistenceService.getLastTabIndex();
    index.value = lastTab;
  }

  void setIndex(int i) {
    index.value = i;
    // Persist navigation state
    PersistenceService.saveNavState(tabIndex: i);
  }
}
