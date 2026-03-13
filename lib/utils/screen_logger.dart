import 'package:flutter/widgets.dart';

/// Tickets that have a written spec in docs/screens/.
/// Update this set whenever a new spec is added to _INDEX.md.
const _spectTickets = {
  'AUTH-01', 'AUTH-02', 'AUTH-07',
  'DB-01', 'DB-02', 'DB-05',
  'STAFF-01', 'STAFF-02', 'STAFF-03', 'STAFF-05', 'STAFF-07',
  'FEED-01', 'FEED-02',
};

final _ticketPattern = RegExp(r'[A-Z]+-\d+');

String _scopeIcon(String screenId) {
  final tickets = _ticketPattern.allMatches(screenId).map((m) => m.group(0)!).toSet();
  if (tickets.isEmpty) return '⚪';
  return tickets.any(_spectTickets.contains) ? '✅' : '🔲';
}

/// Add this mixin to a [State] class to automatically log the screen name
/// and spec ticket ID when the screen is first mounted.
///
/// The log line includes a scope icon:
///   ✅  at least one referenced ticket has a written spec
///   🔲  tickets exist but none are specced yet
///   ⚪  no ticket reference (e.g. ADMIN screens)
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with ScreenLogMixin {
///   @override
///   String get screenId => 'My Screen | TICKET-01';
/// }
/// ```
mixin ScreenLogMixin<T extends StatefulWidget> on State<T> {
  String get screenId;

  @override
  void initState() {
    super.initState();
    debugPrint('📱 SCREEN: $screenId  ${_scopeIcon(screenId)}');
  }
}
