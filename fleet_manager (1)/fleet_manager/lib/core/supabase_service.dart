import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://hukrujiolcpzhvryxidr.supabase.co',
      anonKey: 'sb_publishable_1-BpPiLbutzR9WqEPo2R0A_O_rCH1Kq',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}