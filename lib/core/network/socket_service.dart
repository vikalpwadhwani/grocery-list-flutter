import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? _socket;
  bool _isConnected = false;

  SocketService._internal();

  IO.Socket? get socket => _socket;
  bool get isConnected => _isConnected;

  void connect() {
    if (_socket != null && _isConnected) {
      if (kDebugMode) {
        print('Socket already connected');
      }
      return;
    }

    try {
      _socket = IO.io(
        ApiConstants.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        _isConnected = true;
        if (kDebugMode) {
          print('Socket connected: ${_socket!.id}');
        }
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        if (kDebugMode) {
          print('Socket disconnected');
        }
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        if (kDebugMode) {
          print(' Socket connection error: $error');
        }
      });

      _socket!.onError((error) {
        if (kDebugMode) {
          print(' Socket error: $error');
        }
      });

      _socket!.onReconnect((_) {
        _isConnected = true;
        if (kDebugMode) {
          print(' Socket reconnected');
        }
      });

    } catch (e) {
      if (kDebugMode) {
        print(' Socket init error: $e');
      }
    }
  }

  void joinList(String listId) {
    if (_socket == null) {
      if (kDebugMode) {
        print(' Cannot join list - socket not initialized');
      }
      return;
    }
    _socket!.emit('join-list', listId);
    if (kDebugMode) {
      print(' Joined list room: $listId');
    }
  }

  void leaveList(String listId) {
    if (_socket == null) return;
    _socket!.emit('leave-list', listId);
    if (kDebugMode) {
      print('Left list room: $listId');
    }
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
    if (kDebugMode) {
      print(' Socket listeners removed');
    }
  }

  void removeListener(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    if (_socket != null) {
      removeListeners();
      _socket!.disconnect();
      _socket = null;
      _isConnected = false;
      if (kDebugMode) {
        print(' Socket disconnected and cleaned up');
      }
    }
  }

  void reconnect() {
    disconnect();
    connect();
  }
}