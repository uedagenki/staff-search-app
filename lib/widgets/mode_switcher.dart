import 'package:flutter/material.dart';
import '../services/app_mode_service.dart';

/// モード切り替えボタンウィジェット
class ModeSwitcher extends StatelessWidget {
  final AppModeService modeService;
  final VoidCallback? onModeChanged;

  const ModeSwitcher({
    super.key,
    required this.modeService,
    this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: modeService,
      builder: (context, child) {
        final isUserMode = modeService.currentMode == AppMode.user;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ユーザーモードボタン
              _ModeButton(
                icon: Icons.person_outline,
                label: 'ユーザー',
                isActive: isUserMode,
                activeColor: const Color(0xFF667EEA),
                onTap: () => _switchToUserMode(context),
              ),
              const SizedBox(width: 4),
              // スタッフモードボタン
              _ModeButton(
                icon: Icons.work_outline,
                label: 'スタッフ',
                isActive: !isUserMode,
                activeColor: const Color(0xFFF093FB),
                onTap: () => _switchToStaffMode(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _switchToUserMode(BuildContext context) {
    if (modeService.currentMode == AppMode.user) return;

    if (!modeService.isUserLoggedIn) {
      _showLoginRequiredDialog(context, AppMode.user);
      return;
    }

    modeService.switchMode(AppMode.user).then((success) {
      if (success) {
        onModeChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ユーザーモードに切り替えました'),
            backgroundColor: Color(0xFF667EEA),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _switchToStaffMode(BuildContext context) {
    if (modeService.currentMode == AppMode.staff) return;

    if (!modeService.isStaffLoggedIn) {
      _showLoginRequiredDialog(context, AppMode.staff);
      return;
    }

    modeService.switchMode(AppMode.staff).then((success) {
      if (success) {
        onModeChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('スタッフモードに切り替えました'),
            backgroundColor: Color(0xFFF093FB),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _showLoginRequiredDialog(BuildContext context, AppMode targetMode) {
    final modeName = targetMode == AppMode.user ? 'ユーザー' : 'スタッフ';
    final loginUrl = targetMode == AppMode.user 
        ? 'user_login.html' 
        : 'https://5061-ivmmk44rjvkdnze0ep01h-5185f4aa.sandbox.novita.ai/staff_login.html';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$modeName登録が必要です'),
        content: Text('$modeNameモードを使用するには、${modeName}としてログインする必要があります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: ログイン画面に遷移
              debugPrint('ログイン画面へ遷移: $loginUrl');
            },
            child: const Text('ログイン'),
          ),
        ],
      ),
    );
  }
}

/// モードボタン（内部ウィジェット）
class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// シンプルなモード切り替えドロップダウン（ヘッダー用）
class ModeDropdown extends StatelessWidget {
  final AppModeService modeService;
  final VoidCallback? onModeChanged;

  const ModeDropdown({
    super.key,
    required this.modeService,
    this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: modeService,
      builder: (context, child) {
        return PopupMenuButton<AppMode>(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  modeService.currentMode == AppMode.user
                      ? Icons.person_outline
                      : Icons.work_outline,
                  size: 16,
                  color: modeService.currentMode == AppMode.user
                      ? const Color(0xFF667EEA)
                      : const Color(0xFFF093FB),
                ),
                const SizedBox(width: 6),
                Text(
                  modeService.modeName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: AppMode.user,
              enabled: modeService.isUserLoggedIn,
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 18, color: Color(0xFF667EEA)),
                  const SizedBox(width: 8),
                  Text(
                    'ユーザーモード',
                    style: TextStyle(
                      color: modeService.isUserLoggedIn ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (!modeService.isUserLoggedIn) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: AppMode.staff,
              enabled: modeService.isStaffLoggedIn,
              child: Row(
                children: [
                  const Icon(Icons.work_outline, size: 18, color: Color(0xFFF093FB)),
                  const SizedBox(width: 8),
                  Text(
                    'スタッフモード',
                    style: TextStyle(
                      color: modeService.isStaffLoggedIn ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (!modeService.isStaffLoggedIn) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
                  ],
                ],
              ),
            ),
          ],
          onSelected: (mode) {
            modeService.switchMode(mode).then((success) {
              if (success) {
                onModeChanged?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${mode == AppMode.user ? 'ユーザー' : 'スタッフ'}モードに切り替えました'),
                    backgroundColor: mode == AppMode.user ? const Color(0xFF667EEA) : const Color(0xFFF093FB),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            });
          },
        );
      },
    );
  }
}
