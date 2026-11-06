import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cyan_button.dart';
import '../../../core/widgets/ev_input_field.dart';
import '../../../core/widgets/glass_container.dart';

// import 'my_vehicles_screen.dart'; // Ensure it's imported if needed

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<String> _brands = [
    'Tesla',
    'BYD',
    'Hyundai',
    'Kia',
    'BMW',
    'Audi',
    'Rivian',
    'NIO',
  ];
  String? _selectedBrand;

  final Map<String, List<String>> _models = {
    'Tesla': ['Model 3', 'Model Y', 'Model S', 'Model X', 'Cybertruck'],
    'BYD': ['Seal', 'Atto 3', 'Dolphin', 'Han'],
    'Hyundai': ['Ioniq 5', 'Ioniq 6', 'Kona Electric'],
    'Kia': ['EV6', 'EV9', 'Niro EV'],
    'BMW': ['i4', 'iX', 'i7'],
    'Audi': ['e-tron', 'Q4 e-tron', 'GT e-tron'],
    'Rivian': ['R1T', 'R1S'],
    'NIO': ['ET7', 'ES8', 'ET5'],
  };
  String? _selectedModel;

  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  String _selectedYear = '2024';
  Color _selectedColor = Colors.white;

  final List<Color> _carColors = [
    Colors.white,
    Colors.black,
    Colors.grey,
    Colors.red,
    Colors.blue,
    AppColors.cyan,
    Colors.green,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _licensePlateController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
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
          onPressed: _prevStep,
        ),
        title: Text('Add Vehicle', style: AppTypography.heading()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBrandStep(),
                  _buildModelStep(),
                  _buildDetailsStep(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          if (index % 2 != 0) {
            int stepIndex = index ~/ 2;
            bool isActive = _currentStep > stepIndex;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 2,
                color: isActive ? AppColors.cyan : AppColors.surfaceLight,
              ),
            );
          } else {
            int stepIndex = index ~/ 2;
            bool isActive = _currentStep >= stepIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.cyan : AppColors.surfaceLight,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.cyanGlow,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildBrandStep() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _brands.length,
      itemBuilder: (context, index) {
        final brand = _brands[index];
        final isSelected = _selectedBrand == brand;
        return GestureDetector(
          onTap: () => setState(() => _selectedBrand = brand),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.cyan.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.cyan : AppColors.surfaceLight,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car, size: 40, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  brand,
                  style: AppTypography.body().copyWith(
                    color: isSelected ? AppColors.cyan : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModelStep() {
    final models = _selectedBrand != null ? _models[_selectedBrand!]! : [];
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        final isSelected = _selectedModel == model;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _selectedModel = model),
            borderRadius: BorderRadius.circular(16),
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              borderColor: isSelected ? AppColors.cyan : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E2736),
                    ),
                    child: const Icon(
                      Icons.electric_car,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    model,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E2736),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Year',
            style: AppTypography.body().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceLight),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedYear,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: List.generate(6, (index) => (2020 + index).toString())
                    .map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year, style: AppTypography.body()),
                      );
                    })
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedYear = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'License Plate',
            style: AppTypography.body().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          EvInputField(
            controller: _licensePlateController,
            hintText: 'e.g., EV 1234',
            prefixIcon: Icons.badge,
          ),
          const SizedBox(height: 24),
          Text(
            'Color',
            style: AppTypography.body().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _carColors.map((color) {
              bool isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.cyan : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Nickname (Optional)',
            style: AppTypography.body().copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          EvInputField(
            controller: _nicknameController,
            hintText: 'e.g., My Daily Driver',
            prefixIcon: Icons.directions_car,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    bool canProceed =
        (_currentStep == 0 && _selectedBrand != null) ||
        (_currentStep == 1 && _selectedModel != null) ||
        (_currentStep == 2);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Opacity(
        opacity: canProceed ? 1.0 : 0.45,
        child: CyanButton(
          text: _currentStep == 2 ? 'Add Vehicle' : 'Next',
          onPressed: canProceed ? _nextStep : () {},
        ),
      ),
    );
  }
}
