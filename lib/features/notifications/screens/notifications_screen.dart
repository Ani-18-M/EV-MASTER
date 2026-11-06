import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../dashboard/widgets/sidebar_navigation.dart';
import '../../dashboard/widgets/top_header_bar.dart';

class NotificationItem {
  final String title;
  final String body;
  final String time;
  final String group;
  final Color color;
  final IconData icon;
  final String type;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.group,
    required this.color,
    required this.icon,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _listController;

  final List<String> _filters = [
    'All',
    'Unread',
    'Charging',
    'Alerts',
    'System',
  ];
  String _selectedFilter = 'All';

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _notifications = [
      NotificationItem(
        title: 'Charging Complete',
        body: 'Tesla Model 3 charged to 80% at Downtown Station',
        time: '2 min ago',
        group: 'Today',
        color: AppColors.green,
        icon: Icons.check_circle_outline,
        type: 'Charging',
      ),
      NotificationItem(
        title: 'Low Battery Alert',
        body: 'BYD Atto 3 battery at 15% — find a station now',
        time: '18 min ago',
        group: 'Today',
        color: AppColors.amber,
        icon: Icons.warning_amber_rounded,
        type: 'Alerts',
      ),
      NotificationItem(
        title: 'Station Available',
        body: 'Your saved station SF Marina is now available',
        time: '1h ago',
        group: 'Today',
        color: AppColors.cyan,
        icon: Icons.ev_station,
        type: 'System',
      ),
      NotificationItem(
        title: 'Price Drop',
        body: 'Charging rate dropped to \$0.08/kWh at Palo Alto Hub',
        time: '3h ago',
        group: 'Today',
        color: AppColors.green,
        icon: Icons.trending_down,
        type: 'Alerts',
        isRead: true,
      ),
      NotificationItem(
        title: 'Session Started',
        body: 'Charging session started — 50kW DC Fast Charge',
        time: 'Yesterday',
        group: 'Yesterday',
        color: AppColors.cyan,
        icon: Icons.bolt,
        type: 'Charging',
        isRead: true,
      ),
      NotificationItem(
        title: 'Payment Processed',
        body: 'Payment of \$8.40 processed for session #4821',
        time: 'Yesterday',
        group: 'Yesterday',
        color: AppColors.green,
        icon: Icons.payment,
        type: 'System',
        isRead: true,
      ),
      NotificationItem(
        title: 'Maintenance Alert',
        body: 'Stall #4 at SF Marina is under maintenance',
        time: '2 days ago',
        group: 'Earlier',
        color: AppColors.red,
        icon: Icons.build,
        type: 'Alerts',
        isRead: true,
      ),
      NotificationItem(
        title: 'App Update',
        body: 'EV-MASTER v2.4 is now available with new features',
        time: '3 days ago',
        group: 'Earlier',
        color: AppColors.textMuted,
        icon: Icons.system_update,
        type: 'System',
        isRead: true,
      ),
    ];

    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _onMenuPressed() {
    _scaffoldKey.currentState?.openDrawer();
  }

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications.where((n) => n.type == _selectedFilter).toList();
  }

  Map<String, List<NotificationItem>> get _groupedNotifications {
    final filtered = _filteredNotifications;
    final map = <String, List<NotificationItem>>{};
    for (var n in filtered) {
      if (!map.containsKey(n.group)) map[n.group] = [];
      map[n.group]!.add(n);
    }
    return map;
  }

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _onNavSelected(int index) {
    AppRouter.navigate(context, index, AppRoutes.notifications);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.surface,
              child: SidebarNavigation(
                selectedIndex: AppRoutes.notifications,
                onItemSelected: (index) {
                  Navigator.pop(context);
                  _onNavSelected(index);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SidebarNavigation(
              selectedIndex: AppRoutes.notifications,
              isCollapsed: !isDesktop,
              onItemSelected: _onNavSelected,
            ),
          Expanded(
            child: Column(
              children: [
                TopHeaderBar(
                  currentIndex: AppRoutes.notifications,
                  showMenuButton: isMobile,
                  onMenuPressed: _onMenuPressed,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildFilters(),
                        const SizedBox(height: 24),
                        Expanded(child: _buildList()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notifications',
          style: AppTypography.display().copyWith(fontSize: 28),
        ),
        TextButton.icon(
          onPressed: _markAllRead,
          icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
          label: Text(
            'Mark all read',
            style: AppTypography.button().copyWith(color: AppColors.cyan),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                _listController.forward(from: 0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cyan.withValues(alpha: 0.1)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.cyan : Colors.transparent,
                  ),
                ),
                child: Text(
                  filter,
                  style: AppTypography.body(
                    color: isSelected
                        ? AppColors.cyan
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    final grouped = _groupedNotifications;

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_off, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: AppTypography.heading(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    int itemIndex = 0;

    return ListView.builder(
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final group = grouped.keys.elementAt(index);
        final items = grouped[group]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                group,
                style: AppTypography.heading(color: AppColors.textSecondary)
                    .copyWith(fontSize: 16),
              ),
            ),
            ...items.map((item) {
              final delay = itemIndex * 0.1;
              itemIndex++;
              return FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _listController,
                    curve: Interval(
                      delay.clamp(0.0, 1.0),
                      (delay + 0.4).clamp(0.0, 1.0),
                    ),
                  ),
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _listController,
                          curve: Interval(
                            delay.clamp(0.0, 1.0),
                            (delay + 0.4).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                  child: Dismissible(
                    key: Key(item.title + item.time),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      setState(() {
                        _notifications.remove(item);
                      });
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: AppColors.red.withValues(alpha: 0.2),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E2736),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                            shadows: [
                                              Shadow(
                                                color: Colors.white.withValues(
                                                  alpha: 0.65,
                                                ),
                                                offset: const Offset(0, 1),
                                                blurRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.time,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!item.isRead)
                              Container(
                                margin: const EdgeInsets.only(left: 12, top: 4),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF004D61),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
