import 'package:flutter/material.dart';
import 'package:nidle_qty/models/hourly_production_data_model.dart';

class AllLineQmsInfoDetails extends StatefulWidget {
  final List<HourlyProductionDataModel> productionData;

  const AllLineQmsInfoDetails({Key? key, required this.productionData})
    : super(key: key);

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
            title: 'Alter',
            value: summary['alter'].toString(),
            icon: Icons.autorenew,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            title: 'Alter Check',
            value: summary['alterCheck'].toString(),
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
    final timeRanges =
        widget.productionData.map((e) => e.timeRange).toSet().toList();

    final lineIds = widget.productionData.map((e) => e.lineId).toSet().toList();

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedTimeRange,
          decoration: InputDecoration(
            labelText: 'Time Range',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Time Ranges')),
            ...timeRanges.map((range) {
              return DropdownMenuItem(value: range, child: Text(range ?? ''));
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
            const DropdownMenuItem(value: null, child: Text('All Lines')),
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
      1: 'A',
      2: 'ABC',
      3: 'ment',
      4: 'an-1',
      5: 'an-2',
      6: 'mber',
      7: 'Head',
      8: '0',
      9: 'A-01',
      10: 'A-02',
      11: 'A-03',
      12: 'A-04',
      13: 'A-05',
      14: 'A-06',
      15: 'A-07',
      16: 'A-08',
      17: 'A-09',
      18: 'A-10',
      19: 'B-01',
      20: 'B-02',
      21: 'B-03',
      22: 'B-04',
      23: 'B-05',
      24: 'B-06',
      25: 'B-07',
      26: 'B-08',
      27: 'B-09',
      28: 'B-10',
      29: 'A-11',
      30: 'A-12',
      31: 'A-13',
      32: 'C-01',
      33: 'C-02',
      34: 'C-03',
      35: 'C-04',
      36: 'C-05',
      37: 'C-06',
      38: 'C-07',
      39: 'C-08',
      40: 'C-09',
      41: 'C-10',
      42: 'C-11',
      43: 'B-11',
      44: 'D-01',
      45: 'D-02',
      46: 'D-03',
      47: 'D-04',
      48: 'D-05',
      49: 'D-06',
      50: 'D-07',
      51: 'D-08',
      52: 'D-09',
      53: 'D-10',
      54: 'D-11',
      55: 'E-01',
      57: 'E-02',
      58: 'E-03',
      59: 'E-04',
      60: 'E-05',
      61: 'E-06',
      62: 'E-07',
      63: 'E-08',
      64: 'E-09',
      65: 'E-10',
      66: 'E-11',
      67: 'F-01',
      68: 'F-02',
      69: 'F-03',
      70: 'F-04',
      71: 'F-05',
      72: 'F-06',
      73: 'F-07',
      74: 'F-08',
      75: 'F-09',
      76: 'F-10',
      77: 'F-11',
      78: 'F-12',
      79: 'G-01',
      80: 'G-02',
      81: 'G-03',
      82: 'G-04',
      83: 'G-05',
      84: 'G-06',
      85: 'G-07',
      86: 'G-08',
      87: 'G-09',
      88: 'G-10',
      89: 'G-11',
      90: 's-01',
      91: 'H-01',
      92: 'H-02',
      93: 'H-03',
      94: 'H-04',
      95: 'H-05',
      96: 'H-06',
      97: 'H-07',
      98: 'H-08',
      99: 'H-09',
      100: 'H-10',
      101: 'H-11',
      102: 'I-01',
      103: 'I-02',
      104: 'I-03',
      105: 'I-04',
      106: 'I-05',
      107: 'I-06',
      108: 'I-07',
      109: 'I-08',
      110: 'I-09',
      111: 'I-10',
      112: 'I-11',
      113: 'J-01',
      114: 'J-02',
      115: 'J-03',
      116: 'J-04',
      117: 'J-05',
      118: 'J-06',
      119: 'J-07',
      120: 'J-08',
      121: 'J-09',
      122: 'J-10',
      123: 'J-11',
      146: 'K-01',
      147: 'K-02',
      148: 'K-03',
      150: 'K-04',
      155: 'K-05',
      156: 'K-06',
      157: 'K-08',
      158: 'K-07',
      159: 'K-09',
      160: 'K-10',
      161: 'K-11',
      162: 'I-12',
      163: 'G-12',
      164: 'Cutting',
      165: 'N/A',
    };

    return lineMapping[lineNumber] ?? lineNumber.toString();
  }

  void _applyFilters() {
    setState(() {
      filteredData =
          widget.productionData.where((data) {
            final timeMatch =
                selectedTimeRange == null ||
                data.timeRange == selectedTimeRange;
            final lineMatch =
                selectedLineId == null || data.lineId == selectedLineId;
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
            DataColumn(label: Text('Alter Check'), numeric: true),
            DataColumn(label: Text('Reject'), numeric: true),
            DataColumn(label: Text('DHU')),
          ],
          rows:
              filteredData.map((data) {
                final efficiency = (data.alteration! / data.pass!) * 100;

                return DataRow(
                  cells: [
                    DataCell(Text(data.timeRange ?? '')),
                    DataCell(Text(getLineName(data.lineId!.toInt()))),
                    DataCell(Text(data.style ?? '')),
                    DataCell(Text(data.po ?? '')),
                    DataCell(Text(data.pass.toString())),
                    DataCell(Text(data.alteration.toString())),
                    DataCell(Text(data.alterCheck.toString())),
                    DataCell(Text(data.reject.toString())),
                    DataCell(Text('${efficiency.toStringAsFixed(2)}%')),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateSummary() {
    int totalPass = 0;
    int alter = 0;
    int alterCheck = 0;
    int totalReject = 0;
    int totalRecords = 0;
    double efficiency = 0.0;

    for (var data in filteredData) {
      totalPass += data.pass!.toInt();
      alter += data.alteration!.toInt();
      alterCheck += data.alterCheck!.toInt();
      totalReject += data.reject!.toInt();
      totalRecords += data.totalRecords!.toInt();
    }

    if (totalRecords > 0) {
      efficiency = (totalPass / totalRecords) * 100;
    }

    return {
      'totalPass': totalPass,
      'alter': alter,
      'alterCheck': alterCheck,
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
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
