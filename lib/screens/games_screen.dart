import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/constants.dart';
import '../models/game.dart';
import '../services/games_service.dart';
import '../widgets/app_background.dart';
import 'game_detail_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final GamesService _gamesService = GamesService();
  final TextEditingController _searchController = TextEditingController();
  List<Game> _displayedGames = [];
  String _selectedFilter = 'Featured';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _filters = [
    {'name': 'Featured', 'icon': Icons.star_rounded},
    {'name': 'Popular', 'icon': Icons.local_fire_department_rounded},
    {'name': 'New', 'icon': Icons.new_releases_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);

    await _gamesService.loadGames();
    _applyFiltersAndSort();

    setState(() => _isLoading = false);
  }

  void _applyFiltersAndSort() {
    List<Game> games;

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      games = _gamesService.searchGames(query);
    } else {
      games = _gamesService.filterByCategory(_selectedFilter);
    }

    games = _gamesService.sortGames(games, 'Default');

    setState(() {
      _displayedGames = games;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _applyFiltersAndSort();
  }

  void _selectFilter(String filter) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedFilter = filter;
      _searchController.clear();
    });
    _applyFiltersAndSort();
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
                        _buildHeroHeader(),
                        const SizedBox(height: 24),
                        _buildFilterChips(),
                        const SizedBox(height: 24),
                        _buildGamesSection(),
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

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with gold gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color(0xFFFFF9C4),
                const Color(0xFFFFE082),
                const Color(0xFFFFD54F),
                const Color(0xFFFFE082),
                const Color(0xFFFFF9C4),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ).createShader(bounds),
            child: const Text(
              'Game Library',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: Text(
                  '${_displayedGames.length} premium games available',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, duration: 400.ms);
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: _filters.asMap().entries.map((entry) {
            final filter = entry.value;
            final isSelected = filter['name'] == _selectedFilter;

            return Expanded(
              child: GestureDetector(
                onTap: () => _selectFilter(filter['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(
                      colors: [
                        AppColors.goldDark.withOpacity(0.4),
                        AppColors.goldPrimary.withOpacity(0.2),
                        AppColors.goldDark.withOpacity(0.4),
                      ],
                    ) : null,
                    borderRadius: BorderRadius.circular(26),
                    border: isSelected ? Border.all(
                      color: AppColors.goldPrimary.withOpacity(0.5),
                      width: 1,
                    ) : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.goldPrimary.withOpacity(0.3), blurRadius: 15, spreadRadius: 0)]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: isSelected
                            ? (bounds) => LinearGradient(
                                colors: [AppColors.goldLight, AppColors.goldPrimary],
                              ).createShader(bounds)
                            : (bounds) => LinearGradient(
                                colors: [AppColors.secondaryText, AppColors.secondaryText],
                              ).createShader(bounds),
                        child: Icon(
                          filter['icon'] as IconData,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: isSelected
                            ? (bounds) => LinearGradient(
                                colors: [AppColors.goldLight, AppColors.goldPrimary],
                              ).createShader(bounds)
                            : (bounds) => LinearGradient(
                                colors: [AppColors.secondaryText, AppColors.secondaryText],
                              ).createShader(bounds),
                        child: Text(
                          filter['name'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ).animate().fadeIn(delay: 200.ms),
    );
  }

  Widget _buildGamesSection() {
    if (_displayedGames.isEmpty) {
      return _buildEmptyState();
    }

    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

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
                  'All Games',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3), width: 1),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.goldLight, AppColors.goldPrimary],
                  ).createShader(bounds),
                  child: Text(
                    '${_displayedGames.length} games',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),

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
          itemCount: _displayedGames.length,
          itemBuilder: (context, index) {
            final game = _displayedGames[index];
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
            .fadeIn(delay: (500 + index * 50).ms)
            .scale(begin: const Offset(0.95, 0.95), delay: (500 + index * 50).ms);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundSecondary.withOpacity(0.8), AppColors.cardBackground.withOpacity(0.6)],
        ),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3), width: 1),
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldPrimary],
              ).createShader(bounds),
              child: const Icon(Icons.search_off_rounded, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: const Text(
              'No games found',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              _clearSearch();
              _selectFilter('Featured');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldLight,
                    AppColors.goldPrimary,
                    AppColors.goldMid,
                    AppColors.goldDark,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.goldLight.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(color: AppColors.goldPrimary.withOpacity(0.4), blurRadius: 15),
                ],
              ),
              child: const Text(
                'Reset Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
