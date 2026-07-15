import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class AppSupabase {
  AppSupabase._();

  static Future<void> initialize() {
    return Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
