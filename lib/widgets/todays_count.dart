import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodayQualitySummary extends StatelessWidget {
  const TodayQualitySummary({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('qms')
              .where('check_time', isGreaterThan: startOfDay.toIso8601String())
              .where('check_time', isLessThan: endOfDay.toIso8601String())
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        int passed = 0;
        int rejected = 0;
        int altered = 0;

        for (var doc in snapshot.data!.docs) {
          final status = (doc['status'] as String?)?.toLowerCase();
          if (status == 'pass') {
            passed++;
          } else if (status == 'reject') {
            rejected++;
          } else if (status == 'alter') {
            altered++;
          }
        }

        final total = passed + rejected + altered;
        final passRate =
            total > 0 ? (passed / total * 100).toStringAsFixed(1) : '0.0';

        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Today\'s Quality Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Passed', passed, Colors.green),
                    _buildStatItem('Rejected', rejected, Colors.red),
                    _buildStatItem('Altered', altered, Colors.orange),
                    _buildStatItem('Pass Rate', '$passRate%', Colors.blue),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Inspected: $total',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, dynamic value, Color color) {
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: FittedBox(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
