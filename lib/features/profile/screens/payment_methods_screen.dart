import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../../core/widgets/ev_input_field.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _cards = [
    {
      'type': 'Visa',
      'last4': '4242',
      'expiry': '12/26',
      'name': 'CARDHOLDER',
      'isDefault': true,
      'colors': [Color(0xFF1A1F35), Color(0xFF2E3A59)],
    },
    {
      'type': 'Mastercard',
      'last4': '8810',
      'expiry': '08/25',
      'name': 'CARDHOLDER',
      'isDefault': false,
      'colors': [Color(0xFF3A1C20), Color(0xFF592E36)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _showAddCardSheet() {
    final TextEditingController numberController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Card', style: AppTypography.heading()),
              const SizedBox(height: 24),
              Text(
                'Card Number',
                style: AppTypography.body().copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              EvInputField(
                controller: numberController,
                hintText: '0000 0000 0000 0000',
                prefixIcon: Icons.credit_card,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiry',
                          style: AppTypography.body().copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        EvInputField(
                          controller: expiryController,
                          hintText: 'MM/YY',
                          prefixIcon: Icons.date_range,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CVV',
                          style: AppTypography.body().copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        EvInputField(
                          controller: cvvController,
                          hintText: '123',
                          prefixIcon: Icons.security,
                          keyboardType: TextInputType.number,
                          isPassword: true,
                          isObscured: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CyanButton(
                text: 'Save Card',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    ).whenComplete(() {
      numberController.dispose();
      expiryController.dispose();
      cvvController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment Methods', style: AppTypography.heading()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildCardList(),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: CyanButton(
                text: 'Add New Card',
                onPressed: _showAddCardSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.surfaceLight.withValues(
                    alpha: _shimmerAnimation.value,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        final card = _cards[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildBankCard(card),
        );
      },
    );
  }

  Widget _buildBankCard(Map<String, dynamic> card) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: card['colors'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          if (card['isDefault'])
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
        ],
        border: card['isDefault']
            ? Border.all(color: AppColors.cyan, width: 2)
            : null,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (card['isDefault'])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyan),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: AppTypography.body().copyWith(
                      color: AppColors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(),
              Text(
                card['type'],
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Text(
            '**** **** **** ${card['last4']}',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER',
                    style: AppTypography.body().copyWith(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    card['name'],
                    style: AppTypography.body().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: AppTypography.body().copyWith(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    card['expiry'],
                    style: AppTypography.body().copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
