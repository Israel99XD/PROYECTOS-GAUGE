import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultrasonic Sensor MQTT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SensorPage(),
    );
  }
}

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final String broker = 'broker.hivemq.com';
  final String topic = 'sensor/ultrasonic';
  MqttServerClient? client;
  String sensorData = '';

  @override
  void initState() {
    super.initState();
    connectMQTT();
  }

  void connectMQTT() async {
    client =
        MqttServerClient(broker, 'sensor/ultrasonic'); // Set a unique client ID
    client!.port = 1883;
    client!.logging(on: true);

    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;

    try {
      await client!.connect();
      print('Connected to MQTT broker');
    } catch (e) {
      print('Connection failed: $e');
      client!.disconnect();
    }
  }

  void onConnected() {
    print('Connected');
    client!.subscribe(topic, MqttQos.atLeastOnce);
    print('Subscribed to $topic');
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);
      print('Received message: $payload');
      setState(() {
        sensorData = payload;
      });
    });
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ultrasonic Sensor MQTT'),
      ),
      body: Center(
        child: Text(
          sensorData.isEmpty ? 'No data received' : 'Sensor Data: $sensorData',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
