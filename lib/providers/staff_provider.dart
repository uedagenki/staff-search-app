import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/portfolio_photo.dart';
import '../models/staff_profile.dart';
import '../models/upload_result.dart';
import '../services/staff_service.dart';
import '../services/upload_service.dart';

class StaffProvider extends ChangeNotifier {
  StaffProfile? _currentProfile;
  bool _isLoading = false;
  String? _error;
  List<PortfolioPhoto> portfolioPhotos = [];

  StaffProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentProfile = await StaffService.instance.getMyProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProfile(Map<String, dynamic> req) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentProfile = await StaffService.instance.createProfile(req);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> req) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentProfile = await StaffService.instance.updateProfile(req);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setProfile(StaffProfile profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  Future<void> addPortfolioPhoto(XFile file) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await UploadService.instance.uploadFile(file, UploadFolder.portfolio);
      final photo = await StaffService.instance.addPortfolioPhoto(result.publicUrl);
      portfolioPhotos = [...portfolioPhotos, photo];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePortfolioPhoto(String photoId) async {
    final oldPhotos = List<PortfolioPhoto>.from(portfolioPhotos);
    portfolioPhotos = portfolioPhotos.where((p) => p.id != photoId).toList();
    notifyListeners();
    try {
      await StaffService.instance.deletePortfolioPhoto(photoId);
    } catch (e) {
      portfolioPhotos = oldPhotos;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reorderPortfolioPhotos(List<PortfolioPhoto> newOrder) async {
    final oldPhotos = List<PortfolioPhoto>.from(portfolioPhotos);
    portfolioPhotos = newOrder;
    notifyListeners();
    try {
      final orders = newOrder.asMap().entries.map((e) => {
        'id': e.value.id,
        'order': e.key,
      }).toList();
      await StaffService.instance.reorderPortfolioPhotos(orders);
    } catch (e) {
      portfolioPhotos = oldPhotos;
      notifyListeners();
      rethrow;
    }
  }
}
