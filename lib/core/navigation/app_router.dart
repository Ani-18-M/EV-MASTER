import 'package:flutter/material.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/stations/screens/charging_stations_screen.dart';
import '../../features/vehicles/screens/my_vehicles_screen.dart';
import '../../features/vehicles/screens/vehicle_control_screen.dart';
import '../../features/analytics/screens/energy_usage_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

class AppRoutes {
  static const int home = 0;
  static const int stations = 1;
  static const int vehicles = 2;
  static const int vehicleControl = 3;
  static const int energy = 4;
  static const int map = 5;
  static const int profile = 6;
  static const int settings = 7;
  static const int notifications = 8;
}

class AppRouter {
  /// Navigates to a target route index using a pure silky cross-fade (Tesla / Apple Minimalist).
  ///
  /// - Zero lateral slide or scale distortion: sidebar & top header remain 100% rock-solid.
  /// - Fast 240ms duration with [Curves.easeInOutCubic] for smooth, velvety opacity dissolve.
  /// - If [currentIndex] equals [index], navigation is safely prevented.
  static void navigate(BuildContext context, int index, [int? currentIndex]) {
    if (currentIndex != null && index == currentIndex) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _buildScreen(index),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // The incoming screen smoothly fades in over the solid outgoing screen.
          // The outgoing screen stays 100% solid underneath, completely eliminating
          // any alpha drop or background canvas flickering.
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  static Widget _buildScreen(int index) {
    switch (index) {
      case AppRoutes.home:
        return const DashboardScreen();
      case AppRoutes.stations:
        return const ChargingStationsScreen();
      case AppRoutes.vehicles:
        return const MyVehiclesScreen();
      case AppRoutes.vehicleControl:
        return const VehicleControlScreen();
      case AppRoutes.energy:
        return const EnergyUsageScreen();
      case AppRoutes.map:
        return const MapScreen();
      case AppRoutes.profile:
        return const ProfileScreen();
      case AppRoutes.settings:
        return const SettingsScreen();
      case AppRoutes.notifications:
        return const NotificationsScreen();
      default:
        return const DashboardScreen();
    }
  }
}
