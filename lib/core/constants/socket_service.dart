import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  
  IO.Socket? _socket;
  
  SocketService._internal();

  IO.Socket? get socket => _socket;

  void connect() {
    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
    });

    _socket!.onDisconnect((_) {
    });

    _socket!.onConnectError((error) {
    });
  }

  void joinList(String listId) {
    _socket?.emit('join-list', listId);
  }

  void leaveList(String listId) {
    _socket?.emit('leave-list', listId);
  }

  void onItemAdded(Function(dynamic) callback) {
    _socket?.on('item-added', callback);
  }

  void onItemToggled(Function(dynamic) callback) {
    _socket?.on('item-toggled', callback);
  }

  void onItemUpdated(Function(dynamic) callback) {
    _socket?.on('item-updated', callback);
  }

  void onItemDeleted(Function(dynamic) callback) {
    _socket?.on('item-deleted', callback);
  }

  void onMemberJoined(Function(dynamic) callback) {
    _socket?.on('member-joined', callback);
  }

  void onListDeleted(Function(dynamic) callback) {
    _socket?.on('list-deleted', callback);
  }

  void removeListeners() {
    _socket?.off('item-added');
    _socket?.off('item-toggled');
    _socket?.off('item-updated');
    _socket?.off('item-deleted');
    _socket?.off('member-joined');
    _socket?.off('list-deleted');
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}