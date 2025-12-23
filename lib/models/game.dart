import 'dart:math';

class Game {
  final String id;
  final String name;
  final String iframe;
  final String image;
  final String? animatedLogo; // GIF animated logo URL
  final String? tagline; // Short tagline from DB
  final String? descriptionText; // Full description from DB
  final String? bannerUrl; // Wide banner for detail page
  final List<String> screenshots; // Screenshot URLs from DB

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
    this.tagline,
    this.descriptionText,
    this.bannerUrl,
    this.screenshots = const [],
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

  /// Create from Supabase database response
  factory Game.fromSupabase(Map<String, dynamic> json, String Function(String?) getPublicUrl) {
    final screenshotsList = json['screenshots'] as List<dynamic>?;

    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      iframe: json['api_url'] as String? ?? '',
      image: getPublicUrl(json['logo_url'] as String?),
      animatedLogo: getPublicUrl(json['animated_logo_url'] as String?),
      tagline: json['tagline'] as String?,
      descriptionText: json['description'] as String?,
      bannerUrl: getPublicUrl(json['banner_url'] as String?),
      screenshots: screenshotsList != null
          ? screenshotsList
              .map((s) => getPublicUrl(s as String))
              .where((s) => s.isNotEmpty)
              .toList()
          : [],
      releaseDate: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  /// Create from local JSON (legacy support)
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      iframe: json['iframe'] as String? ?? json['api_url'] as String? ?? '',
      image: json['image'] as String? ?? json['logo_url'] as String? ?? '',
      animatedLogo: json['animatedLogo'] as String? ?? json['animated_logo_url'] as String?,
      tagline: json['tagline'] as String?,
      descriptionText: json['description'] as String?,
      bannerUrl: json['banner_url'] as String?,
      screenshots: json['screenshots'] != null
          ? List<String>.from(json['screenshots'])
          : [],
      provider: json['provider'] as String?,
      category: json['category'] as String?,
      rtp: json['rtp'] != null ? (json['rtp'] as num).toDouble() : null,
      volatility: json['volatility'] as String?,
      paylines: json['paylines'] as int?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      releaseDate: json['releaseDate'] != null ? DateTime.parse(json['releaseDate'] as String) : null,
      playersCount: json['playersCount'] as int?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iframe': iframe,
      'image': image,
      if (animatedLogo != null) 'animatedLogo': animatedLogo,
      if (tagline != null) 'tagline': tagline,
      if (descriptionText != null) 'description': descriptionText,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (screenshots.isNotEmpty) 'screenshots': screenshots,
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

  static int _generateRandomPlayers() {
    final random = Random();
    return 100 + random.nextInt(4900);
  }

  static double _generateRandomRating() {
    final random = Random();
    return 4.0 + random.nextDouble();
  }

  String get formattedPlayersCount {
    if (playersCount >= 1000) {
      return '${(playersCount / 1000).toStringAsFixed(1)}K';
    }
    return playersCount.toString();
  }

  double get effectiveRtp {
    if (rtp != null) return rtp!;
    final random = Random();
    return 94.0 + random.nextDouble() * 3.0;
  }

  String get effectiveVolatility {
    if (volatility != null) return volatility!;
    final random = Random();
    final volatilities = ['Low', 'Medium', 'High'];
    return volatilities[random.nextInt(volatilities.length)];
  }

  int get effectivePaylines {
    if (paylines != null) return paylines!;
    final random = Random();
    final paylineOptions = [10, 20, 25, 40, 243];
    return paylineOptions[random.nextInt(paylineOptions.length)];
  }

  String get effectiveProvider {
    return provider ?? '';
  }

  String get releaseYear {
    if (releaseDate != null) {
      return releaseDate!.year.toString();
    }
    final random = Random();
    return (2020 + random.nextInt(5)).toString();
  }

  /// Get subtitle - uses tagline from DB or generates one
  String get subtitle {
    if (tagline != null && tagline!.isNotEmpty) return tagline!;
    if (category != null && category!.isNotEmpty) return category!;
    if (provider != null && provider!.isNotEmpty) return provider!;
    return _generateSubtitle();
  }

  String _generateSubtitle() {
    final nameLower = name.toLowerCase();

    // Match themes based on name keywords
    if (nameLower.contains('olympus') || nameLower.contains('zeus') || nameLower.contains('god')) {
      return 'Divine Fortune';
    } else if (nameLower.contains('princess') || nameLower.contains('moon')) {
      return 'Magical Adventure';
    } else if (nameLower.contains('dead') || nameLower.contains('scroll') || nameLower.contains('tombstone') || nameLower.contains('crypt')) {
      return 'Ancient Mystery';
    } else if (nameLower.contains('money') || nameLower.contains('train') || nameLower.contains('riches') || nameLower.contains('bank') || nameLower.contains('iron')) {
      return 'Cash Chase';
    } else if (nameLower.contains('fruit') || nameLower.contains('flame') || nameLower.contains('fire')) {
      return 'Hot Action';
    } else if (nameLower.contains('gummy') || nameLower.contains('candy') || nameLower.contains('sweet')) {
      return 'Sweet Wins';
    } else if (nameLower.contains('bingo')) {
      return 'Lucky Numbers';
    } else if (nameLower.contains('pig') || nameLower.contains('heist')) {
      return 'Wild Heist';
    } else if (nameLower.contains('fish') || nameLower.contains('bubble') || nameLower.contains('ocean')) {
      return 'Ocean Fortune';
    } else if (nameLower.contains('roman') || nameLower.contains('barbarossa')) {
      return 'Epic Battle';
    } else if (nameLower.contains('bamboo') || nameLower.contains('panda')) {
      return 'Asian Fortune';
    } else if (nameLower.contains('retro') || nameLower.contains('tape')) {
      return 'Classic Vibes';
    } else if (nameLower.contains('mental') || nameLower.contains('brute')) {
      return 'Wild Chaos';
    } else if (nameLower.contains('xways') || nameLower.contains('xnudge') || nameLower.contains('xsplit')) {
      return 'Mega Ways';
    } else if (nameLower.contains('museum') || nameLower.contains('mystery')) {
      return 'Hidden Treasures';
    } else if (nameLower.contains('shark') || nameLower.contains('razor')) {
      return 'Ocean Hunt';
    } else if (nameLower.contains('quentin') || nameLower.contains('prison')) {
      return 'Prison Break';
    } else if (nameLower.contains('toonz') || nameLower.contains('react')) {
      return 'Alien Fun';
    } else if (nameLower.contains('plinko') || nameLower.contains('pine')) {
      return 'Drop & Win';
    } else if (nameLower.contains('snake') || nameLower.contains('arena')) {
      return 'Battle Arena';
    } else if (nameLower.contains('duck') || nameLower.contains('hunter')) {
      return 'Hunt & Win';
    } else if (nameLower.contains('dino') || nameLower.contains('polis')) {
      return 'Prehistoric Fun';
    } else if (nameLower.contains('nine') || nameLower.contains('five') || nameLower.contains('office')) {
      return 'Office Madness';
    } else if (nameLower.contains('jam') || nameLower.contains('jar')) {
      return 'Fruity Beats';
    } else if (nameLower.contains('boot') || nameLower.contains('das')) {
      return 'Deep Dive';
    } else if (nameLower.contains('outsource')) {
      return 'Corporate Chaos';
    } else if (nameLower.contains('pinata') || nameLower.contains('festival')) {
      return 'Fiesta Fun';
    } else {
      return 'Premium Slot';
    }
  }

  /// Get description - uses DB description or generates one
  String get description {
    if (descriptionText != null && descriptionText!.isNotEmpty) {
      return descriptionText!;
    }
    return '''Experience the thrill of $name, a premium slot game that brings excitement and entertainment to your fingertips.

This stunning game features high-quality graphics, smooth animations, and engaging gameplay mechanics that will keep you spinning for hours. With its ${effectiveVolatility.toLowerCase()} volatility and $effectivePaylines paylines, every spin offers the potential for big wins and exciting bonus features.

Immerse yourself in the captivating theme and enjoy special features including Free Spins, Wild Symbols, Scatter Pays, and exciting Bonus Rounds. The game's intuitive interface makes it easy to play, while the sophisticated design ensures a premium gaming experience.''';
  }

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

  Game copyWith({
    String? id,
    String? name,
    String? iframe,
    String? image,
    String? animatedLogo,
    String? tagline,
    String? descriptionText,
    String? bannerUrl,
    List<String>? screenshots,
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
      tagline: tagline ?? this.tagline,
      descriptionText: descriptionText ?? this.descriptionText,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      screenshots: screenshots ?? this.screenshots,
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
