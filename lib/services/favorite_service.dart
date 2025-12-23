import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoriteKey = 'favorite_staff_ids';
  
  // お気に入りリストを取得
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteKey) ?? [];
  }
  
  // お気に入りに追加
  Future<void> addFavorite(String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(staffId)) {
      favorites.add(staffId);
      await prefs.setStringList(_favoriteKey, favorites);
    }
  }
  
  // お気に入りから削除
  Future<void> removeFavorite(String staffId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(staffId);
    await prefs.setStringList(_favoriteKey, favorites);
  }
  
  // お気に入りかどうかチェック
  Future<bool> isFavorite(String staffId) async {
    final favorites = await getFavorites();
    return favorites.contains(staffId);
  }
  
  // お気に入りをトグル
  Future<bool> toggleFavorite(String staffId) async {
    final isFav = await isFavorite(staffId);
    if (isFav) {
      await removeFavorite(staffId);
      return false;
    } else {
      await addFavorite(staffId);
      return true;
    }
  }
}
