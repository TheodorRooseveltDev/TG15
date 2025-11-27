import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game.dart';

/// Service for loading and managing games data
class GamesService {
  static final GamesService _instance = GamesService._internal();
  factory GamesService() => _instance;
  GamesService._internal();

  List<Game>? _games;
  bool _isLoaded = false;

  /// Load games from JSON file
  Future<List<Game>> loadGames() async {
    if (_isLoaded && _games != null) {
      return _games!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/games-data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> gamesJson = jsonData['games'] as List<dynamic>;

      _games = gamesJson.map((json) => Game.fromJson(json as Map<String, dynamic>)).toList();
      
      // Mark some games as featured, new, or popular
      _enrichGamesData();
      
      _isLoaded = true;
      return _games!;
    } catch (e) {
      print('Error loading games: $e');
      return [];
    }
  }

  /// Enrich games data with featured, new, popular flags
  void _enrichGamesData() {
    if (_games == null || _games!.isEmpty) return;

    // Mark first 6 as featured (animated logo games)
    for (int i = 0; i < _games!.length && i < 6; i++) {
      _games![i] = _games![i].copyWith(isFeatured: true);
    }

    // Mark random games as new (20%)
    for (int i = 0; i < _games!.length; i++) {
      if (i % 5 == 0) {
        _games![i] = _games![i].copyWith(isNew: true);
      }
    }

    // Mark random games as popular (30%)
    for (int i = 0; i < _games!.length; i++) {
      if (i % 3 == 0) {
        _games![i] = _games![i].copyWith(isPopular: true);
      }
    }
  }

  /// Get all games
  List<Game> get allGames => _games ?? [];

  /// Get featured games
  List<Game> get featuredGames => _games?.where((game) => game.isFeatured).toList() ?? [];

  /// Get new games
  List<Game> get newGames => _games?.where((game) => game.isNew).toList() ?? [];

  /// Get popular games
  List<Game> get popularGames => _games?.where((game) => game.isPopular).toList() ?? [];

  /// Search games by name
  List<Game> searchGames(String query) {
    if (_games == null || query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return _games!.where((game) => 
      game.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get game by ID
  Game? getGameById(String id) {
    if (_games == null) return null;
    
    try {
      return _games!.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get similar games (same category or random selection)
  List<Game> getSimilarGames(Game game, {int limit = 6}) {
    if (_games == null) return [];
    
    // Filter out the current game
    final otherGames = _games!.where((g) => g.id != game.id).toList();
    
    // Shuffle and take the limit
    otherGames.shuffle();
    return otherGames.take(limit).toList();
  }

  /// Filter games by category
  List<Game> filterByCategory(String category) {
    if (_games == null) return [];
    
    switch (category.toLowerCase()) {
      case 'featured':
        return allGames; // Featured shows all games
      case 'new':
        return newGames;
      case 'popular':
        return popularGames;
      default:
        return allGames;
    }
  }

  /// Sort games
  List<Game> sortGames(List<Game> games, String sortBy) {
    final sortedGames = List<Game>.from(games);
    
    switch (sortBy.toLowerCase()) {
      case 'name':
      case 'a-z':
        sortedGames.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'rating':
        sortedGames.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'popular':
        sortedGames.sort((a, b) => b.playersCount.compareTo(a.playersCount));
        break;
      case 'rtp':
        sortedGames.sort((a, b) => b.effectiveRtp.compareTo(a.effectiveRtp));
        break;
      default:
        // Keep original order
        break;
    }
    
    return sortedGames;
  }

  /// Get total games count
  int get totalGamesCount => _games?.length ?? 0;

  /// Get formatted total games count
  String get formattedTotalGames => '$totalGamesCount Games';

  /// Clear cache (for testing)
  void clearCache() {
    _games = null;
    _isLoaded = false;
  }
}
