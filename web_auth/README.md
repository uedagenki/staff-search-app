# 🔐 staffsearch Webログインシステム

## 概要
staffsearchアプリケーション専用のWeb認証システムです。アプリ外部からアクセスし、ダッシュボードでシステム統計やユーザー情報を確認できます。

## 🌐 アクセスURL

### ログイン画面
```
https://5060-ivmmk44rjvkdnze0ep01h-c81df28e.sandbox.novita.ai/login.html
```

### ダッシュボード（ログイン後）
```
https://5060-ivmmk44rjvkdnze0ep01h-c81df28e.sandbox.novita.ai/dashboard.html
```

---

## 📋 機能一覧

### ✅ 実装済み機能

#### 1. ログイン画面
- **Firebase Authentication連携**
  - メール/パスワード認証
  - エラーメッセージの日本語化
  - ローディング状態表示
  
- **UI機能**
  - パスワード表示/非表示切替
  - レスポンシブデザイン（モバイル対応）
  - アニメーション効果
  
- **バリデーション**
  - メールアドレス形式チェック
  - 必須項目チェック
  - Firebase エラーハンドリング

#### 2. ダッシュボード画面
- **統計情報表示**
  - 登録ユーザー数（Firestore連携）
  - 総予約数（Firestore連携）
  - 登録スタッフ数（Firestore連携）
  - 総売上（予約データから計算）
  
- **ユーザー情報**
  - ログイン中のメールアドレス表示
  - 最終ログイン時刻表示
  - ウェルカムメッセージ
  
- **機能メニュー**
  - Flutterアプリへのリンク
  - ユーザー管理（準備中）
  - 予約管理（準備中）
  - スタッフ管理（準備中）
  - 分析レポート（準備中）
  - システム設定（準備中）

#### 3. ログアウト機能
- **セキュアなログアウト**
  - Firebase認証からサインアウト
  - ローカルストレージのクリア
  - ログインページへリダイレクト
  - 確認ダイアログ表示

#### 4. セッション管理
- **自動リダイレクト**
  - 未ログイン時：ログインページへ
  - ログイン済み時：ダッシュボードへ
  
- **認証状態の永続化**
  - Firebase Local Persistence使用
  - ページリロード後も認証状態を維持
  - ローカルストレージでセッション管理

---

## 🛠 技術構成

### フロントエンド
- **HTML5**: セマンティックなマークアップ
- **CSS3**: モダンなスタイリング、アニメーション
- **JavaScript (ES6+)**: 認証ロジック、DOM操作

### バックエンド・認証
- **Firebase Authentication**: ユーザー認証
- **Cloud Firestore**: 統計データ取得
- **Firebase SDK 10.7.1**: 互換モード使用

### デザイン
- **レスポンシブデザイン**: モバイル・デスクトップ対応
- **Google Fonts**: Noto Sans JP
- **カラースキーム**: 
  - プライマリ: `#1976D2`（ブルー）
  - グラデーション: `#667eea` → `#764ba2`

---

## 📁 ファイル構成

```
/home/user/flutter_app/web_auth/
├── login.html                 # ログイン画面
├── dashboard.html             # ダッシュボード画面
├── css/
│   ├── style.css             # ログイン画面スタイル
│   └── dashboard.css         # ダッシュボードスタイル
└── js/
    ├── firebase-config.js    # Firebase設定
    ├── auth.js               # 認証ロジック
    └── dashboard.js          # ダッシュボードロジック
```

---

## 🔐 セキュリティ機能

### 認証・認可
- ✅ Firebase Authentication による安全な認証
- ✅ HTTPS通信必須
- ✅ セッション管理とタイムアウト
- ✅ 認証状態の自動チェック

### データ保護
- ✅ パスワードの暗号化保存（Firebase側）
- ✅ ローカルストレージの適切な管理
- ✅ XSS対策（入力値のエスケープ）
- ✅ CSRF対策（Firebase SDK標準機能）

---

## 🚀 使い方

### 1. ログイン方法

1. **ログインページにアクセス**
   ```
   https://5060-ivmmk44rjvkdnze0ep01h-c81df28e.sandbox.novita.ai/login.html
   ```

