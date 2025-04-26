import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class DataHistoryScreen extends StatefulWidget {
  @override
  _DataHistoryScreenState createState() => _DataHistoryScreenState();
}

class _DataHistoryScreenState extends State<DataHistoryScreen> {
  String _timeRange = 'daily'; // 'hourly' or 'daily'
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Production Quality Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          DropdownButton<String>(
            value: _timeRange,
            items: ['hourly', 'daily'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _timeRange = value!;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCards(),
            SizedBox(height: 20),
            _buildTimeSeriesChart(),
            SizedBox(height: 20),
            SizedBox(height: 20),
            _buildRecentChecks(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildSummaryCard('Passed', 3245, Colors.green),
        _buildSummaryCard('Rejected', 128, Colors.red),
        _buildSummaryCard('Altered', 542, Colors.blue),
        _buildSummaryCard('Alt Check', 89, Colors.orange),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _timeRange == 'hourly'
                  ? 'Hourly Quality Trend (${DateFormat('MMM d').format(_selectedDate)})'
                  : 'Daily Quality Trend (${DateFormat('MMM y').format(_selectedDate)})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),

          ],
        ),
      ),
    );
  }




  Widget _buildRecentChecks() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Quality Checks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Table(
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  children: [
                    _buildTableHeader('Style'),
                    _buildTableHeader('Time'),
                    _buildTableHeader('Passed'),
                    _buildTableHeader('Reject'),
                    _buildTableHeader('Alter'),
                  ],
                ),
                ..._generateRecentCheckRows(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _generateRecentCheckRows() {
    return [
      _buildTableRow('JS84002-296295', '09:30 AM', 120, 5, 8),
      _buildTableRow('JS84002-56510', '10:15 AM', 95, 3, 6),
      _buildTableRow('ST161S-Black', '11:00 AM', 110, 8, 4),
      _buildTableRow('ST6476/ST161S', '11:45 AM', 85, 2, 5),
      _buildTableRow('ST6476/ST6476L', '12:30 PM', 102, 4, 7),
    ];
  }

  TableRow _buildTableRow(String style, String time, int passed, int reject, int alter) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(style),
        ),
        Text(time),
        Text(
          passed.toString(),
          style: TextStyle(color: Colors.green),
        ),
        Text(
          reject.toString(),
          style: TextStyle(color: Colors.red),
        ),
        Text(
          alter.toString(),
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}

class TimeSeriesData {
  final DateTime time;
  final int value;

  TimeSeriesData(this.time, this.value);
}

class QualityData {
  final String status;
  final int count;
  final Color color;

  QualityData(this.status, this.count, this.color);
}