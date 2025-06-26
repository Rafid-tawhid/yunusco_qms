import 'package:flutter/material.dart';
import 'package:nidle_qty/models/operation_defect_count_model.dart';

class DefectsDisplayWidget extends StatelessWidget {
  final List<OperationDefectCountModel> defects;

  const DefectsDisplayWidget({super.key, required this.defects});

  @override
  Widget build(BuildContext context) {
    // Group defects by operation name
    final Map<String, List<OperationDefectCountModel>> groupedDefects = {};
    for (var defect in defects) {
      groupedDefects.putIfAbsent(defect.operationName ?? '', () => []).add(defect);
    }

    // Sort operations by total defect count (descending)
    final sortedOperations =
        groupedDefects.entries.toList()..sort((a, b) {
          final aTotal = a.value.fold(0, (sum, defect) => sum + (defect.defectCount?.toInt() ?? 0));
          final bTotal = b.value.fold(0, (sum, defect) => sum + (defect.defectCount?.toInt() ?? 0));
          return bTotal.compareTo(aTotal);
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0,top: 12),
          child: Text('Defects Report',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
          
            itemCount: sortedOperations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final operation = sortedOperations[index];
              operation.value.sort((a, b) => (b.defectCount ?? 0).compareTo(a.defectCount ?? 0));
              final totalDefects = operation.value.fold(0, (sum, defect) => sum + (defect.defectCount?.toInt() ?? 0));
          
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(operation.key, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                            child: Text('Total: $totalDefects', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue[800])),
                          ),
                        ],
                      ),
                      //
                      const SizedBox(height: 4),
                      ...operation.value.map(
                            (defect) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text(defect.defectName ?? '', style: Theme.of(context).textTheme.bodyMedium)),
                              Chip(
                                label: Text(defect.defectCount.toString(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
                                backgroundColor: _getDefectColor(defect.defectCount?.toInt() ?? 0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                labelPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getDefectColor(int count) {
    if (count > 5) return Colors.red[400]!;
    if (count > 2) return Colors.orange[400]!;
    return Colors.green[400]!;
  }
}
