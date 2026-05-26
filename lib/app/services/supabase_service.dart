

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  Future<SupabaseService> init ()async{
    await dotenv.load();
    final String Supabase_url = dotenv.env["SUPABSE_URL"]?? "URL NOT FOUND";
    final String Supabase_key = dotenv.env["SUPABASE_KEY"]?? "KEY NOT FOUND";
    await Supabase.initialize(
        url: Supabase_url,
        anonKey: Supabase_key);
    return this;
}
}