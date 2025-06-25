import 'package:flutter/material.dart';

import '../models/hourly_production_data_model.dart';

class HourlyProductionDashboard extends StatelessWidget {
  final List<HourlyProductionDataModel> productionData;

  const HourlyProductionDashboard({Key? key, required this.productionData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildDataTable(),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildDataTable() {
    // Calculate column widths based on content
    final columnWidths = {
      0: const FixedColumnWidth(100), // Time
      1: const FixedColumnWidth(60),  // Line
      2: const FixedColumnWidth(120), // Buyer
      3: const FixedColumnWidth(100), // PO
      4: const FlexColumnWidth(),     // Style (flexible)
      5: const FixedColumnWidth(60),  // Pass
      6: const FixedColumnWidth(60),  // Alter
      7: const FixedColumnWidth(60),  // Reject
      8: const FixedColumnWidth(60),  // Total
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              columnSpacing: 16,
              horizontalMargin: 8,
              headingRowColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => Colors.blueGrey[800]!.withOpacity(0.8),
              ),
              columns: const [
                DataColumn(label: Text('Time', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Line', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Buyer', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Style', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Pass', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Alter', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Check', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Reject', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Total', style: TextStyle(color: Colors.white))),
              ],
              rows: productionData.map((data) {
                return DataRow(
                  cells: [
                    DataCell(Text(data.timeRange ?? '-', style: _cellStyle())),
                    DataCell(Text(data.lineId?.toString() ?? '-', style: _cellStyle())),
                    DataCell(Text(data.buyerName ?? '-', style: _cellStyle())),

                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 200),
                        child: Text(
                          data.style ?? '-',
                          style: _cellStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(data.pass?.toString() ?? '-',
                        style: _cellStyle(color: Colors.green[700]))),
                    DataCell(Text(data.alteration?.toString() ?? '-', style: _cellStyle(color: Colors.orange[700]))),
                    DataCell(Text(data.alterCheck?.toString() ?? '-', style: _cellStyle(color: Colors.green[700]))),
                    DataCell(Text(data.reject?.toString() ?? '-',
                        style: _cellStyle(color: Colors.red[700]))),
                    DataCell(Text(data.totalRecords?.toString() ?? '-',
                        style: _cellStyle(fontWeight: FontWeight.bold))),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  TextStyle _cellStyle({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      color: color ?? Colors.blueGrey[800],
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}