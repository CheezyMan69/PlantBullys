import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../database/models/sensor_reading.dart';
import '../database/repositories/sensor_reading_repository.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();

  factory MqttService() => _instance;

  MqttService._internal();

  /* ======================
     MQTT SETTINGS
  ====================== */

  final String broker = 'iot.coreflux.cloud';
  final int port = 1883;
  final String clientId = 'bingbong';
  final String topic = 'bingbong/sdata';

  late MqttServerClient _client;

  /* ======================
     CONNECT
  ====================== */

  Future<void> connect() async {
    _client = MqttServerClient(broker, clientId);

    _client.port = port;
    _client.keepAlivePeriod = 20;
    _client.autoReconnect = true;

    _client.logging(on: false);

    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e) {
      print('MQTT Connect Error: $e');
      _client.disconnect();
      return;
    }

    if (_client.connectionStatus?.state ==
        MqttConnectionState.connected) {
      print('MQTT Connected');

      _subscribe();
      _listen();
    } else {
      print('MQTT Connection Failed');
      _client.disconnect();
    }
  }

  /* ======================
     SUBSCRIBE
  ====================== */

  void _subscribe() {
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  /* ======================
     LISTEN
  ====================== */

  void _listen() {
    _client.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) {
        final recMessage =
            messages[0].payload as MqttPublishMessage;

        final payload = MqttPublishPayload
            .bytesToStringAsString(
                recMessage.payload.message);

        _handleMessage(payload);
      },
    );
  }


  Future<void> _handleMessage(String payload) async {
    try {
      final data = jsonDecode(payload);

      final reading = SensorReading(
        plantId: data['plantId'],
        temperature:
            (data['temp'] as num?)?.toDouble(),
        humidity: (data['humidity'] as num?)?.toDouble(),
        soilMoisture:
            (data['soil moisture'] as num?)?.toDouble(),
        light:
            (data['light'] as num?)?.toDouble(),
        recordedAt: DateTime.now(),
      );

      await SensorReadingRepository().insert(reading);

      print('MQTT Data Saved');
    } catch (e) {
      print('MQTT Parse Error: $e');
    }
  }


  void publish(Map<String, dynamic> data) {
    final builder = MqttClientPayloadBuilder();

    builder.addString(jsonEncode(data));

    _client.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
  }



  void _onConnected() {
    print('MQTT Connected');
  }

  void _onDisconnected() {
    print('MQTT Disconnected');
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}