import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gauge MQTT App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GaugeScreen(),
    );
  }
}

class GaugeScreen extends StatefulWidget {
  const GaugeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GaugeScreenState createState() => _GaugeScreenState();
}

class _GaugeScreenState extends State<GaugeScreen> {
  late MqttService _mqttService;
  double _temperature = 0.0;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService('broker.emqx.io', '');
    _mqttService.getTemperatureStream().listen((temperature) {
      setState(() {
        _temperature = temperature;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Gauge'),
      ),
      body: Center(
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: -50,
              maximum: 150,
              pointers: <GaugePointer>[
                NeedlePointer(value: _temperature),
              ],
              ranges: <GaugeRange>[
                GaugeRange(startValue: -50, endValue: 0, color: Colors.blue),
                GaugeRange(startValue: 0, endValue: 100, color: Colors.green),
                GaugeRange(startValue: 100, endValue: 150, color: Colors.red),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Text(
                    '$_temperature°C',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
