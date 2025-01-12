import 'dart:io';
import 'dart:typed_data';

import '../models/client.dart';

void handleConnect(
  Socket client,
  Uint8List data,
  Map<String, Client> sessionStore,
  Map<Socket, Client> activeClients,
) {
  final connectFlags = data[9];
  final clientIdLength = (data[10] << 8) | data[11];
  final clientId = String.fromCharCodes(data.sublist(12, 12 + clientIdLength));
  final cleanSession = (connectFlags & 0x02) != 0;

  print('Client connecting: $clientId (cleanSession: $cleanSession)');

  // Parse Will information if provided
  String? willTopic;
  Uint8List? willMessage;
  int willQos = 0;
  bool willRetain = false;

  if ((connectFlags & 0x04) != 0) {
    // Will Flag
    final willTopicLength = (data[12 + clientIdLength] << 8) | data[13 + clientIdLength];
    willTopic = String.fromCharCodes(data.sublist(
      14 + clientIdLength,
      14 + clientIdLength + willTopicLength,
    ));

    final willMessageStart = 14 + clientIdLength + willTopicLength;
    final willMessageEnd = data.length;
    willMessage = Uint8List.fromList(data.sublist(willMessageStart, willMessageEnd));

    willQos = (connectFlags & 0x18) >> 3;
    willRetain = (connectFlags & 0x20) != 0;
  }

  // Restore or create a new client session
  Client? clientInfo;
  if (!cleanSession && sessionStore.containsKey(clientId)) {
    clientInfo = sessionStore[clientId]!
      ..socket = client // Update the socket
      ..willTopic = willTopic
      ..willMessage = willMessage
      ..willQos = willQos
      ..willRetain = willRetain;
    print('Restored session for client: $clientId');
  } else {
    clientInfo = Client(
      socket: client,
      clientId: clientId,
      cleanSession: cleanSession,
      willTopic: willTopic,
      willMessage: willMessage,
      willQos: willQos,
      willRetain: willRetain,
    );
    if (!cleanSession) {
      sessionStore[clientId] = clientInfo;
    }
  }

  activeClients[client] = clientInfo;

  // Send CONNACK with reason code
  final connAck = Uint8List.fromList([0x20, 0x03, 0x00, 0x00, 0x00]); // Session Present = 0, Reason Code = Success
  client.write(connAck);
  print('CONNACK sent for client: $clientId');

  // Send pending messages for the session
  for (final message in clientInfo.pendingMessages) {
    client.write(message);
    print('Pending message delivered to client: $clientId');
  }
  clientInfo.clearPendingMessages();
}
