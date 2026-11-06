import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:ev_master/core/services/ev_map_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EvMapService Location & Nearby Stations Tests', () {
    test('calculateDistanceKm computes accurate distance', () {
      const locA = LatLng(12.9716, 77.5946); // Bangalore
      const locB = LatLng(13.0827, 80.2707); // Chennai (~290 km)

      final distance = EvMapService.calculateDistanceKm(locA, locB);
      expect(distance, greaterThan(250.0));
      expect(distance, lessThan(350.0));
    });

    test('getUserLocation returns UserLocationResult', () async {
      final result = await EvMapService.getUserLocation(requestIfNeeded: false);
      expect(result, isA<UserLocationResult>());
      expect(result.location, isNotNull);
      expect(result.status, isA<LocationAccessStatus>());
    });

    test('getCuratedStationsAround returns stations sorted around given center', () {
      const customCenter = LatLng(28.6139, 77.2090); // New Delhi
      final stations = EvMapService.getCuratedStationsAround(customCenter);

      expect(stations.length, greaterThanOrEqualTo(5));
      for (final st in stations) {
        expect(st.title, isNotEmpty);
        expect(st.distance, isNotEmpty);
        expect(st.power, isNotEmpty);
        // Location should be localized around customCenter
        expect((st.location.latitude - customCenter.latitude).abs(), lessThan(0.1));
        expect((st.location.longitude - customCenter.longitude).abs(), lessThan(0.1));
      }
    });
  });
}
