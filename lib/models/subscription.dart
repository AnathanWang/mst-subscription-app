enum SubscriptionType { none, monthly, yearly }

class Subscription {
  final SubscriptionType type;
  final DateTime purchaseDate;

  Subscription({required this.type, required this.purchaseDate});

  bool get isActive => type != SubscriptionType.none;

  String get displayName {
    switch (type) {
      case SubscriptionType.monthly:
        return 'Месячная подписка';
      case SubscriptionType.yearly:
        return 'Годовая подписка';
      case SubscriptionType.none:
        return 'Нет подписки';
    }
  }

  DateTime get nextPaymentDate {
    switch (type) {
      case SubscriptionType.monthly:
        return purchaseDate.add(const Duration(days: 30));
      case SubscriptionType.yearly:
        return purchaseDate.add(const Duration(days: 365));
      case SubscriptionType.none:
        return DateTime.now();
    }
  }

  int get daysUntilNextPayment {
    if (!isActive) return 0;
    final difference = nextPaymentDate.difference(DateTime.now());
    return difference.inDays;
  }

  String get paymentPeriod {
    switch (type) {
      case SubscriptionType.monthly:
        return 'ежемесячно';
      case SubscriptionType.yearly:
        return 'ежегодно';
      case SubscriptionType.none:
        return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = SubscriptionType.values.firstWhere(
      (e) => e.toString() == typeString,
      orElse: () => SubscriptionType.none,
    );
    return Subscription(
      type: type,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );
  }

  factory Subscription.none() {
    return Subscription(
      type: SubscriptionType.none,
      purchaseDate: DateTime.now(),
    );
  }

  String getNextPaymentInfo() {
    if (!isActive) {
      return 'Подписка неактивна';
    }
    final daysLeft = daysUntilNextPayment;
    if (daysLeft <= 0) {
      return 'Платеж ожидается';
    }
    return 'Следующий платеж через $daysLeft ${_pluralizeDays(daysLeft)}';
  }

  String _pluralizeDays(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if (days % 10 >= 2 &&
        days % 10 <= 4 &&
        (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }
}
