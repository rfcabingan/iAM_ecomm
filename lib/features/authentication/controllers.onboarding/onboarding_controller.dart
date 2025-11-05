import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  //Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  // Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  // Jump tp the specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  //Update Current index and jump to next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      // Get.to(LoginScreen());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  //Update Current Index and jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
