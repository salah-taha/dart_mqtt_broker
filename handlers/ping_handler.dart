import 'dart:io';
import 'dart:typed_data';

void handlePing(Socket client, Uint8List data) {
  print('PINGREQ packet received');

  // Send PINGRESP to acknowledge the ping request
  final pingResp = Uint8List.fromList([0xD0, 0x00]); // PINGRESP packet
  client.write(pingResp);
  print('PINGRESP sent to client');
}
