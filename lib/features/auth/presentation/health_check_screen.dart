import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';

/// Any response from Supabase (including "table not found") proves the
/// client reached the server; only a network-level failure means "offline".
final supabasePingProvider = FutureProvider<bool>((ref) async {
  try {
    await AppSupabase.client.from('_health_check_ping').select().limit(1);
    return true;
  } on PostgrestException {
    return true;
  } catch (_) {
    return false;
  }
});

class HealthCheckScreen extends ConsumerWidget {
  const HealthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ping = ref.watch(supabasePingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Penjualan')),
      body: Center(
        child: ping.when(
          data: (ok) => Text(
            ok ? 'Terhubung ke Supabase ✔' : 'Gagal terhubung ke Supabase',
            style: TextStyle(color: ok ? Colors.green : Colors.red),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
        ),
      ),
    );
  }
}
