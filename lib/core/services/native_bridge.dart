import 'dart:async';

import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('flashtransfer/native');
  static const EventChannel _events = EventChannel('flashtransfer/native/events');

  Stream<Map<String, dynamic>> get events {
    return _events.receiveBroadcastStream().map((dynamic event) {
      return Map<String, dynamic>.from(event as Map<dynamic, dynamic>);
    });
  }

  Future<List<Map<String, dynamic>>> discoverPeers() async {
    final List<dynamic> peers = await _channel.invokeMethod<List<dynamic>>('discoverPeers') ?? <dynamic>[];
    return peers.map((dynamic peer) => Map<String, dynamic>.from(peer as Map<dynamic, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> getPeers() async {
    final List<dynamic> peers = await _channel.invokeMethod<List<dynamic>>('getPeers') ?? <dynamic>[];
    return peers.map((dynamic peer) => Map<String, dynamic>.from(peer as Map<dynamic, dynamic>)).toList();
  }

  Future<void> stopDiscovery() => _channel.invokeMethod<void>('stopDiscovery');

  Future<void> connect(String address, {Duration timeout = const Duration(seconds: 30)}) {
    return _channel.invokeMethod<void>('connect', <String, Object?>{
      'address': address,
      'timeoutMillis': timeout.inMilliseconds,
    });
  }

  Future<void> disconnect() => _channel.invokeMethod<void>('disconnect');

  Future<Map<String, dynamic>> getConnectionInfo() async {
    final Object? result = await _channel.invokeMethod<Object?>('getConnectionInfo');
    return Map<String, dynamic>.from(result as Map<dynamic, dynamic>);
  }

  Future<void> startServer({int port = 8988}) => _channel.invokeMethod<void>('startServer', <String, Object?>{'port': port});

  Future<void> stopServer() => _channel.invokeMethod<void>('stopServer');

  Future<void> cancelTransfers() => _channel.invokeMethod<void>('cancelTransfers');

  Future<void> sendFile(String uri, String host, int port, {String? sha256}) {
    return _channel.invokeMethod<void>('sendFile', <String, Object?>{
      'uri': uri,
      'host': host,
      'port': port,
      'sha256': sha256,
    });
  }

  Future<String> sha256(String uri) async {
    return await _channel.invokeMethod<String>('sha256', <String, Object?>{'uri': uri}) ?? '';
  }
}
