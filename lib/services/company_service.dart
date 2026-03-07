import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company.dart';

/// 企業管理サービス（SharedPreferencesベース）
class CompanyService {
  static const String _companiesKey = 'companies';
  static const String _offersKey = 'headhunting_offers';
  static const String _currentCompanyKey = 'current_company_id';

  // ========== 企業管理 ==========

  /// 全企業を取得
  Future<List<Company>> getAllCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    final companiesJson = prefs.getString(_companiesKey);
    if (companiesJson == null) return [];

    final List<dynamic> companiesList = jsonDecode(companiesJson);
    return companiesList.map((json) => Company.fromJson(json)).toList();
  }

  /// 企業を作成
  Future<void> createCompany(Company company) async {
    final prefs = await SharedPreferences.getInstance();
    final companies = await getAllCompanies();
    companies.add(company);

    final companiesJson = jsonEncode(companies.map((c) => c.toJson()).toList());
    await prefs.setString(_companiesKey, companiesJson);
  }

  /// 企業を更新
  Future<void> updateCompany(Company company) async {
    final prefs = await SharedPreferences.getInstance();
    final companies = await getAllCompanies();

    final index = companies.indexWhere((c) => c.id == company.id);
    if (index != -1) {
      companies[index] = company;
      final companiesJson = jsonEncode(companies.map((c) => c.toJson()).toList());
      await prefs.setString(_companiesKey, companiesJson);
    }
  }

  /// 企業を削除
  Future<void> deleteCompany(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final companies = await getAllCompanies();

    companies.removeWhere((c) => c.id == companyId);
    final companiesJson = jsonEncode(companies.map((c) => c.toJson()).toList());
    await prefs.setString(_companiesKey, companiesJson);
  }

  /// IDで企業を取得
  Future<Company?> getCompanyById(String companyId) async {
    final companies = await getAllCompanies();
    try {
      return companies.firstWhere((c) => c.id == companyId);
    } catch (e) {
      return null;
    }
  }

  /// 現在の企業IDを設定
  Future<void> setCurrentCompanyId(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentCompanyKey, companyId);
  }

  /// 現在の企業IDを取得
  Future<String?> getCurrentCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentCompanyKey);
  }

  /// 現在の企業を取得
  Future<Company?> getCurrentCompany() async {
    final companyId = await getCurrentCompanyId();
    if (companyId == null) return null;
    return getCompanyById(companyId);
  }

  // ========== ヘッドハンティングオファー管理 ==========

  /// 全オファーを取得
  Future<List<HeadhuntingOffer>> getAllOffers() async {
    final prefs = await SharedPreferences.getInstance();
    final offersJson = prefs.getString(_offersKey);
    if (offersJson == null) return [];

    final List<dynamic> offersList = jsonDecode(offersJson);
    return offersList.map((json) => HeadhuntingOffer.fromJson(json)).toList();
  }

  /// オファーを作成
  Future<void> createOffer(HeadhuntingOffer offer) async {
    final prefs = await SharedPreferences.getInstance();
    final offers = await getAllOffers();
    offers.add(offer);

    final offersJson = jsonEncode(offers.map((o) => o.toJson()).toList());
    await prefs.setString(_offersKey, offersJson);
  }

  /// オファーを更新
  Future<void> updateOffer(HeadhuntingOffer offer) async {
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
  Future<List<HeadhuntingOffer>> getCompanyOffers(String companyId) async {
    final allOffers = await getAllOffers();
    return allOffers.where((o) => o.companyId == companyId).toList();
  }

  /// スタッフが受け取ったオファーを取得
  Future<List<HeadhuntingOffer>> getStaffOffers(String staffId) async {
    final allOffers = await getAllOffers();
    return allOffers.where((o) => o.staffId == staffId).toList();
  }

  /// オファーステータスを更新
  Future<void> updateOfferStatus(
    String offerId,
    OfferStatus status, {
    String? responseMessage,
  }) async {
    final offers = await getAllOffers();
    final index = offers.indexWhere((o) => o.id == offerId);

    if (index != -1) {
      final offer = offers[index];
      final updatedOffer = HeadhuntingOffer(
        id: offer.id,
        companyId: offer.companyId,
        companyName: offer.companyName,
        staffId: offer.staffId,
        staffName: offer.staffName,
        position: offer.position,
        description: offer.description,
        salaryMin: offer.salaryMin,
        salaryMax: offer.salaryMax,
        workLocation: offer.workLocation,
        requirements: offer.requirements,
        benefits: offer.benefits,
        status: status,
        createdAt: offer.createdAt,
        respondedAt: DateTime.now(),
        responseMessage: responseMessage,
      );

      await updateOffer(updatedOffer);
    }
  }

  // ========== スタッフ管理 ==========

  /// 店舗にスタッフを追加
  Future<void> addStaffToCompany(String companyId, String staffId) async {
    final company = await getCompanyById(companyId);
    if (company == null) return;

    if (!company.staffIds.contains(staffId)) {
      final updatedCompany = company.copyWith(
        staffIds: [...company.staffIds, staffId],
      );
      await updateCompany(updatedCompany);
    }
  }

  /// 店舗からスタッフを削除
  Future<void> removeStaffFromCompany(String companyId, String staffId) async {
    final company = await getCompanyById(companyId);
    if (company == null) return;

    final updatedStaffIds = company.staffIds.where((id) => id != staffId).toList();
    final updatedCompany = company.copyWith(staffIds: updatedStaffIds);
    await updateCompany(updatedCompany);
  }

  /// 投げ銭還元率を設定
  Future<void> setTipCommissionRate(String companyId, double rate) async {
    final company = await getCompanyById(companyId);
    if (company == null) return;

    // 0%〜10%の範囲に制限
    final clampedRate = rate.clamp(0.0, 0.10);
    final updatedCompany = company.copyWith(tipCommissionRate: clampedRate);
    await updateCompany(updatedCompany);
  }

  /// スタッフが所属する店舗を取得
  Future<Company?> getStaffCompany(String staffId) async {
    final companies = await getAllCompanies();
    try {
      return companies.firstWhere(
        (c) => c.isStore && c.staffIds.contains(staffId),
      );
    } catch (e) {
      return null;
    }
  }

  /// 店舗の所属スタッフ一覧を取得（スタッフデータは別途取得が必要）
  Future<List<String>> getCompanyStaffIds(String companyId) async {
    final company = await getCompanyById(companyId);
    return company?.staffIds ?? [];
  }

  // ========== デモデータ作成 ==========

  /// デモ企業を作成
  Future<void> createDemoCompanies() async {
    final existingCompanies = await getAllCompanies();
    if (existingCompanies.isNotEmpty) return;

    final now = DateTime.now();
    final demoCompanies = [
      Company(
        id: 'company_001',
        name: '株式会社テックイノベーション',
        industry: 'IT・ソフトウェア',
        description: '最先端のAI技術を活用したサービスを提供する急成長中のスタートアップ企業です。',
        address: '東京都渋谷区渋谷1-1-1',
        phoneNumber: '03-1234-5678',
        website: 'https://tech-innovation.example.com',
        contactEmail: 'recruit@tech-innovation.example.com',
        contactPerson: '採用担当 田中',
        employeeCount: 150,
        establishedDate: DateTime(2018, 4, 1),
        benefits: ['リモートワーク可', '社会保険完備', '交通費全額支給', '副業OK'],
        isVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
      Company(
        id: 'company_002',
        name: 'ビューティーサロングループ株式会社',
        industry: '美容・サービス',
        description: '全国に50店舗以上を展開する美容サロンチェーンです。',
        address: '東京都新宿区新宿2-2-2',
        phoneNumber: '03-9876-5432',
        website: 'https://beauty-salon-group.example.com',
        contactEmail: 'hr@beauty-salon-group.example.com',
        contactPerson: '人事部 佐藤',
        employeeCount: 300,
        establishedDate: DateTime(2010, 7, 15),
        benefits: ['社員割引制度', '資格取得支援', '独立支援制度', '完全週休2日制'],
        isVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
      Company(
        id: 'company_003',
        name: 'グローバルコンサルティング株式会社',
        industry: 'コンサルティング',
        description: '企業の成長をサポートする経営コンサルティング会社です。',
        address: '東京都千代田区丸の内3-3-3',
        phoneNumber: '03-5555-6666',
        website: 'https://global-consulting.example.com',
        contactEmail: 'careers@global-consulting.example.com',
        contactPerson: '採用チーム 鈴木',
        employeeCount: 80,
        establishedDate: DateTime(2015, 1, 10),
        benefits: ['フレックスタイム制', '海外研修制度', 'ストックオプション', '書籍購入補助'],
        isVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final company in demoCompanies) {
      await createCompany(company);
    }
  }
}
