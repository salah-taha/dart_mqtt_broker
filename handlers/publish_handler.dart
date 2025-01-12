import 'dart:io';
import 'dart:typed_data';

import '../models/client.dart';
import '../models/topic.dart';

void handlePublish(
  Socket client,
  Uint8List data,
  Map<String, Topic> topics,
  Map<String, Client> sessionStore,
) {
  print('PUBLISH packet received');

  // Extract QoS level
  final firstByte = data[0];
  final qos = (firstByte & 0x06) >> 1; // QoS bits (bit 1 and 2)

  // Extract topic and payload
  final topicLength = (data[2] << 8) | data[3];
  final topicName = String.fromCharCodes(data.sublist(4, 4 + topicLength));
  final payloadStart = 4 + topicLength;
  final payload = Uint8List.fromList(data.sublist(payloadStart));

  print('Topic: $topicName');
  print('Payload: ${String.fromCharCodes(payload)}');
  print('QoS: $qos');

  // Handle retained message
  final retain = (firstByte & 0x01) != 0;
  final topic = topics.putIfAbsent(topicName, () => Topic(topicName));
  if (retain) {
    topic.setRetainedMessage(data);
  }

  // Broadcast message to online subscribers
  for (final subscriber in topic.subscribers) {
    if (subscriber.socket != client) {
      subscriber.send(data);
      print('Message sent to subscriber: ${subscriber.clientId}');
    }
  }

  // Queue messages for offline subscribers
  for (final client in sessionStore.values) {
    if (client.subscriptions.contains(topicName) && client.socket != client) {
      client.addPendingMessage(data);
      print('Message queued for offline client: ${client.clientId}');
    }
  }

  // QoS Handling
  switch (qos) {
    case 1:
      // Send PUBACK
      final packetId = data.sublist(payloadStart - 2, payloadStart);
      final pubAck = Uint8List.fromList([0x40, 0x02, ...packetId]);
      client.write(pubAck);
      print('PUBACK sent');
      break;

    case 2:
      // Send PUBREC and wait for PUBREL
      final packetId = data.sublist(payloadStart - 2, payloadStart);
      final pubRec = Uint8List.fromList([0x50, 0x02, ...packetId]);
      client.write(pubRec);
      print('PUBREC sent');
      // Additional logic for PUBREL and PUBCOMP goes here
      break;

    case 0:
    default:
      // QoS 0: Fire and forget
      print('QoS 0: Message delivered without acknowledgment');
      break;
  }
}
