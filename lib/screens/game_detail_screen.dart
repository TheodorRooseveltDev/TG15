import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/constants.dart';
import '../models/game.dart';
import '../services/games_service.dart';
import '../services/settings_service.dart';
import 'game_play_screen.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> with TickerProviderStateMixin {
  final GamesService _gamesService = GamesService();
  final SettingsService _settingsService = SettingsService();
  List<Game> _similarGames = [];
  List<String> _availableScreenshots = [];

  late AnimationController _pulseController;
  late AnimationController _glareController;

  @override
  void initState() {
    super.initState();
    _loadSimilarGames();
    _loadAvailableScreenshots();

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _glareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glareController.dispose();
    super.dispose();
  }

  void _loadSimilarGames() {
    _similarGames = _gamesService.getSimilarGames(widget.game, limit: 6);
  }

  Future<void> _loadAvailableScreenshots() async {
    // First check if the game has screenshots from database
    if (widget.game.screenshots.isNotEmpty) {
      if (mounted) {
        setState(() {
          _availableScreenshots = widget.game.screenshots;
        });
      }
      return;
    }

    // Fallback to local assets
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GamePlayScreen(game: widget.game),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: Container(color: Colors.black, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 16),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: _buildPlayButton()),
                const SizedBox(height: 32),
                if (_availableScreenshots.isNotEmpty) ...[_buildScreenshotSection(), const SizedBox(height: 32)],
                _buildAboutSection(),
                const SizedBox(height: 32),
                _buildSimilarGamesSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.0)],
                ),
              ),
            ),
          ),

          Positioned(top: MediaQuery.of(context).padding.top + 12, left: 20, child: _buildBackButton()),
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
          color: AppColors.cardBackground.withOpacity(0.9),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15),
            BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldPrimary],
              ).createShader(bounds),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 6),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldPrimary],
              ).createShader(bounds),
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2);
  }

  Widget _buildHeroSection() {
    // Use banner URL if available, otherwise fallback to animated logo or static image
    final heroImageUrl = widget.game.bannerUrl != null && widget.game.bannerUrl!.isNotEmpty
        ? widget.game.bannerUrl!
        : (widget.game.animatedLogo != null && widget.game.animatedLogo!.isNotEmpty
            ? widget.game.animatedLogo!
            : widget.game.image);

    return Stack(
      children: [
        SizedBox(
          height: 380,
          width: double.infinity,
          child: heroImageUrl.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: heroImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: AppColors.backgroundSecondary,
                    child: Center(child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => _buildHeroFallbackImage(),
                )
              : Image.asset(heroImageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        ),

        Container(
          height: 380,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
                AppColors.backgroundPrimary,
              ],
              stops: const [0.0, 0.4, 0.75, 1.0],
            ),
          ),
        ),

        // Gold shimmer line at bottom of hero
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldLight.withOpacity(0.3),
                  AppColors.goldPrimary.withOpacity(0.6),
                  AppColors.goldLight.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.game.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideX(begin: 0.1),
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: Text(
                  widget.game.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroFallbackImage() {
    // Fallback to static image if banner fails to load
    if (widget.game.image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.game.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: const Center(child: Icon(Icons.casino_rounded, size: 80, color: AppColors.goldAccent)),
        ),
      );
    }
    return Image.asset(widget.game.image, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _glareController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: _playGame,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              painter: _ButtonGlarePainter(glareAnimation: _glareController, borderRadius: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.goldLight,
                      AppColors.goldPrimary,
                      AppColors.goldMid,
                      AppColors.goldDark,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.goldLight.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withOpacity(0.5 + _pulseController.value * 0.3),
                      blurRadius: 25 + _pulseController.value * 15,
                      spreadRadius: 3 + _pulseController.value * 4,
                    ),
                    BoxShadow(
                      color: AppColors.goldLight.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, -2),
                    ),
                    BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'PLAY NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildScreenshotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'Screenshots',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),

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
                  border: Border.all(color: AppColors.goldPrimary.withOpacity(0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 15),
                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildScreenshotImage(_availableScreenshots[index]),
                      // Gold shimmer at top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.goldLight.withOpacity(0.5),
                                AppColors.goldPrimary,
                                AppColors.goldLight.withOpacity(0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (550 + index * 80).ms).slideX(begin: 0.1, delay: (550 + index * 80).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScreenshotImage(String screenshotUrl) {
    // Handle network images from database
    if (screenshotUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: screenshotUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.backgroundSecondary,
          child: Center(child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildScreenshotFallback(),
      );
    }
    // Handle local asset images
    return Image.asset(
      screenshotUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildScreenshotFallback(),
    );
  }

  Widget _buildScreenshotFallback() {
    // Fallback to game image if screenshot fails to load
    if (widget.game.image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: widget.game.image,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          color: AppColors.backgroundSecondary,
          child: const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.goldAccent)),
        ),
      );
    }
    return Image.asset(widget.game.image, fit: BoxFit.cover);
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: const Icon(Icons.info_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'About This Game',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.35), width: 1.5),
              boxShadow: [
                BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 20),
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gold shimmer at top
                Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.goldLight.withOpacity(0.5),
                        AppColors.goldPrimary,
                        AppColors.goldLight.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Text(
                  widget.game.description,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1, delay: 650.ms),
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
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'You Might Also Like',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms),

        const SizedBox(height: 16),

        SizedBox(
          height: 240,
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
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => GameDetailScreen(game: game),
                      transitionDuration: const Duration(milliseconds: 300),
                      reverseTransitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                          child: Container(color: Colors.black, child: child),
                        );
                      },
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
                            border: Border.all(color: AppColors.goldPrimary.withOpacity(0.35), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: AppColors.goldPrimary.withOpacity(0.15), blurRadius: 12),
                              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildSimilarGameImage(game),

                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                    ),
                                  ),
                                ),

                                // Gold shimmer at top
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.goldLight.withOpacity(0.5),
                                          AppColors.goldPrimary,
                                          AppColors.goldLight.withOpacity(0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.goldLight.withOpacity(0.25),
                                          AppColors.goldPrimary.withOpacity(0.15),
                                          AppColors.goldDark.withOpacity(0.25),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.goldPrimary.withOpacity(0.6), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.goldPrimary.withOpacity(0.35),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [AppColors.goldLight, AppColors.goldPrimary],
                                      ).createShader(bounds),
                                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
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
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [AppColors.goldLight, AppColors.goldPrimary],
                        ).createShader(bounds),
                        child: Text(
                          game.subtitle,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (750 + index * 80).ms).slideX(begin: 0.1, delay: (750 + index * 80).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarGameImage(Game game) {
    // Prefer animated logo (GIF) if available for similar games
    final imageUrl = game.animatedLogo != null && game.animatedLogo!.isNotEmpty
        ? game.animatedLogo!
        : game.image;

    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.backgroundSecondary,
          child: Center(child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: const Center(child: Icon(Icons.casino_rounded, size: 40, color: AppColors.goldAccent)),
        ),
      );
    }
    return Image.asset(imageUrl, fit: BoxFit.cover);
  }
}

class _ButtonGlarePainter extends CustomPainter {
  final AnimationController glareAnimation;
  final double borderRadius;

  _ButtonGlarePainter({required this.glareAnimation, required this.borderRadius}) : super(repaint: glareAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = glareAnimation.value;

    if (progress > 0.6) return; // 0.6 * 2.5s = 1.5s animation, 1s pause

    final adjustedProgress = progress / 0.6; // Normalize to 0-1

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final glareStart = Offset(
      -size.width * 0.3 + (size.width * 1.6 * adjustedProgress),
      -size.height * 0.3 + (size.height * 1.6 * adjustedProgress),
    );

    final glareEnd = Offset(glareStart.dx + size.width * 0.3, glareStart.dy + size.height * 0.3);

    final glareGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.6), Colors.white.withOpacity(0)],
      stops: const [0.0, 0.5, 1.0],
    );

    final glarePaint = Paint()
      ..shader = glareGradient.createShader(Rect.fromPoints(glareStart, glareEnd))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(rrect, glarePaint);
  }

  @override
  bool shouldRepaint(_ButtonGlarePainter oldDelegate) => true;
}
