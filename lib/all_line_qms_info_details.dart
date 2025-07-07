

import 'package:flutter/material.dart';
import 'package:nidle_qty/models/hourly_production_data_model.dart';

class AllLineQmsInfoDetails extends StatefulWidget {
  final List<HourlyProductionDataModel> productionData;

  const AllLineQmsInfoDetails({Key? key, required this.productionData}) : super(key: key);

  @override
  _AllLineQmsInfoDetailsState createState() => _AllLineQmsInfoDetailsState();
}

class _AllLineQmsInfoDetailsState extends State<AllLineQmsInfoDetails> {
  late List<HourlyProductionDataModel> filteredData;
  String? selectedTimeRange;
  int? selectedLineId;

  @override
  void initState() {
    super.initState();
    filteredData = widget.productionData;
  }

  @override
  Widget build(BuildContext context) {
    final summary = _calculateSummary();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Production Line Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Summary Cards
              _buildSummaryCards(summary),
              const SizedBox(height: 20),

              // Filters
              _buildFilters(),
              const SizedBox(height: 20),

              // Data Table
              _buildDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryCard(
            title: 'Total Passed',
            value: summary['totalPass'].toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            title: 'Total Alter',
            value: summary['totalAlteration'].toString(),
            icon: Icons.autorenew,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            title: 'Total Rejects',
            value: summary['totalReject'].toString(),
            icon: Icons.highlight_off,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            title: 'Efficiency',
            value: '${summary['efficiency'].toStringAsFixed(2)}%',
            icon: Icons.assessment,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final timeRanges = widget.productionData
        .map((e) => e.timeRange)
        .toSet()
        .toList();

    final lineIds = widget.productionData
        .map((e) => e.lineId)
        .toSet()
        .toList();

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedTimeRange,
          decoration: InputDecoration(
            labelText: 'Time Range',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All Time Ranges'),
            ),
            ...timeRanges.map((range) {
              return DropdownMenuItem(
                value: range,
                child: Text(range ?? ''),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              selectedTimeRange = value;
              _applyFilters();
            });
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: selectedLineId,
          decoration: InputDecoration(
            labelText: 'Line ID',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All Lines'),
            ),
            ...lineIds.map((lineId) {
              return DropdownMenuItem(
                value: lineId!.toInt(),
                child: Text(getLineName(lineId.toInt())),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              selectedLineId = value;
              _applyFilters();
            });
          },
        ),
      ],
    );
  }
  String getLineName(int lineNumber) {
    final lineMapping = {
      9: 'A-01',
      10: 'A-02',
      12: 'A-04',
      13: 'A-05',
      15: 'A-07',
      16: 'A-08',
      17: 'A-09',
      18: 'A-10',
    };

    return lineMapping[lineNumber] ?? lineNumber.toString();
  }
  void _applyFilters() {
    setState(() {
      filteredData = widget.productionData.where((data) {
        final timeMatch = selectedTimeRange == null ||
            data.timeRange == selectedTimeRange;
        final lineMatch = selectedLineId == null ||
            data.lineId == selectedLineId;
        return timeMatch && lineMatch;
      }).toList();
    });
  }

  Widget _buildDataTable() {
    return Card(
      color: Colors.white,
      elevation: 3,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Time Range')),
            DataColumn(label: Text('Line ID'), numeric: true),
            DataColumn(label: Text('Style')),
            DataColumn(label: Text('PO')),
            DataColumn(label: Text('Pass'), numeric: true),
            DataColumn(label: Text('Alter'), numeric: true),
            DataColumn(label: Text('Reject'), numeric: true),
            DataColumn(label: Text('Total'), numeric: true),
            DataColumn(label: Text('Efficiency')),
          ],
          rows: filteredData.map((data) {
            final efficiency = data.totalRecords! > 0
                ? (data.pass! / data.totalRecords! * 100)
                : 0.0;

            return DataRow(cells: [
              DataCell(Text(data.timeRange ?? '')),
              DataCell(Text(getLineName(data.lineId!.toInt()))),
              DataCell(Text(data.style ?? '')),
              DataCell(Text(data.po ?? '')),
              DataCell(Text(data.pass.toString())),
              DataCell(Text(data.alteration.toString())),
              DataCell(Text(data.reject.toString())),
              DataCell(Text(data.totalRecords.toString())),
              DataCell(Text('${efficiency.toStringAsFixed(2)}%')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateSummary() {
    int totalPass = 0;
    int totalAlteration = 0;
    int totalReject = 0;
    int totalRecords = 0;
    double efficiency = 0.0;

    for (var data in filteredData) {
      totalPass += data.pass!.toInt();
      totalAlteration += data.alteration!.toInt();
      totalReject += data.reject!.toInt();
      totalRecords += data.totalRecords!.toInt();
    }

    if (totalRecords > 0) {
      efficiency = (totalPass / totalRecords) * 100;
    }

    return {
      'totalPass': totalPass,
      'totalAlteration': totalAlteration,
      'totalReject': totalReject,
      'efficiency': efficiency,
    };
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 150,
      child: Card(
        color: Colors.white,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(icon, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}