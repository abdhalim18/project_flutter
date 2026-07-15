import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService([Connectivity? connectivity]) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isOnline);
  }

  Future<bool> checkIsOnline() async {
    return _isOnline(await _connectivity.checkConnectivity());
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
