import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/constants.dart';
import '../models/game.dart';
import 'animated_svg_logo.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;
  final bool featured;

  const GameCard({super.key, required this.game, required this.onTap, this.featured = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.purpleMuted.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(color: AppColors.purplePrimary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildGameImage(),

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
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              if (game.isNew)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.success, AppColors.success.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

              if (featured || game.isFeatured)
                Positioned(
                  top: 10,
                  left: game.isNew ? null : 10,
                  right: game.isNew ? 10 : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.goldAccent, AppColors.orange]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'HOT',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameImage() {
    // Prefer animated logo (GIF) if available
    if (game.animatedLogo != null && game.animatedLogo!.isNotEmpty) {
      final animatedUrl = game.animatedLogo!;
      if (animatedUrl.startsWith('http')) {
        // Network GIF
        return CachedNetworkImage(
          imageUrl: animatedUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildImagePlaceholder(),
          errorWidget: (context, url, error) => _buildStaticImage(),
        );
      } else if (animatedUrl.endsWith('.svg')) {
        // Local SVG
        return AnimatedSvgLogo(assetPath: animatedUrl, fit: BoxFit.cover, backgroundColor: Colors.black);
      } else {
        // Local GIF/asset
        return Image.asset(
          animatedUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildStaticImage(),
        );
      }
    }

    // Fallback to static image
    return _buildStaticImage();
  }

  Widget _buildStaticImage() {
    if (game.image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: game.image,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildImagePlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    } else {
      return Image.asset(
        game.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.backgroundSecondary,
      child: Center(child: CircularProgressIndicator(color: AppColors.purplePrimary, strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Center(child: Icon(Icons.casino_rounded, size: 60, color: AppColors.goldAccent)),
    );
  }
}
