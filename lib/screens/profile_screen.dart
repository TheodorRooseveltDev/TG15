import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../services/settings_service.dart';
import '../widgets/app_background.dart';
import 'age_gate_screen.dart';
import 'legal_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SettingsService _settingsService = SettingsService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _hapticFeedback = true;
  bool _notifications = true;

  final TextEditingController _supportDescriptionController = TextEditingController();
  String _selectedTopic = 'Technical Issue';
  File? _supportImage;
  bool _isSending = false;

  final List<String> _supportTopics = [
    'Technical Issue',
    'Account Question',
    'Game Problem',
    'Payment Issue',
    'Feature Request',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _supportDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final hapticFeedback = await _settingsService.getHapticFeedback();
    final notifications = await _settingsService.getNotifications();

    setState(() {
      _hapticFeedback = hapticFeedback;
      _notifications = notifications;
    });
  }

  Future<void> _toggleHapticFeedback(bool value) async {
    HapticFeedback.lightImpact();
    await _settingsService.setHapticFeedback(value);
    setState(() => _hapticFeedback = value);
  }

  Future<void> _toggleNotifications(bool value) async {
    HapticFeedback.lightImpact();
    await _settingsService.setNotifications(value);
    setState(() => _notifications = value);
  }

  void _openSupportModal() {
    HapticFeedback.lightImpact();
    showDialog(context: context, builder: (context) => _buildSupportModal());
  }

  Future<void> _pickImageForSupport(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (image != null) {
      setState(() => _supportImage = File(image.path));
      Navigator.pop(context);
    }
  }

  Future<void> _sendSupportMessage() async {
    if (_supportDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a description'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _supportDescriptionController.clear();
      _supportImage = null;
      _selectedTopic = 'Technical Issue';
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Support request sent successfully!')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _deleteEverything() async {
    HapticFeedback.heavyImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.deleteRed, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.deleteRed.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.warning_rounded, color: AppColors.deleteRed, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Delete Everything?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action will permanently delete:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildDeleteItem('All your favorites'),
            _buildDeleteItem('Recently played games'),
            _buildDeleteItem('All settings and preferences'),
            _buildDeleteItem('Your profile name and avatar'),
            _buildDeleteItem('App cache and data'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deleteRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.deleteRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.deleteRed, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(color: AppColors.deleteRed, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(backgroundColor: AppColors.deleteRed.withOpacity(0.2)),
            child: const Text(
              'Delete Everything',
              style: TextStyle(color: AppColors.deleteRed, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.clearAllCache();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AgeGateScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
            );
          },
        ),
        (route) => false,
      );
    }
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.close_rounded, color: AppColors.deleteRed, size: 16),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }

  void _navigateToLegal(String type) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LegalScreen(type: type)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      extendBody: true,
      body: Stack(
        children: [
          const AppBackground(),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(),
                const SizedBox(height: 32),
                _buildSettingsSection(),
                const SizedBox(height: 32),
                _buildLegalSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
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
              'Settings',
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
                child: const Text(
                  'Manage your preferences',
                  style: TextStyle(
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

  Widget _buildSupportModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.goldDark.withOpacity(0.2),
                            AppColors.cardBackground,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary.withOpacity(0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [AppColors.goldLight, AppColors.goldPrimary],
                            ).createShader(bounds),
                            child: const Text(
                              'Contact Support',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Topic',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedTopic,
                                  isExpanded: true,
                                  dropdownColor: AppColors.cardBackground,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  icon: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [AppColors.goldLight, AppColors.goldPrimary],
                                    ).createShader(bounds),
                                    child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  ),
                                  items: _supportTopics.map((String topic) {
                                    return DropdownMenuItem<String>(value: topic, child: Text(topic));
                                  }).toList(),
                                  onChanged: _isSending
                                      ? null
                                      : (String? newValue) {
                                          if (newValue != null) {
                                            setModalState(() {
                                              setState(() {
                                                _selectedTopic = newValue;
                                              });
                                            });
                                          }
                                        },
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              'Description',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _supportDescriptionController,
                              maxLines: 5,
                              enabled: !_isSending,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Describe your issue in detail...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                                filled: true,
                                fillColor: AppColors.backgroundSecondary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppColors.goldPrimary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              'Attachment (Optional)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 8),

                            if (_supportImage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(_supportImage!, width: 50, height: 50, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Image attached',
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      color: AppColors.error,
                                      iconSize: 20,
                                      onPressed: _isSending
                                          ? null
                                          : () {
                                              setModalState(() {
                                                setState(() {
                                                  _supportImage = null;
                                                });
                                              });
                                            },
                                    ),
                                  ],
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: _isSending ? null : () => _showImageSourcePicker(setModalState),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [AppColors.goldLight, AppColors.goldPrimary],
                                        ).createShader(bounds),
                                        child: const Icon(Icons.attach_file_rounded, color: Colors.white, size: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: [AppColors.goldLight, AppColors.goldPrimary],
                                        ).createShader(bounds),
                                        child: const Text(
                                          'Add Image',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

                    // Footer buttons
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary.withOpacity(0.5),
                        border: Border(top: BorderSide(color: AppColors.goldPrimary.withOpacity(0.2))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _isSending
                                  ? null
                                  : () {
                                      _supportDescriptionController.clear();
                                      _supportImage = null;
                                      _selectedTopic = 'Technical Issue';
                                      Navigator.pop(context);
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isSending ? null : _sendSupportMessage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldPrimary.withOpacity(0.4),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _isSending
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Send',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                ),
                              ),
                            ),
                          ),
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
    );
  }

  void _showImageSourcePicker(StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldPrimary],
              ).createShader(bounds),
              child: const Text(
                'Add Image',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(Icons.camera_alt_rounded, 'Camera', () async {
                  await _pickImageForSupport(ImageSource.camera);
                  setModalState(() {});
                }),
                _buildImagePickerOption(Icons.photo_library_rounded, 'Gallery', () async {
                  await _pickImageForSupport(ImageSource.gallery);
                  setModalState(() {});
                }),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.goldPrimary.withOpacity(0.4), blurRadius: 15),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
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
                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'Preferences',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
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
              children: [
                // Gold shimmer at top
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                _buildSettingTile(
                  icon: Icons.vibration_rounded,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibration on interactions',
                  value: _hapticFeedback,
                  onChanged: _toggleHapticFeedback,
                ),
                _buildDivider(),
                _buildSettingTile(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  subtitle: 'New games and updates',
                  value: _notifications,
                  onChanged: _toggleNotifications,
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Delete Everything',
                  subtitle: 'Reset app to initial state',
                  onTap: _deleteEverything,
                  isDanger: true,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, delay: 300.ms),
      ],
    );
  }

  Widget _buildLegalSection() {
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
                child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.goldLight, AppColors.goldPrimary, AppColors.goldLight],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'About & Legal',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
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
              children: [
                // Gold shimmer at top
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                _buildActionTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Need Help?',
                  subtitle: 'Contact our support team',
                  onTap: _openSupportModal,
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.info_rounded,
                  title: 'App Version',
                  value: '1.0.0',
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.description_rounded,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms',
                  onTap: () => _navigateToLegal('terms'),
                ),
                _buildDivider(),
                _buildActionTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  subtitle: 'Your privacy matters',
                  onTap: () => _navigateToLegal('privacy'),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, delay: 600.ms),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, thickness: 1, color: AppColors.goldPrimary.withOpacity(0.15)),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.goldLight, AppColors.goldPrimary],
            ).createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.goldPrimary,
            activeTrackColor: AppColors.goldPrimary.withOpacity(0.4),
            inactiveThumbColor: Colors.white.withOpacity(0.8),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.goldPrimary.withOpacity(0.3);
              }
              return Colors.white.withOpacity(0.1);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              isDanger
                  ? Icon(icon, color: AppColors.deleteRed, size: 22)
                  : ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.goldLight, AppColors.goldPrimary],
                      ).createShader(bounds),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDanger ? AppColors.deleteRed : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isDanger
                      ? [AppColors.deleteRed, AppColors.deleteRed]
                      : [AppColors.goldLight, AppColors.goldPrimary],
                ).createShader(bounds),
                child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.goldLight, AppColors.goldPrimary],
            ).createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldDark.withOpacity(0.3),
                  AppColors.goldPrimary.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4), width: 1),
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.goldLight, AppColors.goldPrimary],
              ).createShader(bounds),
              child: Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
