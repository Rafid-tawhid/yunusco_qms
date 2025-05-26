import 'package:flutter/material.dart';

import '../models/hourly_production_data_model.dart';

class HourlyProductionDashboard extends StatelessWidget {
  final List<HourlyProductionDataModel> productionData;

  const HourlyProductionDashboard({Key? key, required this.productionData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Production Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[50]!,
              Colors.blueGrey[100]!,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildSummaryCards(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildDataTable(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalPass = productionData.fold(0, (sum, item) => sum + (item.pass ?? 0).toInt());
    final totalReject = productionData.fold(0, (sum, item) => sum + (item.reject ?? 0).toInt());
    final totalAlteration = productionData.fold(0, (sum, item) => sum + (item.alteration ?? 0).toInt());
    final totalRecords = productionData.fold(0, (sum, item) => sum + (item.totalRecords ?? 0).toInt());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildStatCard('Total Passed', totalPass, Colors.green),
          _buildStatCard('Total Rejected', totalReject, Colors.red),
          _buildStatCard('Total Alterations', totalAlteration, Colors.orange),
          _buildStatCard('Total Records', totalRecords, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.7),
              color.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 12,
        headingRowColor: MaterialStateProperty.resolveWith<Color>(
              (states) => Colors.blueGrey[800]!.withOpacity(0.8),
        ),
        columns: const [
          DataColumn(label: Text('Time', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Line', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Buyer', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('PO', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Style', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Pass', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Alter', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Reject', style: TextStyle(color: Colors.white))),
          DataColumn(label: Text('Total', style: TextStyle(color: Colors.white))),
        ],
        rows: productionData.map((data) {
          return DataRow(
            cells: [
              DataCell(Text(data.timeRange ?? '-', style: _cellStyle())),
              DataCell(Text(data.lineId?.toString() ?? '-', style: _cellStyle())),
              DataCell(Text(data.buyerName ?? '-', style: _cellStyle())),
              DataCell(Text(data.po ?? '-', style: _cellStyle())),
              DataCell(Text(data.style ?? '-', style: _cellStyle())),
              DataCell(Text(data.pass?.toString() ?? '-',
                  style: _cellStyle(color: Colors.green[700]))),
              DataCell(Text(data.alteration?.toString() ?? '-',
                  style: _cellStyle(color: Colors.orange[700]))),
              DataCell(Text(data.reject?.toString() ?? '-',
                  style: _cellStyle(color: Colors.red[700]))),
              DataCell(Text(data.totalRecords?.toString() ?? '-',
                  style: _cellStyle(fontWeight: FontWeight.bold))),
            ],
          );
        }).toList(),
      ),
    );
  }

  TextStyle _cellStyle({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      color: color ?? Colors.blueGrey[800],
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}