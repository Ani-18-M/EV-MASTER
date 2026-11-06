import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I start a charging session?',
      'a': 'Plug in your vehicle and navigate to the charging screen. If Auto-start is enabled, it will begin automatically. Otherwise, press the "Start Session" button.',
    },
    {
      'q': 'What payment methods are accepted?',
      'a': 'We accept all major credit cards (Visa, Mastercard, Amex), Apple Pay, and Google Pay. You can manage these in the Charging Settings.',
    },
    {
      'q': 'How do I add a new vehicle?',
      'a': 'Go to Vehicle Settings and select "Add Vehicle" from the dropdown. Enter your VIN or select your make and model manually.',
    },
    {
      'q': 'How do I read the energy usage charts?',
      'a': 'The analytics page shows a bar chart of your kWh usage per day. Cyan bars indicate off-peak usage, while grey bars indicate peak usage.',
    },
    {
      'q': 'How do I schedule a charging session?',
      'a': 'In Vehicle Settings, toggle "Scheduled Charging" and use the time picker to set your preferred start time.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 24),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.cyan,
          letterSpacing: 1.2,
        ),
      ),
    );
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
        title: Text('Help & Support', style: AppTypography.heading()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.0, 0.4),
                ),
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search FAQs...',
                      hintStyle: GoogleFonts.outfit(
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1E2736),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.2, 0.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Frequently Asked Questions'),
                    GlassContainer(
                      padding: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _faqs.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: Color(0xFF94A3B8), height: 1),
                        itemBuilder: (context, index) {
                          return ExpansionTile(
                            iconColor: const Color(0xFF0F172A),
                            collapsedIconColor: const Color(0xFF0F172A),
                            title: Text(
                              _faqs[index]['q']!,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Text(
                                  _faqs[index]['a']!,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF334155),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.4, 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Contact Us'),
                    GlassContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E2736),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.email,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              'Email Support',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            subtitle: Text(
                              'support@evmaster.app',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF0F172A),
                            ),
                            onTap: () {},
                          ),
                          const Divider(color: Color(0xFF94A3B8), height: 1),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E2736),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              'Live Chat',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            subtitle: Text(
                              'Typical reply in 5 mins',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF0F172A),
                            ),
                            onTap: () {},
                          ),
                          const Divider(color: Color(0xFF94A3B8), height: 1),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E2736),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              'Call Center',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            subtitle: Text(
                              '24/7 Support',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF334155),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF0F172A),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
            Center(
              child: Text(
                'EV-MASTER v2.4.0 • Build 2024.10',
                style: AppTypography.body(color: AppColors.textMuted)
                    .copyWith(fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
