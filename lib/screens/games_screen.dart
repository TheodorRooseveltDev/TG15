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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Library',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_displayedGames.length} premium games available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, duration: 400.ms);
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary.withOpacity(0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.purpleMuted.withOpacity(0.3),
            width: 1.5,
          ),
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
                    color: isSelected 
                        ? AppColors.purplePrimary.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.purplePrimary.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : AppColors.purpleLight.withOpacity(0.5),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter['name'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.purpleLight.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )
          .animate()
          .fadeIn(delay: 200.ms),
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
              const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text(
                'All Games',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
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
            childAspectRatio: 0.7,
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
