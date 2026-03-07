import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/store_staff_offer.dart';
import '../models/company.dart'; // OfferStatusをインポート

/// 店舗スタッフオファー管理サービス
class StoreStaffOfferService {
  static const String _offersKey = 'store_staff_offers';

  /// 全オファーを取得
  Future<List<StoreStaffOffer>> getAllOffers() async {
    final prefs = await SharedPreferences.getInstance();
    final offersJson = prefs.getString(_offersKey);
    if (offersJson == null) return [];

    final List<dynamic> offersList = jsonDecode(offersJson);
    return offersList.map((json) => StoreStaffOffer.fromJson(json)).toList();
  }

  /// オファーを作成
  Future<void> createOffer(StoreStaffOffer offer) async {
    final prefs = await SharedPreferences.getInstance();
    final offers = await getAllOffers();
    offers.add(offer);

    final offersJson = jsonEncode(offers.map((o) => o.toJson()).toList());
    await prefs.setString(_offersKey, offersJson);
  }

  /// オファーを更新
  Future<void> updateOffer(StoreStaffOffer offer) async {
    final prefs = await SharedPreferences.getInstance();
    final offers = await getAllOffers();

    final index = offers.indexWhere((o) => o.id == offer.id);
    if (index != -1) {
      offers[index] = offer;
      final offersJson = jsonEncode(offers.map((o) => o.toJson()).toList());
      await prefs.setString(_offersKey, offersJson);
    }
  }

  /// 企業が送信したオファーを取得
  Future<List<StoreStaffOffer>> getCompanyOffers(String companyId) async {
    final allOffers = await getAllOffers();
    return allOffers.where((o) => o.companyId == companyId).toList();
  }

  /// スタッフが受け取ったオファーを取得
  Future<List<StoreStaffOffer>> getStaffOffers(String staffId) async {
    final allOffers = await getAllOffers();
    return allOffers.where((o) => o.staffId == staffId).toList();
  }

  /// スタッフのメールアドレスでオファーを取得
  Future<List<StoreStaffOffer>> getStaffOffersByEmail(String email) async {
    final allOffers = await getAllOffers();
    return allOffers.where((o) => o.staffEmail == email).toList();
  }

  /// オファーを承諾
  Future<void> acceptOffer(
    String offerId, {
    String? responseMessage,
  }) async {
    final offers = await getAllOffers();
    final index = offers.indexWhere((o) => o.id == offerId);

    if (index != -1) {
      final offer = offers[index];
      final updatedOffer = StoreStaffOffer(
        id: offer.id,
        companyId: offer.companyId,
        companyName: offer.companyName,
        staffId: offer.staffId,
        staffName: offer.staffName,
        staffEmail: offer.staffEmail,
        position: offer.position,
        message: offer.message,
        tipCommissionRate: offer.tipCommissionRate,
        benefits: offer.benefits,
        status: OfferStatus.accepted,
        createdAt: offer.createdAt,
        respondedAt: DateTime.now(),
        responseMessage: responseMessage,
      );

      await updateOffer(updatedOffer);
    }
  }

  /// オファーを辞退
  Future<void> declineOffer(
    String offerId, {
    String? responseMessage,
  }) async {
    final offers = await getAllOffers();
    final index = offers.indexWhere((o) => o.id == offerId);

    if (index != -1) {
      final offer = offers[index];
      final updatedOffer = StoreStaffOffer(
        id: offer.id,
        companyId: offer.companyId,
        companyName: offer.companyName,
        staffId: offer.staffId,
        staffName: offer.staffName,
        staffEmail: offer.staffEmail,
        position: offer.position,
        message: offer.message,
        tipCommissionRate: offer.tipCommissionRate,
        benefits: offer.benefits,
        status: OfferStatus.declined,
        createdAt: offer.createdAt,
        respondedAt: DateTime.now(),
        responseMessage: responseMessage,
      );

      await updateOffer(updatedOffer);
    }
  }

  /// オファーをキャンセル（企業側）
  Future<void> cancelOffer(String offerId) async {
    final offers = await getAllOffers();
    final index = offers.indexWhere((o) => o.id == offerId);

    if (index != -1) {
      final offer = offers[index];
      final updatedOffer = StoreStaffOffer(
        id: offer.id,
        companyId: offer.companyId,
        companyName: offer.companyName,
        staffId: offer.staffId,
        staffName: offer.staffName,
        staffEmail: offer.staffEmail,
        position: offer.position,
        message: offer.message,
        tipCommissionRate: offer.tipCommissionRate,
        benefits: offer.benefits,
        status: OfferStatus.cancelled,
        createdAt: offer.createdAt,
        respondedAt: DateTime.now(),
        responseMessage: null,
      );

      await updateOffer(updatedOffer);
    }
  }

  /// 承諾済みオファーからスタッフIDリストを取得
  Future<List<String>> getAcceptedStaffIds(String companyId) async {
    final offers = await getCompanyOffers(companyId);
    return offers
        .where((o) => o.status == OfferStatus.accepted)
        .map((o) => o.staffId)
        .toList();
  }
}
