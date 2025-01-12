import 'dart:io';
import 'dart:typed_data';

class EventBroadcaster {
  final List<Function(Socket client)> onConnectHandlers = [];
  final List<Function(Socket client, Uint8List data)> onPublishHandlers = [];
  final List<Function(Socket client, Uint8List data)> onSubscribeHandlers = [];
  final List<Function(Socket client, Uint8List data)> onUnsubscribeHandlers = [];
  final List<Function(Socket client)> onPingHandlers = [];
  final List<Function(Socket client)> onDisconnectHandlers = [];
  final List<Function(Socket client, String topic, Uint8List message)> onWillHandlers = [];

  void onConnect(Function(Socket client) handler) {
    onConnectHandlers.add(handler);
  }

  void onPublish(Function(Socket client, Uint8List data) handler) {
    onPublishHandlers.add(handler);
  }

  void onSubscribe(Function(Socket client, Uint8List data) handler) {
    onSubscribeHandlers.add(handler);
  }

  void onUnsubscribe(Function(Socket client, Uint8List data) handler) {
    onUnsubscribeHandlers.add(handler);
  }

  void onPing(Function(Socket client) handler) {
    onPingHandlers.add(handler);
  }

  void onDisconnect(Function(Socket client) handler) {
    onDisconnectHandlers.add(handler);
  }

  void onWill(Function(Socket client, String topic, Uint8List message) handler) {
    onWillHandlers.add(handler);
  }

  void triggerConnect(Socket client) {
    for (var handler in onConnectHandlers) {
      handler(client);
    }
  }

  void triggerPublish(Socket client, Uint8List data) {
    for (var handler in onPublishHandlers) {
      handler(client, data);
    }
  }

  void triggerSubscribe(Socket client, Uint8List data) {
    for (var handler in onSubscribeHandlers) {
      handler(client, data);
    }
  }

  void triggerUnsubscribe(Socket client, Uint8List data) {
    for (var handler in onUnsubscribeHandlers) {
      handler(client, data);
    }
  }

  void triggerPing(Socket client) {
    for (var handler in onPingHandlers) {
      handler(client);
    }
  }

  void triggerDisconnect(Socket client) {
    for (var handler in onDisconnectHandlers) {
      handler(client);
    }
  }

  void triggerWill(Socket client, String topic, Uint8List message) {
    for (var handler in onWillHandlers) {
      handler(client, topic, message);
    }
  }

  void triggerUnsupported(Socket client, Uint8List data) {
    for (var handler in onPublishHandlers) {
      handler(client, data);
    }
  }
}
