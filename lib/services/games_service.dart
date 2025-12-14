import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game.dart';

class GamesService {
  static final GamesService _instance = GamesService._internal();
  factory GamesService() => _instance;
  GamesService._internal();

  List<Game>? _games;
  bool _isLoaded = false;

  Future<List<Game>> loadGames() async {
    if (_isLoaded && _games != null) {
      return _games!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/games-data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> gamesJson = jsonData['games'] as List<dynamic>;

      _games = gamesJson.map((json) => Game.fromJson(json as Map<String, dynamic>)).toList();

      _enrichGamesData();

      _isLoaded = true;
      return _games!;
    } catch (e) {
      print('Error loading games: $e');
      return [];
    }
  }

  void _enrichGamesData() {
    if (_games == null || _games!.isEmpty) return;

    for (int i = 0; i < _games!.length && i < 6; i++) {
      _games![i] = _games![i].copyWith(isFeatured: true);
    }

    for (int i = 0; i < _games!.length; i++) {
      if (i % 5 == 0) {
        _games![i] = _games![i].copyWith(isNew: true);
      }
    }

    for (int i = 0; i < _games!.length; i++) {
      if (i % 3 == 0) {
        _games![i] = _games![i].copyWith(isPopular: true);
      }
    }
  }

  List<Game> get allGames => _games ?? [];

  List<Game> get featuredGames => _games?.where((game) => game.isFeatured).toList() ?? [];

  List<Game> get newGames => _games?.where((game) => game.isNew).toList() ?? [];

  List<Game> get popularGames => _games?.where((game) => game.isPopular).toList() ?? [];

  List<Game> searchGames(String query) {
    if (_games == null || query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _games!.where((game) => game.name.toLowerCase().contains(lowerQuery)).toList();
  }

  Game? getGameById(String id) {
    if (_games == null) return null;

    try {
      return _games!.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Game> getSimilarGames(Game game, {int limit = 6}) {
    if (_games == null) return [];

    final otherGames = _games!.where((g) => g.id != game.id).toList();

    otherGames.shuffle();
    return otherGames.take(limit).toList();
  }

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
        break;
    }

    return sortedGames;
  }

  int get totalGamesCount => _games?.length ?? 0;

  String get formattedTotalGames => '$totalGamesCount Games';

  void clearCache() {
    _games = null;
    _isLoaded = false;
  }
}