2. **認証情報を入力**
   - メールアドレス: Flutterアプリで登録したメールアドレス
   - パスワード: 登録時に設定したパスワード

3. **「ログイン」ボタンをクリック**
   - 認証成功：ダッシュボードへ自動リダイレクト
   - 認証失敗：エラーメッセージが表示

### 2. ダッシュボード機能

#### 統計情報の確認
- **リアルタイム統計**: Firestoreから最新データを取得
- **自動更新**: ページリロードで最新情報に更新

#### ログアウト
- 右上の「ログアウト」ボタンをクリック
- 確認ダイアログで「OK」を選択
- ログインページへリダイレクト

---

## 🔧 Firebase設定

### 現在の設定（開発環境用）
```javascript
const firebaseConfig = {
    apiKey: "AIzaSyDemoKeyForWebPlatform123456789",
    authDomain: "staff-finder-demo.firebaseapp.com",
    projectId: "staff-finder-demo",
    storageBucket: "staff-finder-demo.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef123456",
    measurementId: "G-ABCDEFGHIJ"
};
```

### 本番環境への移行手順

1. **Firebase Consoleで実際のプロジェクトを作成**
   - https://console.firebase.google.com/

2. **Web アプリを追加**
   - プロジェクト設定 → アプリを追加 → Web

3. **設定値を取得**
   - Firebase SDK設定値をコピー

4. **`firebase-config.js` を更新**
   ```javascript
   // /home/user/flutter_app/web_auth/js/firebase-config.js
   const firebaseConfig = {
       apiKey: "YOUR_ACTUAL_API_KEY",
       authDomain: "YOUR_PROJECT.firebaseapp.com",
       projectId: "YOUR_PROJECT_ID",
       // ... その他の設定
   };
   ```

5. **ビルドディレクトリに再コピー**
   ```bash
   cp -r /home/user/flutter_app/web_auth/* /home/user/flutter_app/build/web/
   ```

---

## 📊 統計データの取得方法

### Firestoreコレクション構造

```javascript
// ユーザー数
db.collection('users').get()

// 予約数
db.collection('bookings').get()

// スタッフ数
db.collection('staff').get()

// 売上計算
// bookings コレクションの status='completed' の price を合計
```

---

## 🎨 カスタマイズ

### カラーテーマの変更

**プライマリカラー変更:**
```css
/* css/style.css, css/dashboard.css */
.btn-login {
    background: linear-gradient(135deg, #YOUR_COLOR_1 0%, #YOUR_COLOR_2 100%);
}
```

**グラデーション背景変更:**
```css
body {
    background: linear-gradient(135deg, #YOUR_COLOR_1 0%, #YOUR_COLOR_2 100%);
}
```

---

## ⚠️ トラブルシューティング

### ログインできない場合

1. **Firebaseプロジェクトの確認**
   - Firebase Console でプロジェクトが正しく設定されているか確認
   - Authentication が有効になっているか確認

2. **ユーザーアカウントの確認**
   - Flutterアプリで先にユーザー登録を完了しているか確認
   - メールアドレス・パスワードが正しいか確認

3. **ブラウザコンソールの確認**
   - F12キーで開発者ツールを開く
   - Consoleタブでエラーメッセージを確認

### 統計データが表示されない場合

1. **Firestoreセキュリティルール確認**
   - 開発環境では `allow read: if true` が設定されているか確認

2. **データの存在確認**
   - Firebase Console でコレクションにデータが存在するか確認

3. **ネットワーク接続確認**
   - インターネット接続が正常か確認

---

## 📝 今後の拡張予定

### フェーズ2
- [ ] ユーザー管理画面（一覧・詳細・編集）
- [ ] 予約管理画面（確認・キャンセル）
- [ ] スタッフ管理画面（承認・編集）
- [ ] 分析レポート（グラフ・チャート）

### フェーズ3
- [ ] システム設定画面
- [ ] 通知管理
- [ ] バックアップ・エクスポート機能
- [ ] 多言語対応

---

## 📞 サポート

- **技術サポート**: tech@staffsearch.example.com
- **GitHub Issues**: 問題報告・機能リクエスト

---

**制定日**: 2025年1月1日  
**最終更新**: 2025年3月7日  
**バージョン**: v1.0

---

© 2025 staffsearch. All Rights Reserved.
