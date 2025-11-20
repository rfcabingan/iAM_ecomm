import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final carouselContextIndex = 0.obs;

  void updatePageIndicator(index) {
    carouselContextIndex.value = index;
  }
}
