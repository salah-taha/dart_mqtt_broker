import 'dart:io';
import 'dart:typed_data';

Future<void> main() async {
  final host = '127.0.0.1';
  final port = 1883;

  print('Testing MQTT server at $host:$port');

  // Connect to the MQTT broker
  final socket = await RawSocket.connect(host, port);
  print('Connected to MQTT broker');

  // Test CONNECT
  testConnect(socket);

  // Test SUBSCRIBE
  testSubscribe(socket, 'test/topic');

  // Test PUBLISH
  testPublish(socket, 'test/topic', 'Hello MQTT');

  // Test UNSUBSCRIBE
  testUnsubscribe(socket, 'test/topic');

  // Test PINGREQ
  testPing(socket);

  // Disconnect
  socket.close();
  print('Disconnected from MQTT broker');
}

void testConnect(RawSocket socket) {
  final clientId = 'test_client';
  final connectPacket = Uint8List.fromList([
    0x10, // Fixed header for CONNECT
    12 + clientId.length, // Remaining length
    0x00,
    0x04, // Protocol Name Length
    'M'.codeUnitAt(0),
    'Q'.codeUnitAt(0),
    'T'.codeUnitAt(0),
    'T'.codeUnitAt(0),
    0x04, // Protocol Level (4 for MQTT 3.1.1)
    0x02, // Connect Flags (Clean Session)
    0x00,
    0x3C, // Keep Alive (60 seconds)
    0x00,
    clientId.length, // Client ID Length
    ...clientId.codeUnits, // Client ID
  ]);

  socket.write(connectPacket);
  print('CONNECT packet sent');
  handleResponse(socket);
}

void testSubscribe(RawSocket socket, String topic) {
  final subscribePacket = Uint8List.fromList([
    0x82, // Fixed header for SUBSCRIBE
    5 + topic.length, // Remaining length
    0x00,
    0x01, // Packet Identifier
    0x00,
    topic.length, // Topic Length
    ...topic.codeUnits, // Topic
    0x00, // QoS 0
  ]);

  socket.write(subscribePacket);
  print('SUBSCRIBE packet sent for topic: $topic');
  handleResponse(socket);
}

void testPublish(RawSocket socket, String topic, String message) {
  final publishPacket = Uint8List.fromList([
    0x30, // Fixed header for PUBLISH (QoS 0)
    2 + topic.length + message.length, // Remaining length
    0x00,
    topic.length, // Topic Length
    ...topic.codeUnits, // Topic
    ...message.codeUnits, // Message Payload
  ]);

  socket.write(publishPacket);
  print('PUBLISH packet sent for topic: $topic with message: $message');
  handleResponse(socket);
}

void testUnsubscribe(RawSocket socket, String topic) {
  final unsubscribePacket = Uint8List.fromList([
    0xA2, // Fixed header for UNSUBSCRIBE
    4 + topic.length, // Remaining length
    0x00,
    0x01, // Packet Identifier
    0x00,
    topic.length, // Topic Length
    ...topic.codeUnits, // Topic
  ]);

  socket.write(unsubscribePacket);
  print('UNSUBSCRIBE packet sent for topic: $topic');
  handleResponse(socket);
}

void testPing(RawSocket socket) {
  final pingPacket = Uint8List.fromList([
    0xC0, // Fixed header for PINGREQ
    0x00, // Remaining length
  ]);

  socket.write(pingPacket);
  print('PINGREQ packet sent');
  handleResponse(socket);
}

void handleResponse(RawSocket socket) {
  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final data = socket.read();
      if (data != null) {
        print('Response from server: ${data.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ')}');
      }
    }
  });
}
