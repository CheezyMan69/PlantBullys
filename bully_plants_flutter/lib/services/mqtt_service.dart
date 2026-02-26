import 'dart:convert';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../database/models/plant.dart';
import '../database/models/sensor_reading.dart';
import '../database/repositories/plant_repository.dart';
import '../database/repositories/sensor_reading_repository.dart';

class MQTTService {
  late MqttServerClient _client;

  // ===== CONFIG =====
  final String broker = 'iot.coreflux.cloud'; // change if needed
  final int port = 1883; // use 8883 if TLS
  final String clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';

  final String username = 'YOUR_USERNAME';
  final String password = 'YOUR_PASSWORD';

  final String topic = 'bingbong/sdata'; // wildcard for debugging

  // ==================

  Future<void> connect() async {
    print('🔌 Initializing MQTT Client...');

    _client = MqttServerClient(broker, clientId);

    _client.port = port;
    _client.keepAlivePeriod = 30;
    _client.autoReconnect = true;

    _client.logging(on: true);

    // If Coreflux requires SSL
    /*
    _client.secure = true;
    _client.securityContext = SecurityContext.defaultContext;
    */

    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        //.authenticateAs(username, password)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMessage;

    try {
      print('🚀 Connecting to $broker...');

      await _client.connect();
    } catch (e) {
      print('❌ MQTT Connection Error: $e');
      _client.disconnect();
      return;
    }

    if (_client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      print('✅ MQTT Connected Successfully');

      _subscribe();
      _listen();
    } else {
      print('❌ Connection Failed: ${_client.connectionStatus}');
      _client.disconnect();
    }
  }

  // =====================
  // SUBSCRIBE
  // =====================

  void _subscribe() {
    print('📡 Subscribing to: $topic');

    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  // =====================
  // LISTEN
  // =====================

  void _listen() {
    print('👂 Listening for MQTT messages...');

    _client.updates?.listen(
          (List<MqttReceivedMessage<MqttMessage>> messages) {

        final recMessage =
        messages[0].payload as MqttPublishMessage;

        final payload = MqttPublishPayload
            .bytesToStringAsString(
            recMessage.payload.message);

        final topic = messages[0].topic;

        print('==============================');
        print('📩 MESSAGE RECEIVED');
        print('Topic: $topic');
        print('Payload: $payload');
        print('==============================');

        _handleMessage(payload);
      },
      onError: (e) {
        print('❌ Listen Error: $e');
      },
    );
  }

  // =====================
  // HANDLE DATA
  // =====================

  Future<void> _handleMessage(String payload) async {
    print('🧠 Processing payload...');

    try {
      final data = jsonDecode(payload);

      print('✅ JSON Decoded: $data');

      final reading = SensorReading(
        plantId: data['plantId']?.toInt(),
        temperature: (data['temp'] as num?)?.toDouble(),
        humidity: (data['humidity'] as num?)?.toDouble(),
        soilMoisture: (data['soil moisture'] as num?)?.toDouble(),
        light: (data['light'] as num?)?.toDouble(),
        recordedAt: DateTime.now(),
      );

      await SensorReadingRepository().insert(reading);

      print('💾 Data Saved to Database');

    } catch (e, stack) {
      print('❌ Payload Processing Error');
      print(e);
      print(stack);
    }
  }

  // =====================
  // CALLBACKS
  // =====================

  void _onConnected() {
    print('🟢 MQTT Connected Callback');
  }

  void _onDisconnected() {
    print('🔴 MQTT Disconnected');
  }

  void _onSubscribed(String topic) {
    print('📬 Subscribed to $topic');
  }

  void _onSubscribeFail(String topic) {
    print('❌ Failed to Subscribe: $topic');
  }

  // =====================
  // DISCONNECT
  // =====================

  void disconnect() {
    print('👋 Disconnecting MQTT...');
    _client.disconnect();
  }
}