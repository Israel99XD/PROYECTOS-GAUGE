import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Line Chart App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LineChartScreen(),
    );
  }
}

class LineChartScreen extends StatefulWidget {
  const LineChartScreen({super.key});

  @override
  _LineChartScreenState createState() => _LineChartScreenState();
}

class _LineChartScreenState extends State<LineChartScreen> {
  late MqttService _mqttService;
  final List<TemperatureData> _data = [];
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    super.initState();
    _mqttService = MqttService('broker.emqx.io', '');
    _mqttService.getTemperatureStream().listen((temperature) {
      setState(() {
        _data.add(TemperatureData(DateTime.now(), temperature));
        if (_data.length > 20) {
          _data.removeAt(0);
        }
        _chartSeriesController.updateDataSource(
            addedDataIndex: _data.length - 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Line Chart App'),
      ),
      body: SfCartesianChart(
        primaryXAxis: DateTimeAxis(),
        series: <LineSeries<TemperatureData, DateTime>>[
          LineSeries<TemperatureData, DateTime>(
            dataSource: _data,
            xValueMapper: (TemperatureData data, _) => data.time,
            yValueMapper: (TemperatureData data, _) => data.temperature,
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
          ),
        ],
      ),
    );
  }
}

class TemperatureData {
  TemperatureData(this.time, this.temperature);
  final DateTime time;
  final double temperature;
}
