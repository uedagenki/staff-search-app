import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/company.dart';

/// ヘッドハンティング企業認証サービス
class HeadhuntingAuthService {
  static const String _headhuntingCompaniesKey = 'headhunting_companies';
  static const String _currentHeadhuntingCompanyKey = 'current_headhunting_company';

  /// ヘッドハンティング企業として登録されているか確認
  Future<bool> isHeadhuntingCompany(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final companiesJson = prefs.getString(_headhuntingCompaniesKey);
    
    if (companiesJson == null) return false;
    
    final List<dynamic> companies = jsonDecode(companiesJson);
    return companies.any((c) => c['id'] == companyId);
  }

  /// ヘッドハンティング企業として登録
  Future<void> registerHeadhuntingCompany(Company company) async {
    final prefs = await SharedPreferences.getInstance();
    final companiesJson = prefs.getString(_headhuntingCompaniesKey);
    
    List<dynamic> companies = [];
    if (companiesJson != null) {
      companies = jsonDecode(companiesJson);
    }
    
    // 既に登録されていない場合のみ追加
    if (!companies.any((c) => c['id'] == company.id)) {
      companies.add({
        'id': company.id,
        'name': company.name,
        'registeredAt': DateTime.now().toIso8601String(),
      });
      
      await prefs.setString(_headhuntingCompaniesKey, jsonEncode(companies));
    }
    
    // 現在のヘッドハンティング企業として設定
    await setCurrentHeadhuntingCompany(company);
  }

  /// ヘッドハンティング企業登録を解除
  Future<void> unregisterHeadhuntingCompany(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    final companiesJson = prefs.getString(_headhuntingCompaniesKey);
    
    if (companiesJson == null) return;
    
    List<dynamic> companies = jsonDecode(companiesJson);
    companies.removeWhere((c) => c['id'] == companyId);
    
    await prefs.setString(_headhuntingCompaniesKey, jsonEncode(companies));
    
    // 現在の企業が削除された場合、クリア
    final currentCompany = await getCurrentHeadhuntingCompany();
    if (currentCompany != null && currentCompany.id == companyId) {
      await prefs.remove(_currentHeadhuntingCompanyKey);
    }
  }

  /// 現在のヘッドハンティング企業を取得
  Future<Company?> getCurrentHeadhuntingCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final companyJson = prefs.getString(_currentHeadhuntingCompanyKey);
    
    if (companyJson == null) return null;
    
    final companyMap = jsonDecode(companyJson);
    return Company.fromJson(companyMap);
  }

  /// 現在のヘッドハンティング企業を設定
  Future<void> setCurrentHeadhuntingCompany(Company company) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentHeadhuntingCompanyKey, jsonEncode(company.toJson()));
  }

  /// 登録されているヘッドハンティング企業一覧を取得
  Future<List<Map<String, dynamic>>> getHeadhuntingCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    final companiesJson = prefs.getString(_headhuntingCompaniesKey);
    
    if (companiesJson == null) return [];
    
    final List<dynamic> companies = jsonDecode(companiesJson);
    return companies.cast<Map<String, dynamic>>();
  }

  /// ヘッドハンティング企業数を取得
  Future<int> getHeadhuntingCompanyCount() async {
    final companies = await getHeadhuntingCompanies();
    return companies.length;
  }
}
