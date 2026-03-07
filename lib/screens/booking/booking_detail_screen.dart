import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';

/// 予約詳細画面（ユーザー・スタッフ共通）
class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日 (E)', 'ja_JP');

    return Scaffold(
      appBar: AppBar(
        title: const Text('予約詳細'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ステータスカード
          Card(
            elevation: 0,
            color: _getStatusColor(booking.status).withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    booking.status.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.status.displayName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '予約ID: ${booking.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 予約情報
          _buildSectionCard(
            '予約情報',
            Icons.calendar_today,
            [
              _buildInfoRow('予約日', dateFormat.format(booking.bookingDate)),
              _buildInfoRow('予約時間', booking.bookingTime),
              _buildInfoRow(
                '所要時間',
                '${booking.menus.fold(0, (sum, m) => sum + m.duration)}分',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // スタッフ情報
          _buildSectionCard(
            'スタッフ情報',
            Icons.person,
            [
              _buildInfoRow('スタッフ名', booking.staffName),
              _buildInfoRow('職種', booking.staffJobTitle),
              if (booking.storeName != null)
                _buildInfoRow('店舗名', booking.storeName!),
              if (booking.storeAddress != null)
                _buildInfoRow('住所', booking.storeAddress!),
            ],
          ),

          const SizedBox(height: 16),

          // お客様情報
          _buildSectionCard(
            'お客様情報',
            Icons.account_circle,
            [
              _buildInfoRow('お名前', booking.userName),
              _buildInfoRow('メール', booking.userEmail),
              if (booking.userPhone != null)
                _buildInfoRow('電話番号', booking.userPhone!),
            ],
          ),

          const SizedBox(height: 16),

          // メニュー情報
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'メニュー',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...booking.menus.map((menu) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${menu.duration}分',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '¥${_formatPrice(menu.price)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 料金情報
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPriceRow('合計金額', booking.totalPrice),
                  if (booking.discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'クーポン割引',
                      booking.discountAmount,
                      isDiscount: true,
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '最終金額',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '¥${_formatPrice(booking.finalPrice)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 備考
          if (booking.note != null && booking.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        const Text(
                          '備考',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      booking.note!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // キャンセル理由
          if (booking.status == BookingStatus.cancelled &&
              booking.cancellationReason != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'キャンセル理由',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      booking.cancellationReason!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 作成日時
          Text(
            '予約作成日時: ${DateFormat('yyyy/MM/dd HH:mm').format(booking.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int price, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDiscount ? Colors.red[700] : null,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}¥${_formatPrice(price)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDiscount ? Colors.red[700] : null,
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    final formatter = NumberFormat('#,###');
    return formatter.format(price);
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}
