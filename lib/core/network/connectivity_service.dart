import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@singleton
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
