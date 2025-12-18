import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class SubscriptionService {
  static const String _subscriptionKey = 'subscription_data';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveSubscription(Subscription subscription) async {
    final jsonString = jsonEncode(subscription.toJson());
    await _prefs.setString(_subscriptionKey, jsonString);
  }

  Future<Subscription> getSubscription() async {
    final jsonString = _prefs.getString(_subscriptionKey);
    if (jsonString == null) {
      return Subscription.none();
    }
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return Subscription.fromJson(json);
    } catch (e) {
      return Subscription.none();
    }
  }

  Future<void> clearSubscription() async {
    await _prefs.remove(_subscriptionKey);
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_onboardingCompleteKey, complete);
  }

  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<bool> hasActiveSubscription() async {
    final subscription = await getSubscription();
    return subscription.isActive;
  }
}
