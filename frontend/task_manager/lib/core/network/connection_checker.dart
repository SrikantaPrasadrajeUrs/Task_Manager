import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectionChecker{
  Future<bool> get isConnected;
}

class ConnectionCheckImpl extends ConnectionChecker{

  @override
  Future<bool> get isConnected async =>await checkConnection();

  Future<bool> checkConnection()async{
    final result = await (Connectivity().checkConnectivity());
    if(result.isEmpty) return false;
    if(result.contains(ConnectivityResult.wifi)||result.contains(ConnectivityResult.mobile)) return true;
    return false;
  }
}