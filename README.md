# VIP Gaming Lounge 🎰

A premium iOS social casino app offering hundreds of free slot games for entertainment.

## 📱 App Overview

**VIP Gaming Lounge** is a premium social casino application built with Flutter for iOS. The app provides a luxurious gaming experience with hundreds of authentic slot games, all completely free to play.

### Key Features

- ✅ **100% Free** - No purchases required, play forever
- ✅ **No Registration** - Start playing immediately  
- ✅ **14+ Games** (expandable) - Growing library of slot games
- ✅ **Premium Design** - Luxurious teal & gold theme
- ✅ **Game Details** - Comprehensive info before playing (CRITICAL REQUIREMENT)
- ✅ **Age Verified** - 18+ age gate on first launch
- ✅ **Favorites & History** - Track your preferred games
- ✅ **Legal Compliance** - Full Terms, Privacy & Responsible Gaming pages

## 🎯 CRITICAL REQUIREMENT

⚠️ **GAME DETAIL SCREEN IS MANDATORY** ⚠️

Every game MUST show a comprehensive detail screen before playing that includes:
- Hero banner with game artwork
- Rating, players count, and provider info
- Large "PLAY NOW" button
- Screenshot gallery (5 images)
- Game statistics (RTP, volatility, paylines, bet limits)
- Full description (2-3 paragraphs)
- Features list (Free Spins, Wilds, Bonuses, etc.)
- Similar games section (6 recommendations)

**Users can NEVER play a game directly without viewing this screen first.**

## 🚀 Getting Started

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

3. Build for release:
```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── constants/          # Design system
├── models/            # Data models (Game)
├── services/          # Business logic (GamesService, SettingsService)
├── screens/           # All app screens
├── widgets/           # Reusable components
└── main.dart         # Entry point

assets/
├── images/           # App images and game thumbnails
└── games-data.json   # Games database
```

## 🎨 Design System

### Colors
- Teal Primary: #00CED1
- Gold Accent: #FFD700
- Deep Space: #0A0E27
- Card Dark: #0F172A

### Typography
- SF Pro Display (iOS Native)
- H1-H5 headings, body text, captions

### Spacing
- 4px base unit grid system
- 16px container padding

## 🎮 Main Screens

1. **Splash Screen** - Animated loading with logo
2. **Age Gate** - One-time 18+ verification
3. **Home Screen** - Featured games, categories, stats
4. **Games Library** - Search, filter, sort, grid view
5. **Game Detail** - ⚠️ MANDATORY comprehensive game info
6. **Game Play** - Fullscreen WebView with controls
7. **Profile** - User stats, favorites, settings, legal links

## 📊 Performance

- Splash to home: <4 seconds
- 60fps scrolling
- <200MB memory usage
- <100MB app size

## 🚨 App Store Ready

### Included
- Complete legal pages (Terms, Privacy, Responsible Gaming)
- Age gate (18+)
- No real money gambling
- Entertainment only disclaimers
- Proper iOS permissions
- App icons support (add your icons)

### Required for Submission
- App icons (1024x1024 and all sizes)
- Screenshots (6.5", 5.5", 12.9")
- App Store description
- Privacy Policy URL (host legal pages)
- Terms URL (host legal pages)

## 📝 Technical Details

**Framework**: Flutter (Dart)  
**Minimum iOS**: 14.0  
**Orientation**: Portrait + Landscape (games)  
**Permissions**: Internet access only

### Key Packages
- webview_flutter (game iframes)
- cached_network_image (image caching)
- shared_preferences (local storage)
- carousel_slider (featured games)
- flutter_animate (animations)

## 🎯 Success Criteria

✅ Professional premium design  
✅ Smooth 60fps performance  
✅ Comprehensive game details before play  
✅ Complete legal compliance  
✅ Age verification  
✅ No crashes or errors  
✅ Responsive on all iOS devices  

## 📄 License

Proprietary - All rights reserved

---

**Built with Flutter for iOS**

Last Updated: November 24, 2025
