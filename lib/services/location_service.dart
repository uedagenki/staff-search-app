import 'package:geolocator/geolocator.dart';
import 'dart:math';

class LocationService {
  // 現在地を取得
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // 位置情報サービスが有効かチェック
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Web版のフォールバック: 東京駅の座標を返す
        return Position(
          latitude: 35.6812,
          longitude: 139.7671,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Web版のフォールバック: 東京駅の座標を返す
          return Position(
            latitude: 35.6812,
            longitude: 139.7671,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Web版のフォールバック: 東京駅の座標を返す
        return Position(
          latitude: 35.6812,
          longitude: 139.7671,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      // エラー時のフォールバック: 東京駅の座標を返す
      return Position(
        latitude: 35.6812,
        longitude: 139.7671,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  // 2点間の距離を計算（km）
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 地球の半径（km）

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // 距離を人間が読みやすい形式に変換
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  // デモ用：東京都内のランダムな座標を生成
  Map<String, double> getDemoLocation(int seed) {
    final random = Random(seed);
    // 東京都庁周辺の座標範囲
    final double baseLat = 35.6762;
    final double baseLon = 139.6503;
    
    // ±0.05度の範囲でランダム（約5km圏内）
    final double lat = baseLat + (random.nextDouble() - 0.5) * 0.1;
    final double lon = baseLon + (random.nextDouble() - 0.5) * 0.1;
    
    return {'lat': lat, 'lon': lon};
  }
}
