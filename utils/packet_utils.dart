import 'dart:typed_data';

Uint8List createPacketHeader(int type, int remainingLength) {
  return Uint8List.fromList([type << 4, remainingLength]);
}

// Add other helpers as needed
