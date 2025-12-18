import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'models/subscription.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final subscriptionService = SubscriptionService();
  await subscriptionService.init();
  runApp(MyApp(subscriptionService: subscriptionService));
}

class MyApp extends StatelessWidget {
  final SubscriptionService subscriptionService;

  const MyApp({Key? key, required this.subscriptionService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: RootScreen(subscriptionService: subscriptionService),
    );
  }
}

class RootScreen extends StatefulWidget {
  final SubscriptionService subscriptionService;

  const RootScreen({Key? key, required this.subscriptionService})
    : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    // Give time for splash screen perception
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              color: AppColors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.card_membership_rounded,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Subscription App',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return AppNavigationWrapper(
          subscriptionService: widget.subscriptionService,
        );
      },
    );
  }
}

class AppNavigationWrapper extends StatefulWidget {
  final SubscriptionService subscriptionService;

  const AppNavigationWrapper({Key? key, required this.subscriptionService})
    : super(key: key);

  @override
  State<AppNavigationWrapper> createState() => _AppNavigationWrapperState();
}

class _AppNavigationWrapperState extends State<AppNavigationWrapper> {
  late Future<AppState> _appStateFuture;

  @override
  void initState() {
    super.initState();
    _appStateFuture = _determineAppState();
  }

  Future<AppState> _determineAppState() async {
    final isOnboardingComplete = await widget.subscriptionService
        .isOnboardingComplete();
    final hasSubscription = await widget.subscriptionService
        .hasActiveSubscription();

    if (!isOnboardingComplete) {
      return AppState.onboarding;
    } else if (!hasSubscription) {
      return AppState.paywall;
    } else {
      return AppState.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppState>(
      future: _appStateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              color: AppColors.background,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final currentState = snapshot.data ?? AppState.onboarding;

        return _buildScreen(currentState);
      },
    );
  }

  Widget _buildScreen(AppState state) {
    switch (state) {
      case AppState.onboarding:
        return OnboardingScreen(onComplete: _handleOnboardingComplete);
      case AppState.paywall:
        return PaywallScreen(
          onSubscriptionSelected: _handleSubscriptionSelected,
        );
      case AppState.home:
        return HomeScreen(
          subscriptionService: widget.subscriptionService,
          onLogout: _handleLogout,
        );
    }
  }

  Future<void> _handleOnboardingComplete() async {
    await widget.subscriptionService.setOnboardingComplete(true);
    setState(() {
      _appStateFuture = Future.value(AppState.paywall);
    });
  }

  Future<void> _handleSubscriptionSelected(SubscriptionType type) async {
    final subscription = Subscription(type: type, purchaseDate: DateTime.now());
    await widget.subscriptionService.saveSubscription(subscription);
    setState(() {
      _appStateFuture = Future.value(AppState.home);
    });
  }

  Future<void> _handleLogout() async {
    await widget.subscriptionService.clearSubscription();
    await widget.subscriptionService.setOnboardingComplete(false);
    setState(() {
      _appStateFuture = Future.value(AppState.onboarding);
    });
  }
}

enum AppState { onboarding, paywall, home }
