import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:iam_ecomm/features/authentication/controllers/auth_controller.dart';
import 'package:iam_ecomm/features/authentication/screens/onboarding.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/local_storage/storage_utility.dart';
import 'package:iam_ecomm/utils/theme/theme.dart';
import 'package:iam_ecomm/utils/theme/theme_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // return GetMaterialApp(
    //
    //   themeMode: ThemeMode.system,
    //   theme: IAMTheme.lightTheme,
    //   darkTheme: IAMTheme.darkTheme,
    //   home: const OnBoardingScreen(),
    // );

    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }

    final themeController = ThemeController.instance;

    return Obx(
      () => GetMaterialApp(
        themeMode:
            themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: IAMTheme.lightTheme,
        darkTheme: IAMTheme.darkTheme,
        home: const _RootDecider(),
        builder: (context, child) =>
            _SessionActivityListener(child: child ?? const SizedBox.shrink()),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _SessionActivityListener extends StatefulWidget {
  const _SessionActivityListener({required this.child});

  final Widget child;

  @override
  State<_SessionActivityListener> createState() =>
      _SessionActivityListenerState();
}

class _SessionActivityListenerState extends State<_SessionActivityListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Get.isRegistered<AuthController>()) return;

    if (state == AppLifecycleState.resumed) {
      AuthController.instance.checkIdleTimeout();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AuthController.instance.persistCurrentActivity();
    }
  }

  void _recordActivity() {
    if (!Get.isRegistered<AuthController>()) return;
    AuthController.instance.recordUserActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _recordActivity(),
      onPointerMove: (_) => _recordActivity(),
      onPointerSignal: (_) => _recordActivity(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _recordActivity();
          return false;
        },
        child: widget.child,
      ),
    );
  }
}

/// Decides whether to show onboarding (first launch) or the main app shell.
class _RootDecider extends StatefulWidget {
  const _RootDecider();

  @override
  State<_RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<_RootDecider> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _loadFlag();
  }

  Future<void> _loadFlag() async {
    final storage = IAMLocalStorage();
    final flag =
        storage.readData<bool>(IAMLocalStorage.hasSeenOnboardingKey) ?? false;
    if (!mounted) return;
    setState(() {
      _hasSeenOnboarding = flag;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash/placeholder while we read from local storage.
    if (_hasSeenOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasSeenOnboarding == true) {
      // User has already seen onboarding: go straight to main app.
      return const NavigationMenu();
    }

    // First launch: show onboarding.
    return const OnBoardingScreen();
  }
}
