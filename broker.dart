import 'dart:io';
import 'dart:typed_data';

import 'handlers/connect_handler.dart';
import 'handlers/disconnect_handler.dart';
import 'handlers/ping_handler.dart';
import 'handlers/publish_handler.dart';
import 'handlers/subscribe_handler.dart';
import 'handlers/unsubscribe_handler.dart';
import 'models/client.dart';
import 'models/event_broadcaster.dart';
import 'models/topic.dart';

class MQTTBroker {
  final String host;
  final int port;
  final String? certificatePath;
  final String? privateKeyPath;
  final EventBroadcaster events = EventBroadcaster(); // Event broadcaster
  final Map<String, Client> sessionStore = {}; // Persistent sessions
  final Map<Socket, Client> activeClients = {}; // Active client connections
  final Map<String, Topic> topics = {}; // Topics and subscribers

  MQTTBroker({
    this.host = '0.0.0.0',
    this.port = 1883,
    this.certificatePath,
    this.privateKeyPath,
  });

  void start() async {
    try {
      final server = (certificatePath != null && privateKeyPath != null) ? await _startSecureServer() : await _startInsecureServer();

      await for (var client in server) {
        print('Client connected: ${(client)}');
        _handleClient(client);
      }
    } catch (e) {
      print('Failed to start MQTT Broker: $e');
    }
  }

  Future<dynamic> _startSecureServer() async {
    final securityContext = SecurityContext()
      ..useCertificateChain(certificatePath!)
      ..usePrivateKey(privateKeyPath!);

    print('Starting MQTT Broker with TLS on $host:$port');
    return await SecureServerSocket.bind(host, port, securityContext);
  }

  Future<dynamic> _startInsecureServer() async {
    print('Starting MQTT Broker without TLS on $host:$port');
    return await ServerSocket.bind(host, port);
  }

  void _handleClient(dynamic client) {
    client.listen((data) {
      _processPacket(client, Uint8List.fromList(data));
    }, onDone: () {
      print('Client disconnected: ${(client)}');
      handleDisconnect(client, activeClients, topics, sessionStore, events);
      events.triggerDisconnect(client); // Trigger onDisconnect event
    }, onError: (error) {
      print('Error with client ${(client)}: $error');
      handleDisconnect(client, activeClients, topics, sessionStore, events);
      events.triggerDisconnect(client); // Trigger onDisconnect event
    });
  }

  void _processPacket(dynamic client, Uint8List data) {
    final firstByte = data[0];
    final messageType = (firstByte & 0xF0) >> 4;

    switch (messageType) {
      case 1: // CONNECT
        handleConnect(client, data, sessionStore, activeClients);
        events.triggerConnect(client);
        break;
      case 3: // PUBLISH
        handlePublish(client, data, topics, sessionStore);
        events.triggerPublish(client, data);
        break;
      case 8: // SUBSCRIBE
        handleSubscribe(client, data, topics, activeClients);
        events.triggerSubscribe(client, data);
        break;
      case 10: // UNSUBSCRIBE
        handleUnsubscribe(client, data, topics, activeClients);
        events.triggerUnsubscribe(client, data);
        break;
      case 12: // PINGREQ
        handlePing(client, data);
        events.triggerPing(client);
        break;
      default:
        print('Unsupported MQTT packet type: $messageType');
        events.triggerUnsupported(client, data);
        break;
    }
  }

  String getClientAddress(dynamic client) {
    return client is SecureSocket ? client.address.address : (client as Socket).remoteAddress.address;
  }
}
