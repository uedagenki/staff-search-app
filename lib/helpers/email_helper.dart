import 'package:url_launcher/url_launcher.dart';

class EmailHelper {
  // メール送信用ヘルパー
  static Future<void> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'メールアプリを起動できませんでした';
    }
  }

  // パスワード変更通知メール
  static Future<void> sendPasswordChangeNotification(String email) async {
    await sendEmail(
      to: 'support@staff-finder.com',
      subject: 'パスワード変更通知',
      body: '''
以下のアカウントのパスワード変更リクエストがありました:

メールアドレス: $email
変更日時: ${DateTime.now()}

このメールに心当たりがない場合は、すぐにサポートにご連絡ください。
      ''',
    );
  }

  // 新規登録通知メール
  static Future<void> sendRegistrationNotification(String email, String name) async {
    await sendEmail(
      to: email,
      subject: 'Staff Finder へようこそ!',
      body: '''
$name 様

Staff Finder へのご登録ありがとうございます!

アカウントが正常に作成されました。
今すぐアプリにログインして、素晴らしいスタッフとつながりましょう!

ご不明な点がございましたら、お気軽にお問い合わせください。

Staff Finder チーム
      ''',
    );
  }

  // 予約確認メール
  static Future<void> sendBookingConfirmation({
    required String email,
    required String staffName,
    required DateTime date,
    required String timeSlot,
  }) async {
    await sendEmail(
      to: email,
      subject: '予約確認 - $staffName',
      body: '''
予約が確定しました!

スタッフ: $staffName
日時: ${date.year}年${date.month}月${date.day}日 $timeSlot

予約の詳細はアプリの「予約」タブからご確認いただけます。

Staff Finder チーム
      ''',
    );
  }

  // サポートメール
  static Future<void> sendSupportEmail({
    String? subject,
    String? message,
  }) async {
    await sendEmail(
      to: 'support@staff-finder.com',
      subject: subject ?? 'サポートリクエスト',
      body: message ?? '',
    );
  }
}
