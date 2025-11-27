import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/constants.dart';
import '../models/game.dart';
import '../services/games_service.dart';
import '../services/settings_service.dart';
import '../widgets/app_background.dart';
import '../widgets/animated_svg_logo.dart';
import 'game_play_screen.dart';

/// CRITICAL: Game detail screen - MUST be shown before playing
class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> with TickerProviderStateMixin {
  final GamesService _gamesService = GamesService();
  final SettingsService _settingsService = SettingsService();
  List<Game> _similarGames = [];
  List<String> _availableScreenshots = [];
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadSimilarGames();
    _loadAvailableScreenshots();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadSimilarGames() {
    _similarGames = _gamesService.getSimilarGames(widget.game, limit: 6);
  }

  Future<void> _loadAvailableScreenshots() async {
    final screenshots = <String>[];
    final gameId = widget.game.id;
    
    for (int i = 1; i <= 5; i++) {
      final pathJpg = 'assets/images/game-screenshots/$gameId/screenshot_$i.jpg';
      final pathJpeg = 'assets/images/game-screenshots/$gameId/screenshot_$i.jpeg';
      
      try {
        await rootBundle.load(pathJpg);
        screenshots.add(pathJpg);
      } catch (e) {
        try {
          await rootBundle.load(pathJpeg);
          screenshots.add(pathJpeg);
        } catch (e) {
          break;
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _availableScreenshots = screenshots;
      });
    }
  }

  void _playGame() async {
    HapticFeedback.mediumImpact();
    
    await _settingsService.addRecentlyPlayed(widget.game.id);
    
    if (!mounted) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GamePlayScreen(game: widget.game),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AppBackground(),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 24),
                _buildPlayButton(),
                const SizedBox(height: 32),
                if (_availableScreenshots.isNotEmpty) ...[
                  _buildScreenshotSection(),
                  const SizedBox(height: 32),
                ],
                _buildAboutSection(),
                const SizedBox(height: 32),
                _buildSimilarGamesSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            child: _buildBackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppColors.purpleMuted.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            const Text(
              'Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2);
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        // Full-width hero image
        Container(
          height: 380,
          width: double.infinity,
          child: widget.game.image.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: widget.game.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.asset(
                  widget.game.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        // Gradient overlay - image fades out at bottom into background
        Container(
          height: 380,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                AppColors.backgroundPrimary.withOpacity(0.6),
                AppColors.backgroundPrimary,
              ],
              stops: const [0.0, 0.5, 0.85, 1.0],
            ),
          ),
        ),
        // Game icon + title/subtitle left-aligned at bottom
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Game icon/animated logo with gold border
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.goldAccent.withOpacity(0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: widget.game.animatedLogo != null
                      ? AnimatedSvgLogo(
                          assetPath: widget.game.animatedLogo!,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          backgroundColor: Colors.transparent,
                        )
                      : widget.game.image.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: widget.game.image,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.game.image,
                              fit: BoxFit.cover,
                            ),
                ),
              ).animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(width: 16),
              // Title + subtitle + short desc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.game.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 10),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms)
                        .slideX(begin: 0.1),
                    const SizedBox(height: 4),
                    Text(
                      widget.game.subtitle,
                      style: TextStyle(
                        color: AppColors.goldAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 8),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideX(begin: 0.1),
                    const SizedBox(height: 6),
                    Text(
                      widget.game.description.length > 80
                          ? widget.game.description.substring(0, 80) + '...'
                          : widget.game.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        height: 1.4,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 6),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).animate()
                        .fadeIn(delay: 350.ms, duration: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return GestureDetector(
            onTap: _playGame,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/main-button-bg.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purplePrimary.withOpacity(0.4 + _pulseController.value * 0.2),
                    blurRadius: 25 + _pulseController.value * 12,
                    spreadRadius: _pulseController.value * 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'PLAY NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildScreenshotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Screenshots',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 500.ms),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _availableScreenshots.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: EdgeInsets.only(right: index < _availableScreenshots.length - 1 ? 12 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.purpleMuted.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purplePrimary.withOpacity(0.15),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _availableScreenshots[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        widget.game.image,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (550 + index * 80).ms)
                  .slideX(begin: 0.1, delay: (550 + index * 80).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'About This Game',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms),
        
        const SizedBox(height: 16),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundSecondary.withOpacity(0.8),
                  AppColors.cardBackground.withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: AppColors.purpleMuted.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              widget.game.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 650.ms)
            .slideY(begin: 0.1, delay: 650.ms),
      ],
    );
  }

  Widget _buildSimilarGamesSection() {
    if (_similarGames.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'You Might Also Like',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 700.ms),
        
        const SizedBox(height: 16),
        
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _similarGames.length,
            itemBuilder: (context, index) {
              final game = _similarGames[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => GameDetailScreen(game: game),
                    ),
                  );
                },
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(right: index < _similarGames.length - 1 ? 12 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.purpleMuted.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purplePrimary.withOpacity(0.15),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                game.image.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: game.image,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        game.image,
                                        fit: BoxFit.cover,
                                      ),
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                                // Play icon
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        game.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        game.subtitle,
                        style: TextStyle(
                          color: AppColors.purpleLight.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (750 + index * 80).ms)
                  .slideX(begin: 0.1, delay: (750 + index * 80).ms);
            },
          ),
        ),
      ],
    );
  }
}
