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
  late AnimationController _glareController;

  @override
  void initState() {
    super.initState();
    _loadSimilarGames();
    _loadAvailableScreenshots();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(
      period: const Duration(milliseconds: 2500), // 1.5s animation + 1s delay
    );
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
      backgroundColor: const Color(0xFF1A0F2E), // Solid dark purple background
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildPlayButton(),
                ),
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
        SizedBox(
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
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.8),
                const Color(0xFF1A0F2E),
              ],
              stops: const [0.0, 0.4, 0.75, 1.0],
            ),
          ),
        ),
        // Game title/subtitle left-aligned at bottom
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
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 10),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .slideX(begin: 0.1),
              const SizedBox(height: 6),
              Text(
                widget.game.subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 8),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideX(begin: 0.1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _playGame,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            decoration: BoxDecoration(
              // Golden gradient background for 3D effect
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.goldAccent,
                  AppColors.orange,
                  const Color(0xFFD4841C), // Darker gold for depth
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(30),
              // Stronger golden border with animated glare
              border: Border.all(
                color: AppColors.goldAccent.withOpacity(0.8),
                width: 2.5,
              ),
              boxShadow: [
                // Yellow/gold glow effect from behind
                BoxShadow(
                  color: AppColors.goldAccent.withOpacity(0.3 + _pulseController.value * 0.1),
                  blurRadius: 20 + _pulseController.value * 8,
                  spreadRadius: _pulseController.value * 1.5,
                  offset: const Offset(0, 0),
                ),
                // Additional yellow glow layer
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.2),
                  blurRadius: 25,
                  spreadRadius: 0,
                ),
                // Purple glow effect from behind
                BoxShadow(
                  color: AppColors.purplePrimary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
                // Top inner highlight for 3D effect
                BoxShadow(
                  color: AppColors.goldAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
                // Bottom shadow for 3D depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                // Subtle gold glow
                BoxShadow(
                  color: AppColors.goldAccent.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main content
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'PLAY NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Animated border glare effect
                AnimatedBuilder(
                  animation: _glareController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            width: 2.5,
                            color: Colors.transparent,
                          ),
                        ),
                        child: CustomPaint(
                          painter: BorderGlarePainter(
                            progress: _glareController.value,
                            glareColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
              const Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'Screenshots',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
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
              const Icon(
                Icons.info_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'About This Game',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
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
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'You Might Also Like',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 700.ms),
        
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

/// Custom painter for animated border glare effect
class BorderGlarePainter extends CustomPainter {
  final double progress;
  final Color glareColor;

  BorderGlarePainter({
    required this.progress,
    required this.glareColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(30));
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics().first;
    final totalLength = pathMetrics.length;
    
    // Glare length is 15% of total perimeter
    final glareLength = totalLength * 0.15;
    final glareStart = totalLength * progress;
    
    // Draw the glare segment with gradient effect
    for (double i = 0; i < glareLength; i += 1) {
      final currentPos = (glareStart + i) % totalLength;
      final tangent = pathMetrics.getTangentForOffset(currentPos);
      
      if (tangent != null) {
        // Calculate opacity based on position within glare
        final normalizedPos = i / glareLength;
        final opacity = (0.5 - (normalizedPos - 0.5).abs() * 2) * 0.8;
        
        paint.color = glareColor.withOpacity(opacity);
        canvas.drawCircle(tangent.position, 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BorderGlarePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
