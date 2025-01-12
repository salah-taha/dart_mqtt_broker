import 'dart:io';
import 'dart:typed_data';

import '../models/client.dart';
import '../models/topic.dart';

void handleUnsubscribe(
  Socket client,
  Uint8List data,
  Map<String, Topic> topics,
  Map<Socket, Client> clients,
) {
  print('UNSUBSCRIBE packet received');

  // Extract packet ID and topic
  final packetId = (data[2] << 8) | data[3];
  final topicLength = (data[4] << 8) | data[5];
  final topicName = String.fromCharCodes(data.sublist(6, 6 + topicLength));

  print('Client requesting to unsubscribe from topic: $topicName');

  // Find the client in the active clients map
  final clientInfo = clients[client];
  if (clientInfo != null) {
    // Remove the topic from the client's subscriptions
    clientInfo.removeSubscription(topicName);

    // Remove the client from the topic's subscribers list
    final topic = topics[topicName];
    if (topic != null) {
      topic.removeSubscriber(clientInfo);
      print('Client ${clientInfo.clientId} unsubscribed from topic: $topicName');
    } else {
      print('Topic $topicName does not exist');
    }
  } else {
    print('Client is not registered in active clients');
  }

  // Send UNSUBACK to acknowledge the unsubscription
  final unsubAck = Uint8List.fromList([0xB0, 0x02, data[2], data[3]]); // UNSUBACK packet
  client.write(unsubAck);
  print('UNSUBACK sent');
}
