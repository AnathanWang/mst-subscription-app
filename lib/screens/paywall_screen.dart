import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/subscription.dart';
import '../widgets/subscription_card.dart';

class PaywallScreen extends StatefulWidget {
  final Function(SubscriptionType) onSubscriptionSelected;

  const PaywallScreen({Key? key, required this.onSubscriptionSelected})
    : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  SubscriptionType? _selectedType;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Выберите план подписки',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Получите полный доступ ко всем премиум-функциям',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                // Monthly subscription card
                SubscriptionCard(
                  type: SubscriptionType.monthly,
                  title: 'Месячная подписка',
                  price: '299 ₽',
                  period: 'в месяц',
                  isSelected: _selectedType == SubscriptionType.monthly,
                  onTap: () {
                    setState(() {
                      _selectedType = SubscriptionType.monthly;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Yearly subscription card
                SubscriptionCard(
                  type: SubscriptionType.yearly,
                  title: 'Годовая подписка',
                  price: '2 490 ₽',
                  period: 'в год',
                  discount: 'Экономия 1 098 ₽',
                  isSelected: _selectedType == SubscriptionType.yearly,
                  onTap: () {
                    setState(() {
                      _selectedType = SubscriptionType.yearly;
                    });
                  },
                ),
                const SizedBox(height: 40),
                // Features list
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Включено в подписку:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem('Полный доступ к контенту'),
                      _buildFeatureItem('Премиум поддержка'),
                      _buildFeatureItem('Синхронизация между устройствами'),
                      _buildFeatureItem('Без рекламы'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedType != null && !_isProcessing
                        ? _processPurchase
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.textLighter,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Продолжить',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Платеж обрабатывается безопасно',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLighter,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase() async {
    if (_selectedType == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    widget.onSubscriptionSelected(_selectedType!);
  }
}
