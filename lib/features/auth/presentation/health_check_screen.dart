import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

/// Any response from the backend (even an error status) proves the app
/// reached the server; only a network-level failure means "offline".
final serverPingProvider = FutureProvider<bool>((ref) async {
  try {
    await ApiClient.instance.get('/api/health');
    return true;
  } on ApiException {
    return true;
  } catch (_) {
    return false;
  }
});

class HealthCheckScreen extends ConsumerWidget {
  const HealthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ping = ref.watch(serverPingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Penjualan')),
      body: Center(
        child: ping.when(
          data: (ok) => Text(
            ok ? 'Terhubung ke server ✔' : 'Gagal terhubung ke server',
            style: TextStyle(color: ok ? Colors.green : Colors.red),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
        ),
      ),
    );
  }
}
