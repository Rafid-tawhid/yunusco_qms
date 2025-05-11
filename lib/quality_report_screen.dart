import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nidle_qty/widgets/todays_count.dart';
class QualityReportScreen extends StatefulWidget {
  const QualityReportScreen({super.key});

  @override
  _QualityReportScreenState createState() => _QualityReportScreenState();
}

class _QualityReportScreenState extends State<QualityReportScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedSection = 'All';
  List<String> _sections = ['All'];

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('qms')
          .get();

      // Extract unique section IDs - ensure this matches your Firestore field name
      final sections = snapshot.docs
          .map((doc) => doc['section_id'] as String?) // Change to your actual field name
          .where((section) => section != null)
          .toSet()
          .toList();

      setState(() {
        _sections = ['All', ...sections.cast<String>()];
      });
    } catch (e) {
      debugPrint('Error loading sections: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load sections: ${e.toString()}'))
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quality Inspection Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          TodayQualitySummary(),
          _buildFilters(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildReportData(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            DateFormat('MMMM d, yyyy').format(_selectedDate),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedSection,
            items: _sections.map((section) {
              return DropdownMenuItem<String>(
                value: section,
                child: Text(section),
              );
            }).toList(),
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _selectedSection = value!;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportData() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('qms')
          .where('check_time', isGreaterThan: _selectedDate.startOfDay.toIso8601String())
          .where('check_time', isLessThan: _selectedDate.endOfDay.toIso8601String())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No quality checks found for selected date',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final data = snapshot.data!.docs;
        debugPrint('Fetched ${data.length} documents');

        // Group data by hour
        final hourlyData = <String, Map<String, int>>{};
        for (var doc in data) {
          try {
            final checkData = doc.data() as Map<String, dynamic>;
            debugPrint('Processing document: ${doc.id} - $checkData');

            final sectionId = checkData['section_id'] as String? ?? '';
            final checkTime = checkData['check_time'] as String?;
            final status = checkData['status'] as String?;

            if (checkTime == null || status == null) {
              debugPrint('Skipping document with missing fields');
              continue;
            }

            // Filter by selected section
            if (_selectedSection != 'All' && sectionId != _selectedSection) {
              continue;
            }

            final hourKey = DateFormat('H:00').format(DateTime.parse(checkTime));

            hourlyData.putIfAbsent(hourKey, () => {
              'pass': 0,
              'reject': 0,
              'alter': 0,
              'total': 0,
            });

            if (status.toLowerCase() == 'pass') {
              hourlyData[hourKey]!['pass'] = hourlyData[hourKey]!['pass']! + 1;
            } else if (status.toLowerCase() == 'reject') {
              hourlyData[hourKey]!['reject'] = hourlyData[hourKey]!['reject']! + 1;
            } else if (status.toLowerCase() == 'alter') {
              hourlyData[hourKey]!['alter'] = hourlyData[hourKey]!['alter']! + 1;
            }

            hourlyData[hourKey]!['total'] = hourlyData[hourKey]!['total']! + 1;
          } catch (e) {
            debugPrint('Error processing document ${doc.id}: $e');
          }
        }

        if (hourlyData.isEmpty) {
          return const Center(
            child: Text(
              'No matching records found for selected filters',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Sort hours chronologically
        final sortedHours = hourlyData.keys.toList()
          ..sort((a, b) => a.compareTo(b));

        return ListView.builder(
          itemCount: sortedHours.length,
          itemBuilder: (context, index) {
            final hour = sortedHours[index];
            final stats = hourlyData[hour]!;
            final passRate = stats['total']! > 0
                ? (stats['pass']! / stats['total']! * 100).toStringAsFixed(1)
                : '0.0';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$hour - ${(int.parse(hour.split(':')[0]) + 1)}:00',
                      style: const TextStyle(
                      fontWeight: FontWeight.bold,
                          fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Passed', stats['pass']!, Colors.green),
                        _buildStatItem('Rejected', stats['reject']!, Colors.red),
                        _buildStatItem('Altered', stats['alter']!, Colors.orange),
                        _buildStatItem('Pass Rate', '$passRate%', Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, dynamic value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}