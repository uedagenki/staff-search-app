import '../models/store.dart';

class StoreData {
  static List<Store> getAllStores() {
    return [
      // 美容・サロン
      Store(
        id: 'store_001',
        name: '美容室 HAIR & MAKE',
        category: '美容・健康',
        address: '東京都渋谷区神南1-2-3',
        phoneNumber: '03-1234-5678',
        description: '経験豊富なスタイリストが揃う人気サロン。最新のトレンドヘアからカラーまで幅広く対応します。',
        imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
        rating: 4.7,
        reviewCount: 234,
        latitude: 35.6628,
        longitude: 139.6981,
        businessHours: ['月-金: 10:00-20:00', '土日: 9:00-19:00', '定休日: 火曜日'],
        amenities: ['WiFi完備', '駐車場あり', 'キッズスペース', 'カフェ併設'],
      ),
      Store(
        id: 'store_002',
        name: 'エステサロン Bloom',
        category: '美容・健康',
        address: '東京都港区青山2-3-4',
        phoneNumber: '03-2345-6789',
        description: '最新の美容機器と確かな技術で、お客様の美を引き出します。',
        imageUrl: 'https://images.unsplash.com/photo-1519415387722-a1c3bbef716c?w=800',
        rating: 4.8,
        reviewCount: 156,
        latitude: 35.6732,
        longitude: 139.7186,
        businessHours: ['月-日: 10:00-21:00', '定休日: なし'],
        amenities: ['完全個室', 'シャワー完備', 'アメニティ充実', 'ドリンクサービス'],
      ),

      // フィットネス
      Store(
        id: 'store_003',
        name: 'パーソナルジム FIT ZONE',
        category: 'フィットネス・スポーツ',
        address: '東京都新宿区西新宿3-4-5',
        phoneNumber: '03-3456-7890',
        description: 'マンツーマン指導で理想のボディを実現。トレーナー全員が有資格者です。',
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
        rating: 4.9,
        reviewCount: 89,
        latitude: 35.6896,
        longitude: 139.6917,
        businessHours: ['月-日: 7:00-23:00', '定休日: なし'],
        amenities: ['シャワー完備', 'ロッカー無料', 'プロテインバー', '無料体験あり'],
      ),

      // 不動産
      Store(
        id: 'store_004',
        name: '不動産プラザ 東京店',
        category: '不動産',
        address: '東京都千代田区丸の内1-5-6',
        phoneNumber: '03-4567-8901',
        description: '都心の物件を中心に、お客様の理想の住まいをご提案します。',
        imageUrl: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800',
        rating: 4.5,
        reviewCount: 178,
        latitude: 35.6812,
        longitude: 139.7671,
        businessHours: ['月-金: 9:00-19:00', '土日: 10:00-18:00', '定休日: 水曜日'],
        amenities: ['キッズルーム', '駐車場3台', '相談ルーム完備', 'オンライン相談可'],
      ),

      // 自動車ディーラー
      Store(
        id: 'store_005',
        name: 'カーディーラー AutoMax',
        category: '自動車・乗り物',
        address: '東京都世田谷区三軒茶屋2-6-7',
        phoneNumber: '03-5678-9012',
        description: '国産車・輸入車まで幅広く取り扱い。整備・車検も安心のサポート体制。',
        imageUrl: 'https://images.unsplash.com/photo-1562519819-016930ada31d?w=800',
        rating: 4.6,
        reviewCount: 123,
        latitude: 35.6433,
        longitude: 139.6689,
        businessHours: ['月-日: 9:00-20:00', '定休日: なし'],
        amenities: ['試乗可能', '整備工場併設', 'キッズスペース', 'カフェラウンジ'],
      ),

      // 家電量販店
      Store(
        id: 'store_006',
        name: '家電専門店 TechWorld',
        category: '小売・販売',
        address: '東京都品川区大井1-7-8',
        phoneNumber: '03-6789-0123',
        description: '最新家電から生活家電まで豊富な品揃え。専門スタッフが丁寧にご案内します。',
        imageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=800',
        rating: 4.4,
        reviewCount: 267,
        latitude: 35.6054,
        longitude: 139.7347,
        businessHours: ['月-日: 10:00-21:00', '定休日: なし'],
        amenities: ['駐車場完備', '配送サービス', '修理サポート', 'ポイントカード'],
      ),

      // アパレルショップ
      Store(
        id: 'store_007',
        name: 'ファッションストア MODE',
        category: '小売・販売',
        address: '東京都渋谷区神宮前4-8-9',
        phoneNumber: '03-7890-1234',
        description: 'トレンドを押さえた厳選アイテムが揃うセレクトショップ。',
        imageUrl: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800',
        rating: 4.7,
        reviewCount: 145,
        latitude: 35.6695,
        longitude: 139.7078,
        businessHours: ['月-日: 11:00-20:00', '定休日: なし'],
        amenities: ['試着室完備', 'スタイリング相談', 'オンラインショップ', 'ポイントカード'],
      ),

      // 学習塾
      Store(
        id: 'store_008',
        name: '進学塾 スマートアカデミー',
        category: '教育・語学',
        address: '東京都目黒区自由が丘1-9-10',
        phoneNumber: '03-8901-2345',
        description: '個別指導と集団授業を選べる進学塾。志望校合格率90%以上。',
        imageUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800',
        rating: 4.8,
        reviewCount: 98,
        latitude: 35.6074,
        longitude: 139.6676,
        businessHours: ['月-金: 14:00-22:00', '土: 10:00-20:00', '定休日: 日曜日'],
        amenities: ['自習室完備', '無料体験授業', 'オンライン授業対応', '駐輪場あり'],
      ),

      // レストラン
      Store(
        id: 'store_009',
        name: 'イタリアンレストラン Bella Vista',
        category: 'その他専門サービス',
        address: '東京都中央区銀座5-10-11',
        phoneNumber: '03-9012-3456',
        description: '本場イタリアの味を再現した本格イタリアン。記念日にも最適。',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        rating: 4.9,
        reviewCount: 312,
        latitude: 35.6719,
        longitude: 139.7648,
        businessHours: ['月-日: 11:30-15:00, 17:30-23:00', '定休日: なし'],
        amenities: ['個室あり', 'テラス席', 'ワインセラー', '予約優先'],
      ),

      // 家具店
      Store(
        id: 'store_010',
        name: 'インテリアショップ COZY HOME',
        category: '小売・販売',
        address: '東京都江東区豊洲3-11-12',
        phoneNumber: '03-0123-4567',
        description: '北欧家具を中心に、心地よい空間づくりをお手伝いします。',
        imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
        rating: 4.6,
        reviewCount: 187,
        latitude: 35.6544,
        longitude: 139.7964,
        businessHours: ['月-日: 10:00-20:00', '定休日: 水曜日'],
        amenities: ['配送・組立サービス', 'インテリア相談', '大型駐車場', 'カフェ併設'],
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'すべて',
      '美容・健康',
      'フィットネス・スポーツ',
      '不動産',
      '自動車・乗り物',
      '小売・販売',
      '教育・語学',
      'その他専門サービス',
    ];
  }
}
