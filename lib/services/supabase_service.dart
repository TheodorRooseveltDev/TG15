import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  late SupabaseClient _client;

  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  String get storageBucket => dotenv.env['SUPABASE_STORAGE_BUCKET'] ?? 'assets';

  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('SupabaseService not initialized. Call initialize() first.');
    }
    return _client;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Convert a relative storage path to a full public URL
  String getPublicUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }

    // If it's already a full URL, return as is
    if (relativePath.startsWith('http')) {
      return relativePath;
    }

    // Remove leading slash if present
    String path = relativePath;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    // Remove 'assets/' prefix if present since the bucket is already named 'assets'
    if (path.startsWith('assets/')) {
      path = path.substring(7); // Remove 'assets/'
    }

    // Get public URL from Supabase storage
    return _client.storage.from(storageBucket).getPublicUrl(path);
  }

  /// Fetch all games from the database
  Future<List<Map<String, dynamic>>> fetchGames() async {
    try {
      final response = await _client
          .from('games')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching games: $e');
      return [];
    }
  }

  /// Fetch a single game by ID
  Future<Map<String, dynamic>?> fetchGameById(String id) async {
    try {
      final response = await _client
          .from('games')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Error fetching game by ID: $e');
      return null;
    }
  }
}
