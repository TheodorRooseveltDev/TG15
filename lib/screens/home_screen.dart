import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/constants.dart';
import '../models/game.dart';
import '../services/games_service.dart';
import '../widgets/app_background.dart';
import 'game_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGames;

  const HomeScreen({super.key, this.onNavigateToGames});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final GamesService _gamesService = GamesService();
  List<Game> _featuredGames = [];
  List<Game> _allGames = [];
  bool _isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _loadGames();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);

    _allGames = await _gamesService.loadGames();
    _featuredGames = _gamesService.featuredGames;

    if (_featuredGames.isEmpty && _allGames.isNotEmpty) {
      _featuredGames = _allGames.take(5).toList();
    }

    setState(() => _isLoading = false);
  }

  void _navigateToGame(Game game) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => GameDetailScreen(game: game)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AppBackground(),
          _isLoading
              ? SafeArea(child: _buildLoadingState())
              : RefreshIndicator(
                  onRefresh: _loadGames,
                  color: AppColors.goldAccent,
                  backgroundColor: AppColors.cardBackground,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tagline above hero - premium style with decorative lines
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                          child: Row(
                            children: [
                              // Left decorative line
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        const Color(0xFFFFD54F).withOpacity(0.3),
                                        const Color(0xFFFFD54F),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Left diamond
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
                                  ).createShader(bounds),
                                  child: Transform.rotate(
                                    angle: 0.785398, // 45 degrees
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Main text
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF9C4),
                                    Color(0xFFFFE082),
                                    Color(0xFFFFD54F),
                                    Color(0xFFFFE082),
                                    Color(0xFFFFF9C4),
                                  ],
                                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                                ).createShader(bounds),
                                child: const Text(
                                  'FEEL THE THRILL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                              // Right diamond
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
                                  ).createShader(bounds),
                                  child: Transform.rotate(
                                    angle: 0.785398,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Right decorative line
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFFD54F),
                                        const Color(0xFFFFD54F).withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
                        _buildHeroSection(),
                        const SizedBox(height: 48),
                        _buildHotGamesCarousel(),
                        const SizedBox(height: 48),
                        _buildAllGamesGrid(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(color: AppColors.goldAccent, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text('Loading Games...', style: TextStyle(color: AppColors.purpleLight.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              'assets/images/herobg.png',
              fit: BoxFit.cover,
            ),

            // Dark gradient overlay - stronger at bottom
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title - WHITE text
                  const Text(
                    'Premium\nCasino Games',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'No deposits. No purchases. Just play.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 20),

                  // Play Now Button - more gold glow
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onNavigateToGames?.call();
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.goldLight,
                                AppColors.goldPrimary,
                                AppColors.goldMid,
                                AppColors.goldDark,
                                AppColors.goldMid,
                                AppColors.goldPrimary,
                              ],
                              stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.goldLight.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldPrimary.withOpacity(0.7 + _pulseController.value * 0.3),
                                blurRadius: 30 + _pulseController.value * 20,
                                spreadRadius: 3 + _pulseController.value * 3,
                              ),
                              BoxShadow(
                                color: AppColors.goldLight.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'PLAY NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotGamesCarousel() {
    if (_featuredGames.isEmpty) return const SizedBox.shrink();

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
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'Top Picks',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onNavigateToGames,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldPrimary.withOpacity(0.15),
                        AppColors.goldDark.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [AppColors.goldLight, AppColors.goldPrimary],
                        ).createShader(bounds),
                        child: const Text(
                          'View All',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [AppColors.goldLight, AppColors.goldPrimary],
                        ).createShader(bounds),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 16),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _featuredGames.length,
            itemBuilder: (context, index) {
              final game = _featuredGames[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _featuredGames.length - 1 ? 16 : 0),
                child: GestureDetector(
                  onTap: () => _navigateToGame(game),
                  child: SizedBox(
                    width: 160,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 1.5,
                          color: AppColors.goldPrimary.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withOpacity(0.25),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Game Image
                            game.image.startsWith('http')
                                ? CachedNetworkImage(imageUrl: game.image, fit: BoxFit.cover)
                                : Image.asset(game.image, fit: BoxFit.cover),

                            // Premium gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.9),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),

                            // Gold shimmer edge at top
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
                                      AppColors.goldLight.withOpacity(0.6),
                                      AppColors.goldPrimary,
                                      AppColors.goldLight.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Ranking number - large stylized number
                            Positioned(
                              top: 8,
                              left: 8,
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFF9C4), // Very bright gold/yellow
                                    Color(0xFFFFD54F), // Bright gold
                                    Color(0xFFFFCA28), // Medium bright gold
                                    Color(0xFFD4AF37), // Classic gold
                                  ],
                                  stops: [0.0, 0.3, 0.6, 1.0],
                                ).createShader(bounds),
                                child: Text(
                                  '#${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    height: 1,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black87,
                                        blurRadius: 4,
                                        offset: Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Play button overlay
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.goldLight.withOpacity(0.3),
                                      AppColors.goldPrimary.withOpacity(0.2),
                                      AppColors.goldDark.withOpacity(0.3),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.goldPrimary.withOpacity(0.7),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldPrimary.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [AppColors.goldLight, AppColors.goldPrimary],
                                  ).createShader(bounds),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                                ),
                              ),
                            ),

                            // Bottom content
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        shadows: [
                                          Shadow(color: Colors.black, blurRadius: 4),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: [AppColors.goldLight, AppColors.goldPrimary],
                                      ).createShader(bounds),
                                      child: Text(
                                        game.subtitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (600 + index * 80).ms).slideX(begin: 0.2, delay: (600 + index * 80).ms),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllGamesGrid() {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final featuredIds = _featuredGames.map((g) => g.id).toSet();
    final otherGames = _allGames.where((g) => !featuredIds.contains(g.id)).take(6).toList();

    if (otherGames.isEmpty) return const SizedBox.shrink();

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
                child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'More Games',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2), width: 1),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.goldLight, AppColors.goldPrimary],
                  ).createShader(bounds),
                  child: Text(
                    '${_allGames.length} games',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: otherGames.length,
          itemBuilder: (context, index) {
            final game = otherGames[index];
            return GestureDetector(
                  onTap: () => _navigateToGame(game),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.goldPrimary.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Game image
                          game.image.startsWith('http')
                              ? CachedNetworkImage(imageUrl: game.image, fit: BoxFit.cover)
                              : Image.asset(game.image, fit: BoxFit.cover),

                          // Premium gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.85),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),

                          // Gold shimmer edge at top
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

                          // Corner gold accent
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    AppColors.goldPrimary.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Play button
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
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
                                border: Border.all(
                                  color: AppColors.goldPrimary.withOpacity(0.6),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withOpacity(0.35),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                                ).createShader(bounds),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                              ),
                            ),
                          ),

                          // Bottom content with glass effect
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(14),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      shadows: [
                                        Shadow(color: Colors.black, blurRadius: 6),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [AppColors.goldLight, AppColors.goldPrimary],
                                    ).createShader(bounds),
                                    child: Text(
                                      game.subtitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: (800 + index * 80).ms)
                .scale(begin: const Offset(0.95, 0.95), delay: (800 + index * 80).ms);
          },
        ),
      ],
    );
  }
}
