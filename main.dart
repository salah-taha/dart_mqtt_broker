import 'broker.dart';

void main() {
  final broker = MQTTBroker(host: '127.0.0.1', port: 1883);

  // Hook into the onConnect event
  broker.events.onConnect((client) {
    print('Client connected: ${client.address.address}');
  });

  // Hook into the onPublish event
  broker.events.onPublish((client, data) {
    print('Publish received from client: ${client.address.address}');
    print('Data: ${String.fromCharCodes(data)}');
  });

  // Hook into the onSubscribe event
  broker.events.onSubscribe((client, data) {
    print('Subscribe request received from client: ${client.address.address}');
    print('Subscription data: ${String.fromCharCodes(data)}');
  });

  // Hook into the onUnsubscribe event
  broker.events.onUnsubscribe((client, data) {
    print('Unsubscribe request received from client: ${client.address.address}');
    print('Unsubscription data: ${String.fromCharCodes(data)}');
  });

  // Hook into the onPing event
  broker.events.onPing((client) {
    print('Ping received from client: ${client.address.address}');
  });

  // Hook into the onDisconnect event
  broker.events.onDisconnect((client) {
    print('Client disconnected: ${client.address.address}');
  });

  // Hook into the onWill event
  broker.events.onWill((client, topic, message) {
    print('Will triggered for client: ${client.address.address}');
    print('Topic: $topic');
    print('Message: ${String.fromCharCodes(message)}');
  });

  // Start the MQTT broker
  broker.start();
}
