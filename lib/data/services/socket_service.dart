import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  // Saved IDs so we can re-join rooms after reconnect
  String? _userId;
  String? _agencyId;

  bool get isConnected => _socket?.connected == true;

  void initSocket(String token) {
    // If the socket already exists and is connected, just make sure listeners
    // are fresh — do NOT return early (we still need to re-register handlers).
    if (_socket != null && _socket!.connected) {
      // Re-join rooms in case the app was backgrounded and rooms were lost
      _rejoinRooms();
      return;
    }

    // Disconnect any stale socket before creating a new one
    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.dispose();
      _socket = null;
    }

    _socket = IO.io(ApiConstants.socketUrl, 
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(10)
          .setAuth({'token': token})
          .build()
    );

    _socket!.onConnect((_) {
      print('[Socket] ✅ Connected to: ${ApiConstants.socketUrl} | ID: ${_socket!.id}');
      // Always re-join rooms on (re)connect
      _rejoinRooms();
    });

    _socket!.on('reconnect', (_) {
      print('[Socket] 🔄 Reconnected — re-joining rooms');
      _rejoinRooms();
    });

    _socket!.onDisconnect((_) {
      print('[Socket] ❌ Disconnected');
    });

    _socket!.onError((error) {
      print('[Socket] ⚠️ Error: $error');
    });

    _socket!.onConnectError((error) {
      print('[Socket] 🔴 Connect error: $error');
    });
  }

  void _rejoinRooms() {
    if (_userId != null) {
      _socket?.emit('join_user', _userId);
      print('[Socket] Re-joined user room: user_$_userId');
    }
    if (_agencyId != null) {
      _socket?.emit('join_agency', _agencyId);
      print('[Socket] Re-joined agency room: agency_$_agencyId');
    }
  }

  void joinUser(String userId) {
    _userId = userId;
    _socket?.emit('join_user', userId);
    print('[Socket] Joined user room: user_$userId');
  }

  void joinAgency(String agencyId) {
    _agencyId = agencyId;
    _socket?.emit('join_agency', agencyId);
    print('[Socket] Joined agency room: agency_$agencyId');
  }

  void emitUserMessage({required String receiverId, required dynamic message}) {
    _socket?.emit('send_user_message', {
      'receiverId': receiverId,
      'message': message,
    });
  }

  void emitAgencyMessage({required String agencyId, required dynamic message}) {
    _socket?.emit('send_agency_message', {
      'agencyId': agencyId,
      'message': message,
    });
  }

  /// Register a listener for incoming messages.
  /// Always call [offMessageReceived] before this to avoid stacking.
  void onMessageReceived(Function(dynamic) callback) {
    _socket?.on('receive_user_message', callback);
  }

  void offMessageReceived() {
    _socket?.off('receive_user_message');
  }

  void disconnect() {
    _socket?.clearListeners();
    _socket?.disconnect();
    _socket = null;
    _userId = null;
    _agencyId = null;
  }

  IO.Socket? get socket => _socket;
}
