import '../models/headhunt_offer.dart';
import '../data/mock_data.dart';

class HeadhuntService {
  static final HeadhuntService _instance = HeadhuntService._internal();
  factory HeadhuntService() => _instance;
  HeadhuntService._internal();

  // ヘッドハンティングオファーのモックデータ
  List<HeadhuntOffer> _getOffers() {
    final staffList = MockData.getStaffList();
    
    return [
      HeadhuntOffer(
        id: 'offer_001',
        staffId: staffList[0].id,
        staffName: staffList[0].name,
        staffImage: staffList[0].profileImage,
        companyName: 'グローバル商事株式会社',
        position: '営業部長',
        jobDescription: '大手企業の営業部長として、営業戦略の立案と実行をお任せします。年収800-1000万円。',
        salaryRange: '¥8,000,000 - ¥10,000,000',
        location: '東京都港区',
        status: OfferStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        message: 'あなたの実績と経験を高く評価しております。ぜひ一度お話しする機会をいただけませんか?',
      ),
      HeadhuntOffer(
        id: 'offer_002',
        staffId: staffList[0].id,
        staffName: staffList[0].name,
        staffImage: staffList[0].profileImage,
        companyName: 'テック革新株式会社',
        position: 'セールスマネージャー',
        jobDescription: 'IT企業のセールスチームをリードし、新規事業の拡大をお任せします。',
        salaryRange: '¥7,000,000 - ¥9,000,000',
        location: '東京都渋谷区',
        status: OfferStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      HeadhuntOffer(
        id: 'offer_003',
        staffId: staffList[1].id,
        staffName: staffList[1].name,
        staffImage: staffList[1].profileImage,
        companyName: 'ビューティーラボ株式会社',
        position: 'チーフスタイリスト',
        jobDescription: '高級サロンのチーフスタイリストとして、技術指導とサロン運営をお任せします。',
        salaryRange: '¥5,000,000 - ¥7,000,000',
        location: '東京都表参道',
        status: OfferStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        message: '表参道の新店舗オープンに向けて、ぜひあなたの力をお借りしたいです。',
      ),
    ];
  }

  // オファー一覧を取得
  Future<List<HeadhuntOffer>> getOffers({String? staffId}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // シミュレート
    
    final offers = _getOffers();
    
    if (staffId != null) {
      return offers.where((offer) => offer.staffId == staffId).toList();
    }
    
    return offers;
  }

  // 未読オファー数を取得
  Future<int> getUnreadOfferCount({String? staffId}) async {
    final offers = await getOffers(staffId: staffId);
    return offers.where((offer) => offer.status == OfferStatus.pending).length;
  }

  // オファーを承認
  Future<void> acceptOffer(String offerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 実際のアプリでは、バックエンドAPIにリクエストを送信
  }

  // オファーを辞退
  Future<void> declineOffer(String offerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 実際のアプリでは、バックエンドAPIにリクエストを送信
  }

  // オファーに返信
  Future<void> replyToOffer(String offerId, String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 実際のアプリでは、バックエンドAPIにリクエストを送信
  }
}
