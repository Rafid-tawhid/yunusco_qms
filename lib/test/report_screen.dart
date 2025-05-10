import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductionReportScreen extends StatefulWidget {
  final List<dynamic> productionData;

  const ProductionReportScreen({super.key, required this.productionData});

  @override
  _ProductionReportScreenState createState() => _ProductionReportScreenState();
}

class _ProductionReportScreenState extends State<ProductionReportScreen> {
  DateTimeRange? _selectedDateRange;
  String _selectedSection = 'All';
  String _selectedLine = 'All';

  @override
  void initState() {
    super.initState();
    // Set default range to last 7 days
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
  }

  @override
  Widget build(BuildContext context) {
    // Filter data based on selections
    final filteredData = _filterData();

    // Group data by hour
    final hourlyData = _groupByHour(filteredData);
    final defectData = _analyzeDefects(filteredData);

    return Scaffold(
      appBar: AppBar(title: const Text('Production Quality Report'), actions: [IconButton(icon: const Icon(Icons.filter_alt), onPressed: _showFilterDialog)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummaryCards(filteredData),

            const SizedBox(height: 24),
            const Text('Hourly Production', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildHourlyChart(hourlyData),

            const SizedBox(height: 24),
            const Text('Quality Defects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDefectChart(defectData),

            const SizedBox(height: 24),
            const Text('Detailed Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDataTable(filteredData),
          ],
        ),
      ),
    );
  }

  List<dynamic> _filterData() {
    return widget.productionData.where((item) {
      final time = DateTime.parse(item['time']);
      final matchesDate = _selectedDateRange == null || (time.isAfter(_selectedDateRange!.start) && time.isBefore(_selectedDateRange!.end));
      final matchesSection = _selectedSection == 'All' || item['secId'] == _selectedSection;
      final matchesLine = _selectedLine == 'All' || item['line'] == _selectedLine;
      return matchesDate && matchesSection && matchesLine;
    }).toList();
  }

  Map<String, dynamic> _groupByHour(List<dynamic> data) {
    final result = <String, dynamic>{};

    for (var item in data) {
      final time = DateTime.parse(item['time']);
      final hourKey = '${time.hour}:00-${time.hour + 1}:00';

      if (!result.containsKey(hourKey)) {
        result[hourKey] = {'passed': 0, 'reject': 0, 'alter': 0, 'count': 0};
      }

      final count = item['count'];
      result[hourKey]['passed'] += int.parse(count['passed']);
      result[hourKey]['reject'] += int.parse(count['reject']);
      result[hourKey]['alter'] += int.parse(count['alter']);
      result[hourKey]['count'] += 1;
    }

    return result;
  }

  Map<String, int> _analyzeDefects(List<dynamic> data) {
    final result = <String, int>{};

    for (var item in data) {
      final reasons = item['reasons'].toString().split(', ');
      for (var reason in reasons) {
        reason = reason.trim();
        if (reason.isNotEmpty) {
          result[reason] = (result[reason] ?? 0) + 1;
        }
      }
    }

    return result;
  }

  Widget _buildSummaryCards(List<dynamic> data) {
    int totalPassed = 0;
    int totalRejected = 0;
    int totalAltered = 0;
    int totalInspected = 0;

    for (var item in data) {
      final count = item['count'];
      totalPassed += int.parse(count['passed']);
      totalRejected += int.parse(count['reject']);
      totalAltered += int.parse(count['alter']);
      totalInspected += 1;
    }

    final rejectionRate = totalInspected > 0 ? (totalRejected / (totalPassed + totalRejected + totalAltered) * 100) : 0;

    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Passed', totalPassed.toString(), Colors.green, Icons.check_circle)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Rejected', totalRejected.toString(), Colors.red, Icons.cancel)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Altered', totalAltered.toString(), Colors.orange, Icons.build)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Rejection Rate', '${rejectionRate.toStringAsFixed(1)}%', Colors.blue, Icons.analytics)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart(Map<String, dynamic> hourlyData) {
    final chartData =
        hourlyData.entries.map((entry) {
          return {'hour': entry.key, 'passed': entry.value['passed'], 'rejected': entry.value['reject'], 'altered': entry.value['alter']};
        }).toList();

    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <CartesianSeries>[
          StackedColumnSeries<Map<String, dynamic>, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data['hour'],
            yValueMapper: (data, _) => data['passed'],
            name: 'Passed',
            color: Colors.green,
          ),
          StackedColumnSeries<Map<String, dynamic>, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data['hour'],
            yValueMapper: (data, _) => data['rejected'],
            name: 'Rejected',
            color: Colors.red,
          ),
          StackedColumnSeries<Map<String, dynamic>, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data['hour'],
            yValueMapper: (data, _) => data['altered'],
            name: 'Altered',
            color: Colors.orange,
          ),
        ],
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildDefectChart(Map<String, int> defectData) {
    final chartData = defectData.entries.map((e) => {'defect': e.key, 'count': e.value}).toList();

    // Sort by count descending
    chartData.sort((a, b) => int.parse((b['count'] ?? 0).toString()).compareTo(int.parse(a['count'].toString())));

    return SizedBox(
      height: 400,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(labelRotation: -45, labelIntersectAction: AxisLabelIntersectAction.rotate45),
        series: <CartesianSeries>[
          BarSeries<Map<String, dynamic>, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data['defect'],
            yValueMapper: (data, _) => data['count'],
            name: 'Defects',
            color: Colors.red,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  Widget _buildDataTable(List<dynamic> filteredData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Section')),
          DataColumn(label: Text('Line')),
          DataColumn(label: Text('Passed'), numeric: true),
          DataColumn(label: Text('Rejected'), numeric: true),
          DataColumn(label: Text('Altered'), numeric: true),
          DataColumn(label: Text('Defects')),
        ],
        rows:
            filteredData.map((item) {
              final count = item['count'];
              return DataRow(
                cells: [
                  DataCell(Text(DateFormat('HH:mm').format(DateTime.parse(item['time'])))),
                  DataCell(Text(item['secId'])),
                  DataCell(Text(item['line'])),
                  DataCell(Text(count['passed'])),
                  DataCell(Text(count['reject'])),
                  DataCell(Text(count['alter'])),
                  DataCell(Text(item['reasons'].toString())),
                ],
              );
            }).toList(),
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    final sections = widget.productionData.map((e) => e['secId'].toString()).toSet().toList();
    final lines = widget.productionData.map((e) => e['line'].toString()).toSet().toList();

    final now = DateTime.now();
    final initialDateRange = _selectedDateRange ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String section = _selectedSection;
        String line = _selectedLine;
        DateTimeRange dateRange = initialDateRange;

        return AlertDialog(
          title: const Text('Filter Report'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Date Range'),
                  subtitle: Text(
                    '${DateFormat('MMM d, y').format(dateRange.start)} - '
                    '${DateFormat('MMM d, y').format(dateRange.end)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2030), initialDateRange: dateRange);
                    if (picked != null) {
                      dateRange = picked;
                      Navigator.pop(context);
                      _showFilterDialog();
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: section,
                  items: [const DropdownMenuItem(value: 'All', child: Text('All Sections')), ...sections.map((sec) => DropdownMenuItem(value: sec, child: Text('Section $sec')))],
                  onChanged: (value) => section = value!,
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
                DropdownButtonFormField<String>(
                  value: line,
                  items: [const DropdownMenuItem(value: 'All', child: Text('All Lines')), ...lines.map((ln) => DropdownMenuItem(value: ln, child: Text('Line $ln')))],
                  onChanged: (value) => line = value!,
                  decoration: const InputDecoration(labelText: 'Line'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(context, {'dateRange': dateRange, 'section': section, 'line': line});
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedDateRange = result['dateRange'];
        _selectedSection = result['section'];
        _selectedLine = result['line'];
      });
    }
  }
}
