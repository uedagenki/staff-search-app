import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/local_auth_service.dart';
import 'register_screen.dart';
import 'staff/staff_registration_screen.dart';
import 'registration_type_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = LocalAuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      // ログイン成功 - ホーム画面に遷移し、履歴をクリア
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false, // すべての履歴をクリア
      );
    } else {
      // エラー表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('メールアドレスを入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正しいメールアドレスを入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('パスワードリセット'),
        content: Text('$email にパスワードリセット用のメールを送信します。よろしいですか?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('送信'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // パスワードリセットメール送信
    final result = await _authService.sendPasswordResetEmail(email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStaffMode = _tabController.index == 1;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // ロゴ
                Image.asset(
                  'assets/images/staff-search-logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 24),
                
                // タイトル
                Text(
                  'スタッフサーチ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '最適なスタッフをすぐに見つける',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // ユーザー/スタッフ切り替えタブ
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    onTap: (_) => setState(() {}),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.person),
                        text: 'ユーザー',
                      ),
                      Tab(
                        icon: Icon(Icons.work),
                        text: 'スタッフ',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // メールアドレス入力
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    if (!value.contains('@')) {
                      return '正しいメールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // パスワード入力
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ログインボタン
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ログイン',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // パスワードを忘れた場合
                TextButton(
                  onPressed: _handlePasswordReset,
                  child: const Text('パスワードをお忘れですか？'),
                ),
                const SizedBox(height: 24),

                // 区切り線
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'または',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),

                // 新規登録ボタン
                OutlinedButton(
                  onPressed: () {
                    if (isStaffMode) {
                      // スタッフ登録画面に遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StaffRegistrationScreen(),
                        ),
                      );
                    } else {
                      // 通常のユーザー登録画面に遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isStaffMode ? 'スタッフ新規登録' : 'ユーザー新規登録',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 企業/店舗登録ボタン
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationTypeSelectionScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: Colors.blue[700]!,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '企業・店舗として登録',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // デモアカウントでログイン（目立つデザイン）
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isStaffMode ? Colors.purple[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isStaffMode ? Colors.purple[200]! : Colors.orange[200]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: isStaffMode ? Colors.purple[700] : Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'すぐに試したい方へ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isStaffMode ? Colors.purple[700] : Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : () async {
                          setState(() => _isLoading = true);
                          
                          try {
                            if (kDebugMode) {
                              debugPrint('🔧 デモログイン開始: ${isStaffMode ? "スタッフ" : "ユーザー"}モード');
                            }
                            
                            if (isStaffMode) {
                              // スタッフデモユーザーを作成
                              if (kDebugMode) {
                                debugPrint('📝 スタッフデモユーザー作成中...');
                              }
                              await _authService.createStaffDemoUser();
                              
                              // スタッフデモユーザーでログイン
                              _emailController.text = 'staff-demo@example.com';
                              _passwordController.text = 'demo123';
                              
                              if (kDebugMode) {
                                debugPrint('🔐 スタッフデモアカウントでログイン試行...');
                              }
                            } else {
                              // ユーザーデモアカウントを作成
                              if (kDebugMode) {
                                debugPrint('📝 ユーザーデモアカウント作成中...');
                              }
                              await _authService.createDemoUser();
                              
                              // デモユーザーでログイン
                              _emailController.text = 'demo@example.com';
                              _passwordController.text = 'demo123';
                              
                              if (kDebugMode) {
                                debugPrint('🔐 ユーザーデモアカウントでログイン試行...');
                              }
                            }
                            
                            await _handleLogin();
                            
                            if (kDebugMode) {
                              debugPrint('✅ デモログイン処理完了');
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              debugPrint('❌ デモログインエラー: $e');
                            }
                            setState(() => _isLoading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('デモログインに失敗しました: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.play_circle_outline, size: 24),
                        label: Text(
                          isStaffMode ? 'スタッフデモアカウント' : 'ユーザーデモアカウント',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isStaffMode ? Colors.purple[400] : Colors.orange[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isStaffMode 
                            ? 'スタッフ機能を体験できます' 
                            : 'アカウント登録不要で全機能を体験できます',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
