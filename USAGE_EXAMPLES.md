# Примеры использования Subscription App

## 1. Инициализация приложения

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final subscriptionService = SubscriptionService();
  await subscriptionService.init();
  runApp(MyApp(subscriptionService: subscriptionService));
}
```

## 2. Работа с SubscriptionService

### Инициализация сервиса
```dart
final service = SubscriptionService();
await service.init();
```

### Сохранение подписки
```dart
final subscription = Subscription(
  type: SubscriptionType.yearly,
  purchaseDate: DateTime.now(),
);
await service.saveSubscription(subscription);
```

### Получение подписки
```dart
final subscription = await service.getSubscription();
print(subscription.displayName); // "Годовая подписка"
print(subscription.isActive); // true
```

### Проверка активной подписки
```dart
final hasActive = await service.hasActiveSubscription();
if (hasActive) {
  print('Подписка активна');
}
```

### Очистка подписки
```dart
await service.clearSubscription();
```

### Управление состоянием онбординга
```dart
// Отметить онбординг как завершенный
await service.setOnboardingComplete(true);

// Проверить, завершен ли онбординг
final isComplete = await service.isOnboardingComplete();
```

## 3. Работа с моделью Subscription

### Создание подписки
```dart
// Месячная подписка
final monthly = Subscription(
  type: SubscriptionType.monthly,
  purchaseDate: DateTime.now(),
);

// Годовая подписка
final yearly = Subscription(
  type: SubscriptionType.yearly,
  purchaseDate: DateTime.now(),
);

// Подписка "нет"
final none = Subscription.none();
```

### Получение информации о подписке
```dart
final subscription = Subscription(
  type: SubscriptionType.yearly,
  purchaseDate: DateTime.now(),
);

// Проверка активности
print(subscription.isActive); // true

// Название подписки
print(subscription.displayName); // "Годовая подписка"

// Периодичность платежей
print(subscription.paymentPeriod); // "ежегодно"

// Дата следующего платежа
print(subscription.nextPaymentDate); // DateTime в будущем

// Дни до платежа
print(subscription.daysUntilNextPayment); // 365

// Информация о платеже с правильным склонением
print(subscription.getNextPaymentInfo()); 
// "Следующий платеж через 365 дней"
```

### Сериализация подписки
```dart
final subscription = Subscription(
  type: SubscriptionType.monthly,
  purchaseDate: DateTime.now(),
);

// Преобразование в JSON
final json = subscription.toJson();
// {'type': 'SubscriptionType.monthly', 'purchaseDate': '2024-...'}

// Восстановление из JSON
final restored = Subscription.fromJson(json);
```

## 4. Навигация между экранами

### Жизненный цикл навигации
```dart
// RootScreen автоматически определяет, какой экран показывать:

// 1. Если онбординг не завершен → показывает OnboardingScreen
// 2. Если онбординг завершен, но нет подписки → показывает PaywallScreen
// 3. Если подписка активна → показывает HomeScreen
```

### Программный переход между экранами
```dart
// В RootScreen (_RootScreenState):

// Завершение онбординга
await widget.subscriptionService.setOnboardingComplete(true);
setState(() {
  _appStateFuture = Future.value(AppState.paywall);
});

// Выбор подписки
final subscription = Subscription(
  type: SubscriptionType.yearly,
  purchaseDate: DateTime.now(),
);
await widget.subscriptionService.saveSubscription(subscription);
setState(() {
  _appStateFuture = Future.value(AppState.home);
});

// Выход из аккаунта
await widget.subscriptionService.clearSubscription();
await widget.subscriptionService.setOnboardingComplete(false);
setState(() {
  _appStateFuture = Future.value(AppState.onboarding);
});
```

## 5. Использование OnboardingScreen

```dart
OnboardingScreen(
  onComplete: () {
    // Вызывается при завершении онбординга
    // Переходит на экран Paywall
  },
)
```

## 6. Использование PaywallScreen

```dart
PaywallScreen(
  onSubscriptionSelected: (subscriptionType) {
    // Вызывается при выборе подписки
    // subscriptionType: SubscriptionType.monthly или SubscriptionType.yearly
    
    final subscription = Subscription(
      type: subscriptionType,
      purchaseDate: DateTime.now(),
    );
    // Сохраняем подписку и переходим на главный экран
  },
)
```

## 7. Использование HomeScreen

```dart
HomeScreen(
  subscriptionService: subscriptionService,
  onLogout: () {
    // Вызывается при нажатии кнопки выхода
    // Очищает подписку и возвращает на онбординг
  },
)
```

## 8. Использование SubscriptionCard

```dart
SubscriptionCard(
  type: SubscriptionType.monthly,
  title: 'Месячная подписка',
  price: '299 ₽',
  period: 'в месяц',
  discount: null, // или 'Скидка' для годовой
  isSelected: true,
  onTap: () {
    // Обработка выбора
  },
)
```

## 9. Полные примеры сценариев

### Сценарий 1: Первый запуск приложения
```dart
// 1. Пользователь видит OnboardingScreen
// 2. Нажимает "Начать" → переход на PaywallScreen
// 3. Выбирает годовую подписку → PaywallScreen эмулирует покупку
// 4. После успешной покупки → HomeScreen с активной подпиской
// 5. SharedPreferences сохраняет состояние
```

### Сценарий 2: Повторный запуск после сохранения
```dart
// 1. SharedPreferences загружает:
//    - onboarding_complete = true
//    - subscription_data = {тип, дата}
// 2. RootScreen определяет AppState.home
// 3. Сразу показывается HomeScreen с подпиской
```

### Сценарий 3: Выход из аккаунта
```dart
// 1. Пользователь нажимает кнопку logout
// 2. Показывается диалог подтверждения
// 3. При подтверждении:
//    - Очищается подписка
//    - Очищается флаг онбординга
//    - Возврат на OnboardingScreen
```

## 10. Расширение функционала

### Добавление новой подписки
```dart
// В models/subscription.dart добавить новый тип:
enum SubscriptionType { none, monthly, yearly, premium }

// Обновить методы displayName, paymentPeriod и т.д.
```

### Интеграция с реальной системой платежей
```dart
// В PaywallScreen заменить эмуляцию на реальный платеж:
Future<void> _processPurchase() async {
  // Инициировать Apple Pay или Google Play Billing
  final result = await _paymentService.processPurchase(
    productId: _selectedType == SubscriptionType.monthly 
      ? 'monthly_sub' 
      : 'yearly_sub',
  );
  
  if (result.success) {
    // Сохранить подписку
    await _subscriptionService.saveSubscription(
      Subscription(
        type: _selectedType!,
        purchaseDate: DateTime.now(),
      ),
    );
  }
}
```

### Добавление экрана подробной информации
```dart
// Создать новый экран SubscriptionDetailsScreen
// Добавить кнопку на HomeScreen для перехода
// Использовать Navigator.push для открытия
```

## 11. Полезные утилиты

### Проверка, скоро ли следующий платеж
```dart
extension SubscriptionExt on Subscription {
  bool isPaymentSoon({int days = 7}) {
    return daysUntilNextPayment <= days && daysUntilNextPayment > 0;
  }
}

// Использование
if (subscription.isPaymentSoon()) {
  print('Платеж ожидается в течение недели');
}
```

### Форматирование даты платежа
```dart
String formatPaymentDate(DateTime date) {
  final months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
```

---

**Дополнительная информация**: Все примеры работают с текущей архитектурой приложения. Для большинства сценариев рекомендуется использовать SubscriptionService для всех операций с подписками.