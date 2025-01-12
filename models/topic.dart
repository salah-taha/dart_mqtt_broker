import 'dart:typed_data';

import 'client.dart';

class Topic {
  final String name;
  final List<Client> subscribers = [];
  Uint8List? retainedMessage;

  Topic(this.name);

  /// Adds a subscriber to the topic
  void addSubscriber(Client client) {
    if (!subscribers.contains(client)) {
      subscribers.add(client);
      print('Client ${client.clientId} subscribed to $name');
    }
  }

  /// Removes a subscriber from the topic
  void removeSubscriber(Client client) {
    subscribers.remove(client);
    print('Client ${client.clientId} unsubscribed from $name');
  }

  /// Sets a retained message for the topic
  void setRetainedMessage(Uint8List message) {
    retainedMessage = message;
    print('Retained message set for $name');
  }

  /// Broadcasts a message to all subscribers
  void broadcast(Uint8List message, {int qos = 0}) {
    for (final subscriber in subscribers) {
      if (qos == 1) {
        // QoS 1: Ensure delivery acknowledgment
        _sendWithAcknowledgment(subscriber, message);
      } else if (qos == 2) {
        // QoS 2: Two-phase delivery
        _sendWithTwoPhaseDelivery(subscriber, message);
      } else {
        subscriber.send(message); // QoS 0: Fire and forget
      }
    }
    print('Message broadcasted to $name');
  }

  /// Matches a topic with wildcards
  bool matches(String topic) {
    final topicLevels = name.split('/');
    final subscriptionLevels = topic.split('/');

    for (var i = 0; i < subscriptionLevels.length; i++) {
      if (i >= topicLevels.length) return false;

      if (subscriptionLevels[i] == '+') continue;
      if (subscriptionLevels[i] == '#') return true;

      if (subscriptionLevels[i] != topicLevels[i]) return false;
    }
    return topicLevels.length == subscriptionLevels.length;
  }

  void _sendWithAcknowledgment(Client client, Uint8List message) {
    client.send(message);
    print('QoS 1: Sent message to ${client.clientId} and awaiting PUBACK');
    // Add logic to wait for PUBACK
  }

  void _sendWithTwoPhaseDelivery(Client client, Uint8List message) {
    client.send(message);
    print('QoS 2: Sent PUBREC to ${client.clientId}');
    // Add logic for PUBREC, PUBREL, and PUBCOMP
  }
}
