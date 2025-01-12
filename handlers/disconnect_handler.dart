import 'dart:io';

import '../models/client.dart';
import '../models/event_broadcaster.dart';
import '../models/topic.dart';


void handleDisconnect(
  Socket client,
  Map<Socket, Client> activeClients,
  Map<String, Topic> topics,
  Map<String, Client> sessionStore,
  EventBroadcaster events,
) {
  final clientInfo = activeClients.remove(client);
  if (clientInfo != null) {
    // Handle Last Will and Testament
    if (clientInfo.willTopic != null && clientInfo.willMessage != null) {
      print('Broadcasting Last Will for client: ${clientInfo.clientId}');

      final topic = topics.putIfAbsent(clientInfo.willTopic!, () => Topic(clientInfo.willTopic!));
      topic.broadcast(clientInfo.willMessage!, qos: clientInfo.willQos);

      if (clientInfo.willRetain) {
        topic.setRetainedMessage(clientInfo.willMessage!);
        events.triggerWill(client, topic.name, clientInfo.willMessage!);
      }
    }

    // Persist session if cleanSession is false
    if (!clientInfo.cleanSession) {
      sessionStore[clientInfo.clientId] = clientInfo;
      print('Session for client ${clientInfo.clientId} persisted.');
    } else {
      print('Session for client ${clientInfo.clientId} removed.');
    }

    // Remove the client from all subscribed topics
    for (final topic in topics.values) {
      topic.removeSubscriber(clientInfo);
    }
  }
}
