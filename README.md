# MQTT Broker with Optional TLS Support

This project implements an MQTT broker in Dart with support for optional SSL/TLS encryption. It is lightweight, customizable, and adheres to MQTT protocol specifications.

## Features

- **MQTT Protocol Support**: Implements core MQTT protocol functionality.
- **TLS/SSL Support**: Provides secure connections using a self-signed or CA-signed certificate.
- **Dynamic Event Handling**: Customizable hooks for events like `onConnect`, `onPublish`, `onSubscribe`, etc.
- **Retained Messages**: Supports retained messages for topics.
- **QoS Levels**: Implements Quality of Service levels 0, 1, and 2.
- **Last Will and Testament (LWT)**: Ensures client disconnection messages are handled.
- **Wildcard Topics**: Supports topic filters with `+` and `#` wildcards.

## Future Features

The following features can be considered for future development:

- **MQTT Version 5.0 Support**:
  - User Properties: Allow custom metadata for MQTT messages.
  - Session Expiry: Handle session expiration intervals.
  - Reason Codes: Include reason codes in acknowledgments.
- **Clustered Deployment**:
  - Support for scaling the broker horizontally with multiple nodes.
  - Distributed session and topic management.
- **Enhanced Authentication**:
  - Support for username/password-based authentication.
  - Integration with OAuth2, JWT, or external authentication providers.
- **WebSocket Support**:
  - Allow MQTT over WebSocket connections for web-based clients.
- **Message Persistence**:
  - Store published messages in a database for durability.
  - Support replaying messages to new subscribers.
- **Monitoring and Metrics**:
  - Real-time monitoring of connected clients and topics.
  - Metrics for message throughput, latency, and resource usage.
- **Advanced Access Control**:
  - Topic-based access permissions for clients.
  - Integration with ACL (Access Control List) systems.
- **HTTP API for Administration**:
  - RESTful API to manage clients, topics, and broker settings.

## Requirements

- Dart SDK (>=2.12)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/mskayali/dart_mqtt_broker.git
   cd mqtt-broker-dart
   ```

2. Install dependencies:

   ```bash
   dart pub get
   ```

## Usage

### Starting the Broker

The broker can be run in either secure (TLS) or non-secure mode.

#### Insecure Mode

```dart
void main() {
  final broker = MQTTBroker(host: '0.0.0.0', port: 1883);
  broker.start();
}
```

#### Secure Mode

```dart
void main() {
  final broker = MQTTBroker(
    host: '0.0.0.0',
    port: 8883,
    certificatePath: 'path/to/certificate.pem',
    privateKeyPath: 'path/to/private.key',
  );
  broker.start();
}
```

### Event Hooks

The broker provides event hooks for common MQTT actions:

```dart
void main() {
  final broker = MQTTBroker(port: 1883);

  // Register event handlers
  broker.events.onConnect((client) => print('Client connected: $client'));
  broker.events.onPublish((client, data) => print('Publish received: $data'));
  broker.events.onSubscribe((client, data) => print('Subscription: $data'));
  broker.events.onUnsubscribe((client, data) => print('Unsubscription: $data'));
  broker.events.onPing((client) => print('Ping received'));
  broker.events.onDisconnect((client) => print('Client disconnected: $client'));
  broker.events.onWill((client, topic, message) {
    print('Last Will from $client: $topic -> $message');
  });

  broker.start();
}
```

## Certificate Setup

### Generating a Self-Signed Certificate

1. Generate a private key:

   ```bash
   openssl genrsa -out private.key 2048
   ```

2. Generate a self-signed certificate:

   ```bash
   openssl req -new -x509 -key private.key -out certificate.pem -days 365
   ```

### Using the Certificate

- Place `certificate.pem` and `private.key` in your project directory.
- Provide their paths when initializing the broker in secure mode.

## Testing

### Running Unit Tests

```bash
dart test
```

### Connecting with an MQTT Client

Use any MQTT client to connect to the broker:

#### Insecure Connection

```bash
mosquitto_pub -h localhost -p 1883 -t test/topic -m "Hello World"
```

#### Secure Connection

```bash
mosquitto_pub --cafile certificate.pem -h localhost -p 8883 -t test/topic -m "Hello Secure World"
```

## Folder Structure

```
├── handlers/          # Packet handlers (connect, publish, etc.)
├── models/            # Core models (Client, Topic, EventBroadcaster)
├── test/              # Unit tests
├── main.dart          # Example entry point
├── broker.dart        # Main broker implementation
└── README.md          # Project documentation
```

## Contributing

Contributions are welcome! Please submit issues or pull requests via GitHub.

## License

This project is licensed under the MIT License. See `LICENSE` for details.
