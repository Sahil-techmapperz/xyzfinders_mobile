import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/constants/api_constants.dart';
import '../../core/config/api_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final ApiService _apiService = ApiService();

  void initSocket(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'token': token,
      },
    });

    _socket!.onConnect((_) {
      print('Socket connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onError((error) {
      print('Socket Error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void onMessageReceived(Function(dynamic) callback) {
    _socket?.on('receive_message', callback);
  }

  void offMessageReceived() {
    _socket?.off('receive_message');
  }

  IO.Socket? get socket => _socket;
}
