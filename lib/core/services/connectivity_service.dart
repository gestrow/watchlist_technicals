import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status.
class ConnectivityService {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Stream of connectivity status changes.
  Stream<bool> get connectivityStream => _controller.stream;

  /// Current connectivity status.
  bool get isOnline => _isOnline;

  /// Initialize the connectivity service and start listening.
  Future<void> init() async {
    // Check initial status
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) => r != ConnectivityResult.none);

    if (wasOnline != _isOnline) {
      _controller.add(_isOnline);
    }
  }

  /// Check connectivity status on demand.
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return _isOnline;
  }

  /// Dispose resources.
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
