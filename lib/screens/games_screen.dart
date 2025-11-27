import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/constants.dart';
import '../models/game.dart';
import '../services/games_service.dart';
import '../widgets/game_card.dart';
import '../widgets/app_background.dart';
import 'game_detail_screen.dart';

/// Games library screen with search and filters
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
    {'name': 'Featured', 'icon': Icons.star_rounded, 'color': AppColors.goldAccent},
    {'name': 'Popular', 'icon': Icons.local_fire_department_rounded, 'color': AppColors.orange},
    {'name': 'New', 'icon': Icons.new_releases_rounded, 'color': AppColors.success},
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
    
    // Apply search
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      games = _gamesService.searchGames(query);
    } else {
      // Apply filter
      games = _gamesService.filterByCategory(_selectedFilter);
    }
    
    // Apply default sort
    games = _gamesService.sortGames(games, 'Default');
    
    setState(() {
      _displayedGames = games;
    });
  }

  void _onSearchChanged(String query) {
    _applyFiltersAndSort();
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(game: game),
      ),
    );
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
                        _buildSearchSection(),
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
            child: const CircularProgressIndicator(
              color: AppColors.goldAccent,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Games...',
            style: TextStyle(
              color: AppColors.purpleLight.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purpleDark.withOpacity(0.8),
              AppColors.backgroundSecondary.withOpacity(0.9),
            ],
          ),
          border: Border.all(
            color: AppColors.purpleMuted.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purplePrimary.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purplePrimary, AppColors.purpleSecondary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purplePrimary.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.games_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFE0E0E0)],
                    ).createShader(bounds),
                    child: const Text(
                      'Game Library',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_displayedGames.length} premium games available',
                    style: TextStyle(
                      color: AppColors.purpleLight.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, duration: 400.ms);
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.purpleMuted.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purplePrimary.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search games...',
            hintStyle: TextStyle(
              color: AppColors.purpleLight.withOpacity(0.5),
              fontSize: 16,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.purplePrimary,
                size: 24,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: _clearSearch,
                    color: AppColors.purpleLight,
                  )
                : null,
            filled: true,
            fillColor: AppColors.backgroundSecondary.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.purplePrimary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter['name'] == _selectedFilter;
          
          return Padding(
            padding: EdgeInsets.only(right: index < _filters.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () => _selectFilter(filter['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            (filter['color'] as Color).withOpacity(0.3),
                            (filter['color'] as Color).withOpacity(0.1),
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.backgroundSecondary.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? (filter['color'] as Color).withOpacity(0.6)
                        : AppColors.purpleMuted.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (filter['color'] as Color).withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      color: isSelected
                          ? filter['color'] as Color
                          : AppColors.purpleLight.withOpacity(0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter['name'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.purpleLight.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (200 + index * 80).ms)
              .slideX(begin: 0.2, delay: (200 + index * 80).ms);
        },
      ),
    );
  }

  Widget _buildGamesSection() {
    if (_displayedGames.isEmpty) {
      return _buildEmptyState();
    }

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
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'All Games',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.purpleMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_displayedGames.length} games',
                  style: TextStyle(
                    color: AppColors.purpleLight.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.shortestSide >= 600 ? 3 : 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _displayedGames.length,
          itemBuilder: (context, index) {
            final game = _displayedGames[index];
            return GameCard(
              game: game,
              onTap: () => _navigateToGame(game),
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
          colors: [
            AppColors.backgroundSecondary.withOpacity(0.8),
            AppColors.cardBackground.withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: AppColors.purpleMuted.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.purpleMuted.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 60,
              color: AppColors.purpleLight.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No games found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: AppColors.purpleLight.withOpacity(0.7),
              fontSize: 14,
            ),
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
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purplePrimary.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Text(
                'Reset Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms)
        .scale(begin: const Offset(0.95, 0.95));
  }
}
