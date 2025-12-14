import 'dart:ui';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GamesService _gamesService = GamesService();
  List<Game> _featuredGames = [];
  List<Game> _allGames = [];
  bool _isLoading = true;
  late AnimationController _pulseController;
  late AnimationController _glareController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _glareController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();

    _loadGames();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glareController.dispose();
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
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purplePrimary.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 15)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Image.asset(
                      'assets/images/herobg.png',
                      width: double.infinity,
                      height: 380,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                          colors: [Colors.transparent, Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.85)],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.purplePrimary.withOpacity(0.3), Colors.transparent],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(colors: [Colors.white, Color(0xFFE0E0E0)]).createShader(bounds),
                            child: Text(
                              'Premium Casino Games',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(color: AppColors.goldAccent.withOpacity(0.5), blurRadius: 20),
                                  Shadow(color: AppColors.purplePrimary.withOpacity(0.8), blurRadius: 30),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, delay: 300.ms),

                          const SizedBox(height: 8),

                          Text(
                            'No deposits. No purchases. Just play.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8)],
                            ),
                          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                          const SizedBox(height: 40), // Space for button overflow
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onNavigateToGames?.call();
              },
              child:
                  AnimatedBuilder(
                        animation: Listenable.merge([_pulseController, _glareController]),
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: CustomPaint(
                              painter: _ButtonGlarePainter(glareAnimation: _glareController, borderRadius: 30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [AppColors.goldAccent, AppColors.orange, const Color(0xFFD4841C)],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: AppColors.goldAccent.withOpacity(0.8), width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldAccent.withOpacity(0.5 + _pulseController.value * 0.3),
                                      blurRadius: 30 + _pulseController.value * 15,
                                      spreadRadius: 5 + _pulseController.value * 5,
                                    ),
                                    BoxShadow(
                                      color: AppColors.orange.withOpacity(0.4 + _pulseController.value * 0.2),
                                      blurRadius: 40 + _pulseController.value * 10,
                                      spreadRadius: 3 + _pulseController.value * 3,
                                    ),
                                    BoxShadow(
                                      color: AppColors.purplePrimary.withOpacity(0.3),
                                      blurRadius: 25,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: AppColors.goldAccent.withOpacity(0.6),
                                      blurRadius: 15,
                                      offset: const Offset(0, -2),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.6),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                                      ),
                                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      'BROWSE ALL GAMES',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
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
                              ),
                            ),
                          );
                        },
                      )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms)
                      .scale(begin: const Offset(0.9, 0.9), delay: 500.ms)
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: 2000.ms)
                      .scale(duration: 2000.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02)),
            ),
          ),
        ],
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
              const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Hot Games',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onNavigateToGames,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 16),

        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _featuredGames.length,
            itemBuilder: (context, index) {
              final game = _featuredGames[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _featuredGames.length - 1 ? 12 : 0),
                child: GestureDetector(
                  onTap: () => _navigateToGame(game),
                  child: SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child:
                              Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.purpleMuted.withOpacity(0.3), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(color: AppColors.purplePrimary.withOpacity(0.15), blurRadius: 12),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          game.image.startsWith('http')
                                              ? CachedNetworkImage(imageUrl: game.image, fit: BoxFit.cover)
                                              : Image.asset(game.image, fit: BoxFit.cover),

                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                                              ),
                                            ),
                                          ),

                                          Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
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
                                  )
                                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                                  .shimmer(
                                    duration: 2000.ms,
                                    delay: Duration(milliseconds: index * 200),
                                  )
                                  .scale(
                                    duration: 2000.ms,
                                    begin: const Offset(1.0, 1.0),
                                    end: const Offset(1.02, 1.02),
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
                        Text(
                          game.subtitle,
                          style: TextStyle(color: AppColors.purpleLight.withOpacity(0.6), fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
              const Icon(Icons.grid_view_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text(
                'More Games',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_allGames.length} games',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600),
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
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: otherGames.length,
          itemBuilder: (context, index) {
            final game = otherGames[index];
            return GestureDetector(
                  onTap: () => _navigateToGame(game),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.purpleMuted.withOpacity(0.25), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purplePrimary.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          game.image.startsWith('http')
                              ? CachedNetworkImage(imageUrl: game.image, fit: BoxFit.cover)
                              : Image.asset(game.image, fit: BoxFit.cover),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                              ),
                            ),
                          ),

                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    game.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
