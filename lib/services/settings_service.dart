import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for managing app settings and preferences
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  // Keys
  static const String _keyAgeGateShown = 'age_gate_shown';
  static const String _keyHapticFeedback = 'haptic_feedback';
  static const String _keyBackgroundMusic = 'background_music';
  static const String _keyNotifications = 'notifications';
  static const String _keyFavoriteGames = 'favorite_games';
  static const String _keyRecentlyPlayed = 'recently_played';
  static const String _keyFirstLaunch = 'first_launch';

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Age Gate
  Future<bool> hasShownAgeGate() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyAgeGateShown) ?? false;
  }

  Future<void> setAgeGateShown() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyAgeGateShown, true);
  }

  // First Launch
  Future<bool> isFirstLaunch() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  // Haptic Feedback
  Future<bool> getHapticFeedback() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyHapticFeedback) ?? true;
  }

  Future<void> setHapticFeedback(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyHapticFeedback, value);
  }

  // Background Music
  Future<bool> getBackgroundMusic() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyBackgroundMusic) ?? true;
  }

  Future<void> setBackgroundMusic(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyBackgroundMusic, value);
  }

  // Notifications
  Future<bool> getNotifications() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyNotifications) ?? true;
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyNotifications, value);
  }

  // Favorite Games
  Future<List<String>> getFavoriteGames() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyFavoriteGames);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavoriteGame(String gameId) async {
    final favorites = await getFavoriteGames();
    if (!favorites.contains(gameId)) {
      favorites.add(gameId);
      await _saveFavoriteGames(favorites);
    }
  }

  Future<void> removeFavoriteGame(String gameId) async {
    final favorites = await getFavoriteGames();
    favorites.remove(gameId);
    await _saveFavoriteGames(favorites);
  }

  Future<bool> isFavorite(String gameId) async {
    final favorites = await getFavoriteGames();
    return favorites.contains(gameId);
  }

  Future<void> _saveFavoriteGames(List<String> favorites) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyFavoriteGames, json.encode(favorites));
  }

  // Recently Played Games
  Future<List<String>> getRecentlyPlayed() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyRecentlyPlayed);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<void> addRecentlyPlayed(String gameId) async {
    final recent = await getRecentlyPlayed();
    
    // Remove if already exists
    recent.remove(gameId);
    
    // Add to beginning
    recent.insert(0, gameId);
    
    // Keep only last 10
    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }
    
    await _saveRecentlyPlayed(recent);
  }

  Future<void> _saveRecentlyPlayed(List<String> recent) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyRecentlyPlayed, json.encode(recent));
  }

  Future<void> clearRecentlyPlayed() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyRecentlyPlayed);
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyRecentlyPlayed);
    // Don't clear favorites, age gate, or settings
  }

  // Reset all settings (for testing)
  Future<void> resetAllSettings() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
