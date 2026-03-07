# 🔥 Firebase設定が必要です

## 現在の状況

スタッフログイン機能は実装済みですが、**Firebase設定ファイルが未配置**のため、アカウント作成とログインができません。

## 必要な設定ファイル

### 1. Firebase Admin SDK キー（サーバー側操作用）
**配置先:** `/opt/flutter/firebase-admin-sdk.json`

**取得方法:**
1. Firebase Console: https://console.firebase.google.com/
2. プロジェクト選択 → 設定（歯車アイコン） → プロジェクトの設定
3. 「サービスアカウント」タブ
4. 「Python」を選択
5. 「新しい秘密鍵の生成」をクリック
6. ダウンロードしたJSONファイルを上記パスに配置

### 2. google-services.json（Android用）
**配置先:** `/opt/flutter/google-services.json`

**取得方法:**
1. Firebase Console: https://console.firebase.google.com/
2. プロジェクト選択 → プロジェクト設定
3. 「全般」タブ → Androidアプリ
4. `google-services.json` をダウンロード
5. ダウンロードしたファイルを上記パスに配置

### 3. Firebase Options（Web/Flutter用）
**配置先:** `/home/user/flutter_app/lib/firebase_options.dart`

**取得方法:**
1. Firebase Console: https://console.firebase.google.com/
2. プロジェクト選択 → プロジェクト設定
3. 「全般」タブ → Webアプリ
4. Firebase SDK スニペットから設定情報を取得
5. `firebase_options.dart` に設定を追加

## デモアカウント情報

### ユーザーデモアカウント
```
メールアドレス: demo@example.com
パスワード: demo123
役割: user
```

### スタッフデモアカウント
```
メールアドレス: staff-demo@example.com
パスワード: demo123
役割: staff
スタッフ登録: 済み
```

## Firebase設定後の手順

1. **Firestore Database を作成**
   - Firebase Console → Firestore Database
   - 「データベースを作成」をクリック
   - テストモードまたは本番モードを選択

2. **Authentication を有効化**
   - Firebase Console → Authentication
   - 「始める」をクリック
   - メール/パスワード認証を有効化

3. **デモアカウントを作成**
   ```bash
   # Flutter アプリのデモアカウント作成ボタンをクリック
   # または Firebase Console から手動で作成
   ```

4. **アプリを再ビルド**
   ```bash
   cd /home/user/flutter_app
   flutter build web --release
   python3 -m http.server 5060 --directory build/web --bind 0.0.0.0
   ```

## 現在の実装状況

✅ **実装済み:**
- ユーザー/スタッフ切り替えタブ
- スタッフ新規登録画面への遷移
- スタッフデモアカウント作成機能
- ログイン処理（Firebase Auth連携）
- 詳細なデバッグログ

⚠️ **要設定:**
- Firebase設定ファイルの配置
- Firestore Database の作成
- Authentication の有効化

## トラブルシューティング

### ログインできない場合
1. ブラウザのコンソール（F12）でエラーを確認
2. Firebase設定ファイルが正しく配置されているか確認
3. Firebase Console で Authentication が有効化されているか確認
4. Firestore Database が作成されているか確認

### エラーメッセージ
- `No Firebase App '[DEFAULT]' has been created` 
  → `firebase_options.dart` が未設定

- `Failed to get document because the client is offline`
  → Firebase設定が正しくない、またはネットワークエラー

- `PERMISSION_DENIED`
  → Firestoreのセキュリティルールを確認

## サポート

Firebase設定でお困りの場合は、Firebase公式ドキュメントを参照してください：
https://firebase.google.com/docs/flutter/setup
