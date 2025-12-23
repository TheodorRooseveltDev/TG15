import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/constants.dart';
import '../models/game.dart';
import '../services/games_service.dart';
import '../widgets/app_background.dart';
import 'game_detail_screen.dart';

class SlotScreen extends StatefulWidget {
  const SlotScreen({super.key});

  @override
  State<SlotScreen> createState() => _SlotScreenState();
}

class _SlotScreenState extends State<SlotScreen> with TickerProviderStateMixin {
  final GamesService _gamesService = GamesService();
  List<Game> _allGames = [];
  Game? _selectedGame;
  bool _isLoading = true;
  bool _isSpinning = false;
  bool _hasSpun = false;
  bool _showResult = false;

  // Animation controllers for smooth scrolling
  late AnimationController _reel1Controller;
  late AnimationController _reel2Controller;
  late AnimationController _reel3Controller;
  late AnimationController _glowController;
  late AnimationController _winCelebrationController;
  late AnimationController _winLineGlowController;

  // Scroll positions for each reel (in pixels)
  double _reel1Offset = 0;
  double _reel2Offset = 0;
  double _reel3Offset = 0;

  // Target positions for stopping
  int _targetIndex = 0;

  // Height of each game item in the reel
  static const double _itemHeight = 90.0;
  // Number of visible items per reel
  static const int _visibleItems = 3;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _loadGames();
  }

  // Track if we've already handled the spin completion
  bool _reel1Completed = false;
  bool _reel2Completed = false;
  bool _reel3Completed = false;

  void _initAnimationControllers() {
    _reel1Controller = AnimationController(vsync: this);
    _reel2Controller = AnimationController(vsync: this);
    _reel3Controller = AnimationController(vsync: this);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _winCelebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _winLineGlowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Set up status listeners once (not per spin)
    _reel1Controller.addStatusListener(_onReel1Complete);
    _reel2Controller.addStatusListener(_onReel2Complete);
    _reel3Controller.addStatusListener(_onReel3Complete);
  }

  void _onReel1Complete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_reel1Completed) {
      _reel1Completed = true;
      HapticFeedback.mediumImpact();
    }
  }

  void _onReel2Complete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_reel2Completed) {
      _reel2Completed = true;
      HapticFeedback.mediumImpact();
    }
  }

  void _onReel3Complete(AnimationStatus status) async {
    if (status == AnimationStatus.completed && !_reel3Completed) {
      _reel3Completed = true;
      HapticFeedback.heavyImpact();

      // Determine which game is on the win line based on final reel offset
      // The win line is at row index 1 (second row from top)
      final totalHeight = _allGames.length * _itemHeight;
      final normalizedOffset = _reel3Offset % totalHeight;
      // The reel renders with top: -normalizedOffset - _itemHeight
      // So at row 1 (win line), we need to find which game index is there
      final winLineGameIndex = ((normalizedOffset / _itemHeight).round() + 2) % _allGames.length;
      _selectedGame = _allGames[winLineGameIndex];

      setState(() {
        _isSpinning = false;
      });

      // Brief pause to let the reels settle visually
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      // Start win line glow animation (smooth fade in)
      _winLineGlowController.forward(from: 0);

      // Small haptic to signal win line appearing
      HapticFeedback.lightImpact();

      // Wait for glow to build up
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Start celebration pulse animation
      _winCelebrationController.forward(from: 0).then((_) {
        if (mounted) {
          _winCelebrationController.reverse();
        }
      });

      // Stronger haptic for the celebration moment
      HapticFeedback.mediumImpact();

      setState(() {
        _showResult = true;
      });

      // Wait a bit more before showing the bottom sheet
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted && _showResult) {
        HapticFeedback.heavyImpact();
        _showResultBottomSheet();
      }
    }
  }

  @override
  void dispose() {
    _reel1Controller.dispose();
    _reel2Controller.dispose();
    _reel3Controller.dispose();
    _glowController.dispose();
    _winCelebrationController.dispose();
    _winLineGlowController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    _allGames = await _gamesService.loadGames();

    if (_allGames.isNotEmpty) {
      // Initialize random positions
      final random = Random();
      _reel1Offset = random.nextDouble() * _allGames.length * _itemHeight;
      _reel2Offset = random.nextDouble() * _allGames.length * _itemHeight;
      _reel3Offset = random.nextDouble() * _allGames.length * _itemHeight;
    }

    setState(() => _isLoading = false);
  }

  void _spin() {
    if (_isSpinning || _allGames.isEmpty) return;

    HapticFeedback.heavyImpact();

    // Reset completion flags for new spin
    _reel1Completed = false;
    _reel2Completed = false;
    _reel3Completed = false;

    // Reset win animations
    _winLineGlowController.reset();
    _winCelebrationController.reset();

    setState(() {
      _isSpinning = true;
      _hasSpun = true;
      _showResult = false;
    });

    // Pick a random winning game index
    final random = Random();
    _targetIndex = random.nextInt(_allGames.length);

    // Calculate target offset
    // The win line is at row 1 (second row). The reel renders with top: -normalizedOffset - _itemHeight
    // So to have game at _targetIndex appear at row 1, we need offset = (_targetIndex - 1) * _itemHeight
    // But we need to handle wraparound properly
    final totalReelHeight = _allGames.length * _itemHeight;
    final targetOffset = ((_targetIndex - 1 + _allGames.length) % _allGames.length) * _itemHeight;

    // Reel 1: 3 full rotations + target
    final reel1Target = _reel1Offset + (totalReelHeight * 3) +
        ((targetOffset - (_reel1Offset % totalReelHeight) + totalReelHeight) % totalReelHeight);

    // Reel 2: 4 full rotations + target (stops later)
    final reel2Target = _reel2Offset + (totalReelHeight * 4) +
        ((targetOffset - (_reel2Offset % totalReelHeight) + totalReelHeight) % totalReelHeight);

    // Reel 3: 5 full rotations + target (stops last)
    final reel3Target = _reel3Offset + (totalReelHeight * 5) +
        ((targetOffset - (_reel3Offset % totalReelHeight) + totalReelHeight) % totalReelHeight);

    // Animate reel 1 - smoother, longer duration with custom curve
    _reel1Controller.duration = const Duration(milliseconds: 2500);
    final reel1Animation = Tween<double>(begin: _reel1Offset, end: reel1Target)
        .animate(CurvedAnimation(
          parent: _reel1Controller,
          curve: Curves.easeOutQuart, // Smoother deceleration
        ));

    reel1Animation.addListener(() {
      setState(() {
        _reel1Offset = reel1Animation.value;
      });
    });

    // Animate reel 2 (starts same time, takes longer)
    _reel2Controller.duration = const Duration(milliseconds: 3200);
    final reel2Animation = Tween<double>(begin: _reel2Offset, end: reel2Target)
        .animate(CurvedAnimation(
          parent: _reel2Controller,
          curve: Curves.easeOutQuart,
        ));

    reel2Animation.addListener(() {
      setState(() {
        _reel2Offset = reel2Animation.value;
      });
    });

    // Animate reel 3 (starts same time, takes longest for suspense)
    _reel3Controller.duration = const Duration(milliseconds: 4000);
    final reel3Animation = Tween<double>(begin: _reel3Offset, end: reel3Target)
        .animate(CurvedAnimation(
          parent: _reel3Controller,
          curve: Curves.easeOutQuart,
        ));

    reel3Animation.addListener(() {
      setState(() {
        _reel3Offset = reel3Animation.value;
      });
    });

    // Haptic feedback during spin - less frequent for smoother feel
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isSpinning) {
        timer.cancel();
        return;
      }
      HapticFeedback.selectionClick();
    });

    // Start all reels
    _reel1Controller.forward(from: 0);
    _reel2Controller.forward(from: 0);
    _reel3Controller.forward(from: 0);
  }

  void _showResultBottomSheet() {
    if (_selectedGame == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: AppColors.goldPrimary.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.goldPrimary.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Gold shimmer at top
            Container(
              margin: const EdgeInsets.only(top: 16),
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header badge - LIMITED TODAY GAME
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.goldLight,
                          AppColors.goldPrimary,
                          AppColors.goldDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.goldLight.withOpacity(0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'LIMITED GAME FOR TODAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Game image card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.goldPrimary.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldPrimary.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _selectedGame!.image.startsWith('http')
                                ? CachedNetworkImage(
                                    imageUrl: _selectedGame!.image,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(_selectedGame!.image, fit: BoxFit.cover),
                          ),

                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                    Colors.black.withOpacity(0.8),
                                  ],
                                  stops: const [0.3, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // Gold shimmer at top
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.goldLight.withOpacity(0.8),
                                    AppColors.goldPrimary,
                                    AppColors.goldLight.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Play button overlay
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(16),
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
                                    color: AppColors.goldPrimary.withOpacity(0.8),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldPrimary.withOpacity(0.5),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [AppColors.goldLight, AppColors.goldPrimary],
                                  ).createShader(bounds),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Game title only
                  Text(
                    _selectedGame!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Play button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToGame();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.goldLight.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                          SizedBox(width: 10),
                          Text(
                            'PLAY NOW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
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

                  // Bottom safe area padding
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame() {
    if (_selectedGame != null) {
      HapticFeedback.lightImpact();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => GameDetailScreen(game: _selectedGame!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          const AppBackground(),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSlotMachine(),
                        const SizedBox(height: 24),
                        _buildSpinButton(),
                        const SizedBox(height: 100),
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
          Text('Loading Slot Machine...', style: TextStyle(color: AppColors.purpleLight.withOpacity(0.7), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Decorative header
          Row(
            children: [
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
                  ).createShader(bounds),
                  child: Transform.rotate(
                    angle: 0.785398,
                    child: Container(width: 6, height: 6, color: Colors.white),
                  ),
                ),
              ),
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
                  'DAILY SPIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F)],
                  ).createShader(bounds),
                  child: Transform.rotate(
                    angle: 0.785398,
                    child: Container(width: 6, height: 6, color: Colors.white),
                  ),
                ),
              ),
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
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFF9C4),
                Color(0xFFFFE082),
                Color(0xFFFFD54F),
              ],
            ).createShader(bounds),
            child: const Text(
              'Lucky Slots',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spin to discover your game of the day',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildSlotMachine() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          // Main machine body
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2A1810),
                  const Color(0xFF1A0D08),
                  const Color(0xFF0D0604),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.goldPrimary.withOpacity(0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top gold bar with lights
                _buildTopBar(),
                const SizedBox(height: 12),

                // Reels container
                Container(
                  height: _itemHeight * _visibleItems,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.goldDark.withOpacity(0.8),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.9),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // The 3 reels
                        Row(
                          children: [
                            Expanded(child: _buildReel(_reel1Offset)),
                            _buildReelDivider(),
                            Expanded(child: _buildReel(_reel2Offset)),
                            _buildReelDivider(),
                            Expanded(child: _buildReel(_reel3Offset)),
                          ],
                        ),

                        // Win line indicator (center horizontal line)
                        Positioned(
                          top: _itemHeight - 2,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_winLineGlowController, _winCelebrationController]),
                            builder: (context, child) {
                              final glowValue = _winLineGlowController.value;
                              final celebrationValue = _winCelebrationController.value;
                              final pulseScale = 1.0 + (celebrationValue * 0.05);

                              return Transform.scale(
                                scale: _showResult ? pulseScale : 1.0,
                                child: Container(
                                  height: _itemHeight + 4,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _showResult
                                          ? AppColors.goldPrimary.withOpacity(0.4 + glowValue * 0.5)
                                          : AppColors.goldPrimary.withOpacity(0.3),
                                      width: _showResult ? 2 + glowValue : 2,
                                    ),
                                    boxShadow: _showResult ? [
                                      BoxShadow(
                                        color: AppColors.goldPrimary.withOpacity(0.3 + glowValue * 0.4),
                                        blurRadius: 10 + glowValue * 20,
                                        spreadRadius: glowValue * 5,
                                      ),
                                      BoxShadow(
                                        color: AppColors.goldLight.withOpacity(glowValue * 0.3),
                                        blurRadius: 25,
                                        spreadRadius: 2,
                                      ),
                                    ] : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Top shadow gradient
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom shadow gradient
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Left/Right edge shadows
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          width: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          width: 15,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                // Bottom gold bar
                _buildBottomBar(),
              ],
            ),
          ),

          // Corner decorations
          Positioned(
            top: 0,
            left: 0,
            child: _buildCornerLight(),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Transform.scale(scaleX: -1, child: _buildCornerLight()),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildTopBar() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldDark,
            AppColors.goldPrimary,
            AppColors.goldLight,
            AppColors.goldPrimary,
            AppColors.goldDark,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) => _buildLight(index)),
      ),
    );
  }

  Widget _buildLight(int index) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final isLit = _isSpinning
            ? (_glowController.value * 7).floor() % 7 == index
            : _showResult;
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLit ? Colors.red : Colors.red.withOpacity(0.3),
            boxShadow: isLit ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.8),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ] : null,
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldDark,
            AppColors.goldPrimary,
            AppColors.goldLight,
            AppColors.goldPrimary,
            AppColors.goldDark,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCornerLight() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.goldLight.withOpacity(0.8 + _glowController.value * 0.2),
                AppColors.goldPrimary.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withOpacity(0.5 + _glowController.value * 0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReelDivider() {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.goldDark.withOpacity(0.4),
            AppColors.goldPrimary.withOpacity(0.8),
            AppColors.goldDark.withOpacity(0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildReel(double offset) {
    if (_allGames.isEmpty) {
      return Container(color: Colors.black);
    }

    final totalHeight = _allGames.length * _itemHeight;
    // Normalize offset to prevent huge numbers
    final normalizedOffset = offset % totalHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Build multiple copies of the game strip for seamless looping
            Positioned(
              top: -normalizedOffset - _itemHeight,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Previous set of games (for seamless loop)
                  ..._allGames.map((game) => _buildReelItem(game)),
                  // Current set of games
                  ..._allGames.map((game) => _buildReelItem(game)),
                  // Next set of games (for seamless loop)
                  ..._allGames.map((game) => _buildReelItem(game)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReelItem(Game game) {
    return Container(
      height: _itemHeight,
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.goldPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Game image
              game.image.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: game.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.backgroundSecondary,
                        child: Center(
                          child: Icon(
                            Icons.casino_rounded,
                            color: AppColors.goldPrimary.withOpacity(0.5),
                            size: 30,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholderImage(),
                    )
                  : Image.asset(
                      game.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                    ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),

              // Game name at bottom
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    game.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundSecondary,
            AppColors.cardBackground,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.casino_rounded,
          color: AppColors.goldPrimary.withOpacity(0.5),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildSpinButton() {
    return GestureDetector(
      onTap: _isSpinning ? null : _spin,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isSpinning
                    ? [
                        AppColors.goldDark.withOpacity(0.5),
                        AppColors.goldDark.withOpacity(0.3),
                      ]
                    : [
                        AppColors.goldLight,
                        AppColors.goldPrimary,
                        AppColors.goldMid,
                        AppColors.goldDark,
                        AppColors.goldMid,
                        AppColors.goldPrimary,
                      ],
                stops: _isSpinning ? null : const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.goldLight.withOpacity(_isSpinning ? 0.2 : 0.6),
                width: 2,
              ),
              boxShadow: _isSpinning
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.5 + _glowController.value * 0.3),
                        blurRadius: 25 + _glowController.value * 15,
                        spreadRadius: 2 + _glowController.value * 3,
                      ),
                      BoxShadow(
                        color: AppColors.goldLight.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSpinning)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.goldPrimary.withOpacity(0.5),
                      strokeWidth: 2,
                    ),
                  )
                else
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFF9C4)],
                    ).createShader(bounds),
                    child: const Icon(Icons.casino_rounded, color: Colors.white, size: 28),
                  ),
                const SizedBox(width: 12),
                Text(
                  _isSpinning ? 'SPINNING...' : (_hasSpun ? 'SPIN AGAIN' : 'SPIN NOW'),
                  style: TextStyle(
                    color: _isSpinning ? AppColors.goldPrimary.withOpacity(0.5) : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    shadows: _isSpinning
                        ? null
                        : const [
                            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}
