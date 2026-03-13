import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/job_category.dart';
import '../models/portfolio_photo.dart';
import '../models/staff.dart';
import '../models/staff_profile.dart';
import '../services/api_client.dart';

class StaffService {
  static final StaffService instance = StaffService._();
  StaffService._();

  final _storage = const FlutterSecureStorage();
  List<JobCategory>? _cachedCategories;

  Future<List<JobCategory>> getJobCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    final token = await _storage.read(key: 'access_token');
    final resp = await http.get(
      Uri.parse('$kApiBaseUrl/api/v1/staff/job-categories'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else {
        throw Exception('Unexpected response format');
      }
      _cachedCategories = list
          .map((e) => JobCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      return _cachedCategories!;
    }
    throw Exception('Failed to load categories: ${resp.statusCode}');
  }

  Future<List<Staff>> getStaffList({String? category, String? cursor, int limit = 20}) async {
    final params = <String, String>{'limit': limit.toString()};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (cursor != null) params['cursor'] = cursor;

    final resp = await ApiClient().get('/api/v1/staff', queryParams: params);
    if (resp.isSuccess && resp.data != null) {
      final list = resp.data!['staff'] as List<dynamic>? ?? [];
      return list.map((e) => Staff.fromApiResponse(e as Map<String, dynamic>)).toList();
    }
    throw Exception(resp.message ?? 'Failed to load staff list.');
  }

  Future<StaffProfile> createProfile(Map<String, dynamic> req) async {
    final resp = await ApiClient().post('/api/v1/staff/profile', req);
    if (resp.isSuccess && resp.data != null) {
      return StaffProfile.fromJson(resp.data!);
    }
    if (resp.statusCode == 409) {
      throw Exception('You already have a staff profile.');
    }
    throw Exception(resp.message ?? 'Failed to create staff profile.');
  }

  Future<StaffProfile> updateProfile(Map<String, dynamic> req) async {
    final resp = await ApiClient().patch('/api/v1/staff/profile', req);
    if (resp.isSuccess && resp.data != null) {
      return StaffProfile.fromJson(resp.data!);
    }
    throw Exception(resp.message ?? 'Failed to update staff profile.');
  }

  Future<StaffProfile?> getProfile(String userID) async {
    final resp = await ApiClient().get('/api/v1/staff/$userID');
    if (resp.isSuccess && resp.data != null) {
      return StaffProfile.fromJson(resp.data!);
    }
    if (resp.statusCode == 404) return null;
    throw Exception(resp.message ?? 'Failed to get staff profile.');
  }

  Future<StaffProfile?> getMyProfile() async {
    final resp = await ApiClient().get('/api/v1/staff/me');
    if (resp.isSuccess && resp.data != null) {
      return StaffProfile.fromJson(resp.data!);
    }
    if (resp.statusCode == 404) return null;
    throw Exception(resp.message ?? 'Failed to get staff profile.');
  }

  Future<PortfolioPhoto> addPortfolioPhoto(String photoUrl, {int? displayOrder}) async {
    final body = <String, dynamic>{'photo_url': photoUrl};
    if (displayOrder != null) body['display_order'] = displayOrder;
    final response = await ApiClient().post('/api/v1/staff/portfolio/photos', body);
    if (response.isSuccess && response.data != null) {
      return PortfolioPhoto.fromJson(response.data!);
    }
    throw Exception(response.message ?? 'Failed to add portfolio photo.');
  }

  Future<void> deletePortfolioPhoto(String photoId) async {
    final resp = await ApiClient().delete('/api/v1/staff/portfolio/photos/$photoId');
    if (!resp.isSuccess && resp.statusCode != 204) {
      throw Exception(resp.message ?? 'Failed to delete portfolio photo.');
    }
  }

  Future<void> reorderPortfolioPhotos(List<Map<String, dynamic>> orders) async {
    final resp = await ApiClient().patch(
      '/api/v1/staff/portfolio/photos/reorder',
      {'photo_orders': orders},
    );
    if (!resp.isSuccess) {
      throw Exception(resp.message ?? 'Failed to reorder portfolio photos.');
    }
  }
}
