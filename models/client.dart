import 'dart:io';
import 'dart:typed_data';

class Client {
  Socket socket;
  String clientId;
  bool cleanSession;
  String? willTopic;
  Uint8List? willMessage;
  int willQos;
  bool willRetain;
  final List<String> subscriptions = [];
  final List<Uint8List> pendingMessages = [];

  Client({
    required this.socket,
    required this.clientId,
    this.cleanSession = true,
    this.willTopic,
    this.willMessage,
    this.willQos = 0,
    this.willRetain = false,
  });

  /// Adds a topic subscription
  void addSubscription(String topic) {
    if (!subscriptions.contains(topic)) {
      subscriptions.add(topic);
    }
  }

  /// Removes a topic subscription
  void removeSubscription(String topic) {
    subscriptions.remove(topic);
  }

  /// Adds a pending message for offline storage
  void addPendingMessage(Uint8List message) {
    pendingMessages.add(message);
  }

  /// Clears all pending messages
  void clearPendingMessages() {
    pendingMessages.clear();
  }

  /// Sends data to the client's socket
  void send(Uint8List data) {
    try {
      socket.write(data);
    } catch (e) {
      print('Error sending data to client $clientId: $e');
    }
  }

  @override
  String toString() {
    return 'Client(clientId: $clientId, cleanSession: $cleanSession, subscriptions: $subscriptions, pendingMessages: ${pendingMessages.length})';
  }
}
