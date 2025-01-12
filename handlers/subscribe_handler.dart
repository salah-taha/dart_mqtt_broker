import 'dart:io';
import 'dart:typed_data';

import '../models/client.dart';
import '../models/topic.dart';

void handleSubscribe(
  Socket client,
  Uint8List data,
  Map<String, Topic> topics,
  Map<Socket, Client> clients,
) {
  print('SUBSCRIBE packet received');

  // Extract packet ID and topic
  final packetId = (data[2] << 8) | data[3];
  final topicLength = (data[4] << 8) | data[5];
  final topicName = String.fromCharCodes(data.sublist(6, 6 + topicLength));

  print('Client subscribing to topic: $topicName');

  // Find or create the topic
  final topic = topics.putIfAbsent(topicName, () => Topic(topicName));

  // Add client to the topic's subscribers
  final clientInfo = clients[client];
  if (clientInfo != null) {
    clientInfo.addSubscription(topicName); // Adds to the client's subscription list
    topic.addSubscriber(clientInfo); // Adds the client to the topic's subscriber list

    // Check if the topic has a retained message and send it to the subscribing client
    if (topic.retainedMessage != null) {
      clientInfo.send(topic.retainedMessage!);
      print('Sent retained message to client ${clientInfo.clientId}');
    }
  }

  // Send SUBACK to acknowledge the subscription
  final subAck = Uint8List.fromList([0x90, 0x03, data[2], data[3], 0x00]); // QoS 0
  client.write(subAck);
  print('SUBACK sent to client');
}
