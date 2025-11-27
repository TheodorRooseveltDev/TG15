import 'dart:math';

/// Game model representing a slot machine game
class Game {
  final String id;
  final String name;
  final String iframe;
  final String image;
  final String? animatedLogo; // Animated SVG logo path for WebView display

  // Additional fields for rich game data
  final String? provider;
  final String? category;
  final double? rtp;
  final String? volatility;
  final int? paylines;
  final bool isFeatured;
  final bool isNew;
  final bool isPopular;
  final DateTime? releaseDate;
  final int playersCount;
  final double rating;

  Game({
    required this.id,
    required this.name,
    required this.iframe,
    required this.image,
    this.animatedLogo,
    this.provider,
    this.category,
    this.rtp,
    this.volatility,
    this.paylines,
    this.isFeatured = false,
    this.isNew = false,
    this.isPopular = false,
    this.releaseDate,
    int? playersCount,
    double? rating,
  })  : playersCount = playersCount ?? _generateRandomPlayers(),
        rating = rating ?? _generateRandomRating();

  /// Factory constructor from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      iframe: json['iframe'] as String,
      image: json['image'] as String,
      animatedLogo: json['animatedLogo'] as String?,
      provider: json['provider'] as String?,
      category: json['category'] as String?,
      rtp: json['rtp'] != null ? (json['rtp'] as num).toDouble() : null,
      volatility: json['volatility'] as String?,
      paylines: json['paylines'] as int?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'] as String)
          : null,
      playersCount: json['playersCount'] as int?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iframe': iframe,
      'image': image,
      if (animatedLogo != null) 'animatedLogo': animatedLogo,
      if (provider != null) 'provider': provider,
      if (category != null) 'category': category,
      if (rtp != null) 'rtp': rtp,
      if (volatility != null) 'volatility': volatility,
      if (paylines != null) 'paylines': paylines,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'isPopular': isPopular,
      if (releaseDate != null) 'releaseDate': releaseDate!.toIso8601String(),
      'playersCount': playersCount,
      'rating': rating,
    };
  }

  /// Generate random players count for realistic feel (100-5000)
  static int _generateRandomPlayers() {
    final random = Random();
    return 100 + random.nextInt(4900);
  }

  /// Generate random rating between 4.0 and 5.0
  static double _generateRandomRating() {
    final random = Random();
    return 4.0 + random.nextDouble();
  }

  /// Get formatted players count (e.g., "1.2K", "234")
  String get formattedPlayersCount {
    if (playersCount >= 1000) {
      return '${(playersCount / 1000).toStringAsFixed(1)}K';
    }
    return playersCount.toString();
  }

  /// Get RTP or generate random one between 94-97%
  double get effectiveRtp {
    if (rtp != null) return rtp!;
    final random = Random();
    return 94.0 + random.nextDouble() * 3.0;
  }

  /// Get volatility or generate random one
  String get effectiveVolatility {
    if (volatility != null) return volatility!;
    final random = Random();
    final volatilities = ['Low', 'Medium', 'High'];
    return volatilities[random.nextInt(volatilities.length)];
  }

  /// Get paylines or generate random one
  int get effectivePaylines {
    if (paylines != null) return paylines!;
    final random = Random();
    final paylineOptions = [10, 20, 25, 40, 243];
    return paylineOptions[random.nextInt(paylineOptions.length)];
  }

  /// Get provider or default
  String get effectiveProvider {
    return provider ?? 'Premium Gaming';
  }

  /// Get release year
  String get releaseYear {
    if (releaseDate != null) {
      return releaseDate!.year.toString();
    }
    final random = Random();
    return (2020 + random.nextInt(5)).toString();
  }

  /// Generate short subtitle for game cards
  String get subtitle {
    return '${effectiveVolatility} volatility • $effectivePaylines paylines • Premium slot experience';
  }

  /// Generate game description
  String get description {
    return '''Experience the thrill of ${name}, a premium slot game that brings excitement and entertainment to your fingertips.

This stunning game features high-quality graphics, smooth animations, and engaging gameplay mechanics that will keep you spinning for hours. With its ${effectiveVolatility.toLowerCase()} volatility and $effectivePaylines paylines, every spin offers the potential for big wins and exciting bonus features.

Immerse yourself in the captivating theme and enjoy special features including Free Spins, Wild Symbols, Scatter Pays, and exciting Bonus Rounds. The game's intuitive interface makes it easy to play, while the sophisticated design ensures a premium gaming experience.''';
  }

  /// Get game features list
  List<String> get features {
    return [
      'Free Spins',
      'Wild Symbols',
      'Scatter Pays',
      'Bonus Rounds',
      'Multipliers',
      if (effectiveVolatility == 'High') 'Big Win Potential',
      if (paylines != null && paylines! > 100) 'Ways to Win',
    ];
  }

  /// Copy with method for creating modified copies
  Game copyWith({
    String? id,
    String? name,
    String? iframe,
    String? image,
    String? animatedLogo,
    String? provider,
    String? category,
    double? rtp,
    String? volatility,
    int? paylines,
    bool? isFeatured,
    bool? isNew,
    bool? isPopular,
    DateTime? releaseDate,
    int? playersCount,
    double? rating,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      iframe: iframe ?? this.iframe,
      image: image ?? this.image,
      animatedLogo: animatedLogo ?? this.animatedLogo,
      provider: provider ?? this.provider,
      category: category ?? this.category,
      rtp: rtp ?? this.rtp,
      volatility: volatility ?? this.volatility,
      paylines: paylines ?? this.paylines,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isPopular: isPopular ?? this.isPopular,
      releaseDate: releaseDate ?? this.releaseDate,
      playersCount: playersCount ?? this.playersCount,
      rating: rating ?? this.rating,
    );
  }
}
