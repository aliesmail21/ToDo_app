import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  static OnboardingController get to => Get.find();

  final _isFirstTime = true.obs;
  bool get isFirstTime => _isFirstTime.value;

  @override
  void onInit() {
    super.onInit();
    checkFirstTime();
  }

  Future<void> checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('isFirstTime');
      _isFirstTime.value = hasSeenOnboarding ?? true;
    } catch (e) {
      print('Error checking first time status: $e');
      _isFirstTime.value = true;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      _isFirstTime.value = false;
    } catch (e) {
      print('Error completing onboarding: $e');
    }
  }
}
