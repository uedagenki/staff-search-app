# staffsearch アプリケーション 完全仕様書

## 📋 目次
1. [プロジェクト概要](#1-プロジェクト概要)
2. [システムアーキテクチャ](#2-システムアーキテクチャ)
3. [機能要件](#3-機能要件)
4. [データベーススキーマ](#4-データベーススキーマ)
5. [技術スタック](#5-技術スタック)
6. [プライバシーポリシー・個人情報保護](#6-プライバシーポリシー個人情報保護)
7. [画面設計](#7-画面設計)
8. [API仕様](#8-api仕様)
9. [セキュリティ要件](#9-セキュリティ要件)
10. [デプロイメント](#10-デプロイメント)

---

## 1. プロジェクト概要

### 1.1 アプリケーション名
**staffsearch（スタッフサーチ）**

### 1.2 概要
TikTok風UIを採用した、働く人（スタッフ）のSNS配信サービス＆QRチップ決済アプリケーション。スタッフと顧客をつなぐマッチングプラットフォーム。

### 1.3 ターゲットユーザー
- **一般ユーザー**: サービスを探している顧客
- **スタッフ**: 美容師、エステティシャン、ネイリスト、マッサージ師など
- **管理者**: プラットフォーム運営者

### 1.4 主要価値提案
- 🔍 スタッフを簡単に検索・発見
- 📅 オンライン予約システム
- 🎥 ライブ配信でスタッフとリアルタイム交流
- 💝 チップ・ギフト機能でスタッフを応援
- ⭐ レビュー・評価システムで信頼性確保
- 🔒 個人情報保護法準拠のプライバシー管理

---

## 2. システムアーキテクチャ

### 2.1 全体アーキテクチャ

```
┌──────────────────────────────────────────────────────────────┐
│                   Flutter Web/Android App                     │
│                     (Dart 3.9.2)                             │
└──────────────────┬──────────────────────────────────────────┘
                   │
     ┌─────────────┴────────────────┐
     │                              │
┌────▼──────────┐         ┌─────────▼────────┐
│  Firebase     │         │  Local Storage   │
│  Services     │         │  (Offline)       │
├───────────────┤         ├──────────────────┤
│ • Firestore   │         │ • Hive DB        │
│ • Storage     │         │ • SharedPrefs    │
│ • Auth        │         └──────────────────┘
│ • Messaging   │
│ • Analytics   │
└───────┬───────┘
        │
┌───────▼───────────────────────────────┐
│     External APIs & Services          │
├───────────────────────────────────────┤
│ • Agora SDK (Live Streaming)         │
│ • Stripe API (Payment)               │
│ • Google Maps API (Location)         │
│ • FCM (Push Notifications)           │
└───────────────────────────────────────┘
```

### 2.2 データフロー

```
User Action → Flutter UI → Service Layer → Firebase/API → Response
     ↓                                                        ↓
Local Cache ←───────────────────────────────────────────────┘
```

---

## 3. 機能要件

### 3.1 認証・アカウント管理

#### ✨ プライバシーポリシー対応（NEW）
**個人情報保護法準拠機能:**
- ✅ 新規登録時のプライバシーポリシー同意チェックボックス
- ✅ プライバシーポリシー全文表示画面
- ✅ 同意日時の記録（Firestore）
- ✅ プライバシーポリシーバージョン管理

**実装詳細:**
- 画面: `/lib/screens/privacy_policy_screen.dart`
- 更新画面: `/lib/screens/register_screen.dart`
- データモデル: `users` コレクションに追加フィールド
  ```javascript
  {
    privacyPolicyAccepted: boolean,
    privacyPolicyAcceptedAt: timestamp,
    privacyPolicyVersion: string  // "v1.0"
  }
  ```

#### ユーザー登録
- メール/パスワード認証（Firebase Auth）
- プロフィール情報入力（名前、画像、自己紹介）
- **プライバシーポリシー同意必須** ✨
- 電話番号登録（任意）

#### ログイン
- メール/パスワードログイン
- セッション管理（永続ログイン）
- デモユーザー機能（テスト用）

#### プロフィール管理
- 基本情報編集
- プロフィール画像変更
- パスワード変更
- アカウント削除

### 3.2 スタッフ検索・発見

#### カテゴリ検索
- 美容師、エステティシャン、ネイリスト、マッサージ師等
- カテゴリ別フィルタリング

#### 地域検索
- 現在地からの距離順表示
- Google Maps連携
- 地図上でスタッフ表示

#### フィルター機能
- 評価順、人気順、距離順
- 価格帯フィルター
- オンライン/オフライン状態
- カテゴリー複数選択

#### ランキング
- カテゴリー別ランキング
- ギフト受取額ランキング
- フォロワー数ランキング

### 3.3 予約システム（Firebase Firestore）

#### 予約作成フロー
1. スタッフ選択
2. サービス選択（メニューから）
3. 日付選択（カレンダー）
4. 時間選択（30分刻みタイムスロット）
5. 備考入力（任意）
6. 予約確認・送信

#### タイムスロット管理
- 営業時間: 9:00 - 18:00（デフォルト）
- 30分刻みのスロット
- 既存予約との重複チェック
- 利用可能/不可の視覚的表示

#### 予約ステータス管理
- **pending**: 予約申請中（スタッフ確認待ち）
- **confirmed**: 予約確定
- **completed**: サービス完了
- **cancelled**: キャンセル

#### リアルタイム更新
- Firebase Streamでリアルタイム同期
- 複数デバイス間で自動更新

### 3.4 ライブ配信機能（Agora SDK）

#### 視聴者機能
- ライブ配信一覧表示
- リアルタイム視聴（低遅延）
- コメント投稿
- ギフト送信
- いいね・ハート送信

#### 配信者機能（スタッフ）
- カメラ・マイク設定
- タイトル・サムネイル設定
- 配信開始/終了
- 視聴者数確認
- コメント確認
- ギフト受取確認

### 3.5 チップ・ギフトシステム

#### ポイント購入
- Stripe決済連携
- ポイントパッケージ
  - 100pt: ¥100
  - 500pt: ¥500
  - 1000pt: ¥1,000
  - 3000pt: ¥3,000
  - 5000pt: ¥5,000

#### ギフト送信
- スタッフへのチップ送信
- ライブ配信中のギフト送信
- ギフトアニメーション表示
- ギフト履歴確認

### 3.6 メッセージ・チャット

#### ダイレクトメッセージ
- スタッフとの1対1チャット
- テキストメッセージ
- 画像・ファイル送信
- 既読・未読管理

#### プッシュ通知（FCM）
- 新着メッセージ通知
- 予約確定通知
- ギフト受取通知
- ライブ配信開始通知

### 3.7 レビュー・評価

#### レビュー投稿
- 5段階評価（星）
- コメント投稿
- 写真添付
- 予約完了後に投稿可能

#### レビュー閲覧
- スタッフの評価一覧
- 評価平均・件数表示
- 新着順・評価順ソート

---

## 4. データベーススキーマ

### 4.1 Firestore コレクション設計

#### users コレクション
```javascript
users/{userId}
{
  // 基本情報
  id: string,
  email: string,
  name: string,
  profileImage: string,
  bio: string,
  phoneNumber: string,
  role: string,  // 'user' | 'staff' | 'admin'
  
  // ポイント
  points: number,
  
  // プライバシー関連 ✨ NEW
  privacyPolicyAccepted: boolean,
  privacyPolicyAcceptedAt: timestamp,
  privacyPolicyVersion: string,  // "v1.0"
  
  // タイムスタンプ
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### bookings コレクション（Firebase対応）
```javascript
bookings/{bookingId}
{
  id: string,
  
  // ユーザー情報
  userId: string,
  userName: string,
  userEmail: string,
  userPhone: string,
  
  // スタッフ情報
  staffId: string,
  staffName: string,
  staffAvatar: string,
  
  // サービス情報
  serviceId: string,
  serviceName: string,
  serviceDescription: string,
  price: number,
  
  // 予約情報
  dateTime: timestamp,
  duration: number,  // 分単位
  status: string,    // 'pending' | 'confirmed' | 'completed' | 'cancelled'
  notes: string,
  cancellationReason: string,
  
  // タイムスタンプ
  createdAt: timestamp,
  updatedAt: timestamp
}

// Firestoreインデックス推奨
// - staffId, status
// - userId, status
// - staffId, dateTime
```

#### services コレクション
```javascript
services/{serviceId}
{
  id: string,
  staffId: string,
  name: string,
  description: string,
  price: number,
  duration: number,  // 分単位
  category: string,
  isActive: boolean,
  images: array<string>,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

---

## 5. 技術スタック

### 5.1 フロントエンド
- **Framework**: Flutter 3.35.4（固定）
- **Language**: Dart 3.9.2（固定）
- **UI**: Material Design 3
- **State Management**: Provider

### 5.2 バックエンド
- **Firebase Core**: 3.6.0
- **Cloud Firestore**: 5.4.3
- **Firebase Storage**: 12.3.2
- **Firebase Auth**: （Firebase Coreに含まれる）
- **Firebase Messaging**: 15.1.3

### 5.3 主要パッケージ（固定バージョン）
```yaml
dependencies:
  # Firebase
  firebase_core: 3.6.0
  cloud_firestore: 5.4.3
  firebase_storage: 12.3.2
  firebase_messaging: 15.1.3
  
  # ローカルストレージ
  shared_preferences: 2.5.3
  hive: 2.2.3
  hive_flutter: 1.1.0
  
  # 状態管理・ネットワーク
  provider: 6.1.5+1
  http: 1.5.0
  
  # UI・ユーティリティ
  intl: 0.19.0
  cached_network_image: 3.4.1
  shimmer: 3.0.0
  flutter_rating_bar: 4.0.1
  
  # 機能別
  geolocator: 13.0.2              # 位置情報
  agora_rtc_engine: 6.3.2         # ライブ配信
  flutter_stripe: 10.2.0          # 決済
  qr_flutter: 4.1.0               # QRコード
  video_player: 2.9.2             # 動画再生
  image_picker: 1.1.2             # 画像選択
  permission_handler: 11.3.1      # パーミッション管理
```

### 5.4 外部サービス
- **Agora**: ライブ配信（リアルタイム動画・音声）
- **Stripe**: オンライン決済処理
- **Google Maps**: 地図表示・位置情報
- **FCM**: プッシュ通知

---

## 6. プライバシーポリシー・個人情報保護

### 6.1 個人情報保護法対応

#### 実装機能
✅ **プライバシーポリシー画面**
- 全文表示（日本語）
- 読みやすいセクション構成
- スクロール可能なレイアウト

✅ **同意チェックボックス**
- 新規登録画面に実装
- チェック必須（未チェックは登録不可）
- プライバシーポリシーへのリンク付き

✅ **同意記録**
- 同意日時をFirestoreに保存
- バージョン管理（v1.0）
- 監査ログとして保持

#### プライバシーポリシー内容
1. はじめに
2. 収集する情報
   - アカウント情報
   - 利用情報
   - 位置情報
   - デバイス情報
3. 情報の利用目的
4. 情報の第三者提供
5. 情報の管理
6. ユーザーの権利
7. Cookie・トラッキング技術
8. 未成年者の個人情報
9. プライバシーポリシーの変更
10. お問い合わせ

### 6.2 データ保護措置

#### 技術的保護
- 🔒 HTTPS通信（全データ暗号化）
- 🔑 Firebase Authenticationによる認証
- 🛡️ Firestoreセキュリティルール
- 🔐 データ保管時の暗号化

#### 運用的保護
- 📊 アクセスログ記録
- 👥 最小権限の原則
- 🔄 定期的なセキュリティ監査
- 📱 デバイス認証

---

## 7. 画面設計

### 7.1 主要画面一覧

#### 認証系
- ログイン画面
- 新規登録画面（プライバシーポリシー同意含む） ✨
- プライバシーポリシー画面 ✨ NEW
- パスワードリセット画面

#### ホーム・検索系
- ホーム画面（スタッフ一覧）
- 検索画面（フィルタ・ソート）
- 地図検索画面
- ランキング画面

#### スタッフ詳細・予約系
- スタッフ詳細画面
- 予約作成画面 ✨ Firebase対応
- 予約一覧画面 ✨ Firebase対応
- 予約詳細画面

#### ライブ配信系
- ライブ配信一覧
- ライブ視聴画面
- ライブ配信画面（スタッフ）

#### メッセージ・プロフィール系
- メッセージ一覧
- チャット画面
- プロフィール画面
- プロフィール編集画面

#### スタッフ管理系
- スタッフダッシュボード
- 予約管理画面
- サービスメニュー管理
- 収益管理画面

#### 管理者系
- 管理ダッシュボード
- ユーザー管理
- スタッフ管理
- コンテンツモデレーション

---

## 8. API仕様

### 8.1 Firebase Firestore API

#### 予約API
```dart
// 予約作成
Future<Booking?> createBooking(Booking booking)

// スタッフの予約取得
Future<List<Booking>> getStaffBookings(String staffId, {String? status, DateTime? date})

// ユーザーの予約取得
Future<List<Booking>> getUserBookings(String userId, {String? status})

// 予約更新
Future<bool> updateBooking(Booking updatedBooking)

// 予約キャンセル
Future<bool> cancelBooking(String bookingId, String staffId, String userId, String? reason)

// タイムスロット取得
Future<List<TimeSlot>> getAvailableTimeSlots(String staffId, DateTime date, int duration)
```

#### サービスAPI
```dart
// サービス取得
Future<List<Service>> getStaffServices(String staffId)

// サービス追加
Future<bool> addService(Service service)

// サービス更新
Future<bool> updateService(Service updatedService)

// サービス削除
Future<bool> deleteService(String staffId, String serviceId)
```

### 8.2 外部API

#### Agora SDK
```dart
// チャンネル参加
await engine.joinChannel(token, channelName, null, uid)

// チャンネル退出
await engine.leaveChannel()
```

#### Stripe API
```dart
// 決済処理
await Stripe.instance.presentPaymentSheet()
```

---

## 9. セキュリティ要件

### 9.1 認証・認可
- Firebase Authenticationによる認証
- ロールベースアクセス制御（user/staff/admin）
- セッション管理（永続ログイン）

### 9.2 データセキュリティ
- HTTPS通信必須
- Firestoreセキュリティルール適用
- 個人情報の暗号化保存
- プライバシーポリシー同意記録 ✨

### 9.3 Firestoreセキュリティルール
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーコレクション
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 予約コレクション
    match /bookings/{bookingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == resource.data.staffId);
      allow delete: if false;
    }
    
    // サービスコレクション
    match /services/{serviceId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 10. デプロイメント

### 10.1 Web版デプロイメント
```bash
# ビルド
flutter build web --release

# サーバー起動
cd build/web
python3 -m http.server 5060 --bind 0.0.0.0
```

### 10.2 Android APKビルド
```bash
# リリースビルド
flutter build apk --release

# 出力先
# build/app/outputs/flutter-apk/app-release.apk
```

### 10.3 環境変数
- **Firebase設定**: `lib/firebase_options.dart`
- **Agora App ID**: 環境変数で管理
- **Stripe Public Key**: 環境変数で管理

---

## 11. 今後の拡張機能

### フェーズ2
- iOS対応
- 多言語対応（英語、中国語）
- AI推奨機能
- ビデオ通話機能

### フェーズ3
- AR美容体験
- サブスクリプションプラン
- スタッフ向けAI分析ダッシュボード

---

## 📞 サポート・お問い合わせ

- **技術サポート**: tech@staffsearch.example.com
- **ユーザーサポート**: support@staffsearch.example.com
- **プライバシー問い合わせ**: privacy@staffsearch.example.com

---

**制定日**: 2025年1月1日  
**バージョン**: v1.0  
**最終更新**: 2025年3月5日

---

© 2025 staffsearch. All Rights Reserved.
