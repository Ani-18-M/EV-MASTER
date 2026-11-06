import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ev_master/core/theme/app_theme.dart';
import 'package:ev_master/features/auth/screens/login_screen.dart';
import 'package:ev_master/features/auth/screens/signup_screen.dart';
import 'package:ev_master/features/dashboard/screens/dashboard_screen.dart';
import 'package:ev_master/features/stations/screens/charging_stations_screen.dart';
import 'package:ev_master/features/stations/screens/station_details_screen.dart';
import 'package:ev_master/features/charging/screens/start_charging_screen.dart';
import 'package:ev_master/features/vehicles/screens/my_vehicles_screen.dart';
import 'package:ev_master/features/vehicles/screens/vehicle_control_screen.dart';
import 'package:ev_master/features/analytics/screens/energy_usage_screen.dart';
import 'package:ev_master/features/map/screens/map_screen.dart';
import 'package:ev_master/features/map/screens/navigation_route_screen.dart';
import 'package:ev_master/core/widgets/floatable_tile.dart';

void main() {
  testWidgets('Screen 1: LoginScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const LoginScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to your EV-MASTER account'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('Screen 2: SignupScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const SignupScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Join the EV revolution. Charge, Control, Drive.'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
  });

  testWidgets('Screen 3: DashboardScreen renders correctly on desktop and mobile', (tester) async {
    // 1. Desktop Viewport
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.text('Drive Cleaner. Live Greener.'), findsOneWidget);
    expect(find.text('Total Charges'), findsOneWidget);
    expect(find.text('Active Vehicles'), findsOneWidget);
    expect(find.text('Energy Consumed'), findsOneWidget);
    expect(find.text('Charge Smarter'), findsOneWidget);
    expect(find.text('Nearby Charging Stations'), findsOneWidget);
    expect(find.text('GreenCharge Station'), findsOneWidget);
    expect(find.byType(FloatableTile), findsNWidgets(7));

    // 2. Mobile Viewport (2 tiles per row, zero overflow, all cards present)
    tester.view.physicalSize = const Size(390, 844);
    await tester.pump();

    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.text('Total Charges'), findsOneWidget);
    expect(find.text('Active Vehicles'), findsOneWidget);
    expect(find.text('Energy Consumed'), findsOneWidget);
    expect(find.text('CO₂ Offset'), findsOneWidget);
    expect(find.text('Charge Smarter'), findsOneWidget);
    expect(find.text('Find Charging Stations'), findsOneWidget);
    expect(find.text('Nearby Charging Stations'), findsOneWidget);
    expect(find.text('GreenCharge Station'), findsOneWidget);
    expect(find.text('CityCharge Hub'), findsOneWidget);
    expect(find.text('Tesla Supercharger'), findsOneWidget);
    expect(find.byType(FloatableTile), findsNWidgets(8));
  });

  testWidgets('Screen 4: ChargingStationsScreen renders correctly', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const ChargingStationsScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Charging Stations'), findsNWidgets(2));
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Slow'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('GreenCharge Station'), findsOneWidget);
    expect(find.text('City Mall Charging Hub'), findsOneWidget);
    expect(find.text('Riverside Station'), findsOneWidget);
    expect(find.text('Tech Park Station'), findsOneWidget);

    // Test Navigation interaction
    await tester.tap(find.text('Navigate').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Route to GreenCharge Station'), findsOneWidget);

    // Test Filter Modal interaction
    await tester.tap(find.text('Filter'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Filter Charging Stations'), findsOneWidget);
    expect(find.text('Show Available Only'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);
  });

  testWidgets('Screen 5: StationDetailsScreen renders correctly', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const testStation = StationData(
      id: '1',
      name: 'GreenCharge Station',
      distance: '1.2 km',
      availability: '2/4 Available',
      power: 'DC Fast (120 kW)',
      isFast: true,
      address: '1.2 km • Open 24/7',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const StationDetailsScreen(station: testStation),
      ),
    );
    await tester.pump();

    expect(find.text('GreenCharge Station'), findsOneWidget);
    expect(find.text('Stalls'), findsOneWidget);
    expect(find.text('Battery Plan'), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Amenities'), findsOneWidget);
    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('Start Charging'), findsOneWidget);
    expect(find.text('Live Stall Bay Status'), findsOneWidget);

    // Switch to Battery Plan
    await tester.tap(find.text('Battery Plan'));
    await tester.pump();
    expect(find.text('Pre-condition Battery Pack'), findsOneWidget);

    // Switch to Pricing
    await tester.tap(find.text('Pricing'));
    await tester.pump();
    expect(find.text('24-Hour Time-of-Use Tariff Schedule'), findsOneWidget);
    expect(find.text('Target Charge Level'), findsOneWidget);

    // Switch to Amenities
    await tester.tap(find.text('Amenities'));
    await tester.pump();
    expect(find.text('Plug Reliability Score'), findsOneWidget);
  });

  testWidgets('Screen 6: StartChargingScreen renders correctly', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const testStation = StationData(
      id: '1',
      name: 'GreenCharge Station',
      distance: '1.2 km',
      availability: '2/4 Available',
      power: 'DC Fast (120 kW)',
      isFast: true,
      address: '1.2 km • Open 24/7',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const StartChargingScreen(station: testStation),
      ),
    );
    await tester.pump();

    expect(find.text('GreenCharge Station'), findsOneWidget);
    expect(find.text('Connecting to charger...'), findsOneWidget);
    expect(find.text('Stall #4 Selected'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Screen 7: MyVehiclesScreen renders correctly on desktop and mobile', (tester) async {
    // Mobile Viewport
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const MyVehiclesScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('My Vehicles'), findsOneWidget);
    expect(find.text('Tesla Model 3'), findsWidgets);
    expect(find.text('View Details'), findsWidgets);
    expect(find.text('Control'), findsWidgets);
    expect(find.text('Quick Stats'), findsOneWidget);
  });

  testWidgets('Screen 8: VehicleControlScreen renders correctly on desktop and mobile', (tester) async {
    // Mobile Viewport
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const VehicleControlScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Tesla'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
    expect(find.text('Climate'), findsOneWidget);
    expect(find.text('Charge Port'), findsOneWidget);
  });

  testWidgets('Screen 9: EnergyUsageScreen renders correctly on desktop and mobile', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const EnergyUsageScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Energy Usage'), findsWidgets);
    expect(find.text('Total kWh this week'), findsOneWidget);
    expect(find.text('Vehicle Breakdown'), findsOneWidget);
    expect(find.text('Efficiency Trend'), findsOneWidget);
    expect(find.text('Start New Session'), findsOneWidget);
  });

  testWidgets('Screen 10: MapScreen renders correctly and navigates to route guidance', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const MapScreen(),
      ),
    );
    await tester.pump();

    // Verify key elements matching the reference image media_1790973912551.jpg
    expect(find.text('City Mall'), findsOneWidget);
    expect(find.text('City Mall Charging Hub'), findsOneWidget);
    expect(find.text('2.4 km  •  Open 24/7'), findsOneWidget);
    expect(find.text('AC (22 kW)'), findsOneWidget);
    expect(find.text('Navigate'), findsOneWidget);

    // Tap Navigate button and verify sub-screen opens
    await tester.tap(find.text('Navigate'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(NavigationRouteScreen), findsOneWidget);
    expect(find.text('Route Guidance'), findsOneWidget);
    expect(find.text('In 400 m'), findsOneWidget);
    expect(find.text('Arrived • Start Charging'), findsOneWidget);
  });
}


