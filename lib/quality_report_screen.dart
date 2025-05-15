import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/service_class/hive_service_class.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import 'models/local_send_data_model.dart';

class ProductionReportScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    var cp=context.read<CountingProvider>();
    final hourlyData = _processHourlyData(cp.testingreportDataList);
    final statusSummary = _getStatusSummary(cp.testingreportDataList);
    final chartData = _prepareChartData(hourlyData);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daily Production Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCards(statusSummary),
            const SizedBox(height: 24),
            _buildHourlyChart(chartData),
            const SizedBox(height: 24),
            _buildHourlyTable(hourlyData),
          ],
        ),
      ),
    );
  }

  // Process data into hourly counts
  Map<String, Map<int, int>> _processHourlyData(List<LocalSendDataModel> data) {
    final hourlyCounts = <String, Map<int, int>>{};

    for (var item in data) {
      final createdDate = DateTime.parse(item.createdDate!);
      final hour = DateFormat('HH:00').format(createdDate);
      final status = int.parse(item.status??'0');

      hourlyCounts.putIfAbsent(hour, () => {1: 0, 2: 0, 3: 0, 4: 0});
      hourlyCounts[hour]![status] = hourlyCounts[hour]![status]! + 1;
    }

    return hourlyCounts;
  }

  // Get status summary totals
  Map<int, int> _getStatusSummary(List<LocalSendDataModel> data) {
    final summary = {1: 0, 2: 0, 4: 0}; // Removed status 3 from summary
    for (var item in data) {
      final status = int.parse(item.status.toString());
      if (status == 1 || status == 3) {
        summary[1] = summary[1]! + 1; // Combine status 1 and 3 as Pass
      } else if (status == 2) {
        summary[2] = summary[2]! + 1;
      } else if (status == 4) {
        summary[4] = summary[4]! + 1;
      }
    }
    return summary;
  }

  // Prepare data for stacked column chart
  List<CartesianSeries> _prepareChartData(Map<String, Map<int, int>> hourlyData) {
    final hours = hourlyData.keys.toList()..sort();
    const statusColors = {
      1: Colors.green, // Now includes status 3 counts
      2: Colors.orange,
      4: Colors.red,
    };

    return [
      for (final status in [1, 2, 4]) // Removed status 3 from chart
        StackedColumnSeries<HourlyData, String>(
          dataSource: hours.map((hour) {
            int count = hourlyData[hour]![status]!;
            if (status == 1) {
              count += hourlyData[hour]![3]!; // Add status 3 counts to status 1
            }
            return HourlyData(
              hour: hour,
              count: count,
              status: status,
            );
          }).toList(),
          xValueMapper: (HourlyData data, _) => data.hour,
          yValueMapper: (HourlyData data, _) => data.count,
          name: _getStatusName(status),
          color: statusColors[status],
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
    ];
  }

  // String _getStatusName(int status) {
  //   switch (status) {
  //     case 1: return 'Pass';
  //     case 2: return 'Alter';
  //     case 3: return 'Alter Check';
  //     case 4: return 'Reject';
  //     default: return 'Unknown';
  //   }
  // }

  // Build summary cards
  Widget _buildSummaryCards(Map<int, int> summary) {
    const statusColors = {
      1: Colors.green,
      2: Colors.orange,
      4: Colors.red,
    };

    // Filter out status 3 (Alter Check) and calculate total pass + alter
    final filteredSummary = summary..remove(3);
    final totalPassAlter = (summary[1] ?? 0) + (summary[2] ?? 0);

    return Row(

      children: [
        // Status cards (excluding Alter Check)
        ...filteredSummary.entries.map((entry) {
          return Expanded(

            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getStatusName(entry.key),
                      style: TextStyle(
                        color: statusColors[entry.key],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),

        // Pass+Alter total card
        SizedBox(
          width: 100,
          child: Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalPassAlter.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusName(int status) {
    switch (status) {
      case 1: return 'Pass';
      case 2: return 'Alter';
      case 4: return 'Reject';
      default: return '';
    }
  }

  // Build Syncfusion stacked column chart
  Widget _buildHourlyChart(List<CartesianSeries> series) {
    return SizedBox(
      height: 350,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelRotation: -45,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Quantity'),
        ),
        series: series,
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  // Build hourly data table
  Widget _buildHourlyTable(Map<String, Map<int, int>> hourlyData) {
    final hours = hourlyData.keys.toList()..sort();

    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hourly Production Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Hour')),
                  DataColumn(label: Text('Pass'), numeric: true),
                  DataColumn(label: Text('Alter'), numeric: true),
                  DataColumn(label: Text('Reject'), numeric: true),
                  DataColumn(label: Text('Total'), numeric: true),
                ],
                rows: hours.map((hour) {
                  final data = hourlyData[hour]!;
                  final passTotal = data[1]! + data[3]!; // Combined pass count
                  final total = data.values.reduce((a, b) => a + b);
                  return DataRow(cells: [
                    DataCell(Text(hour)),
                    DataCell(Text(passTotal.toString())),
                    DataCell(Text(data[2].toString())),
                    DataCell(Text(data[4].toString())),
                    DataCell(Text(total.toString())),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HourlyData {
  final String hour;
  final int count;
  final int status;

  HourlyData({
    required this.hour,
    required this.count,
    required this.status,
  });
}