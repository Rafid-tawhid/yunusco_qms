import 'package:flutter/material.dart';
import 'package:nidle_qty/models/defect_models.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:provider/provider.dart';

import 'models/checked_enum.dart';

class QualityCheckScreen extends StatefulWidget {
  final String form;

  QualityCheckScreen({required this.form});

  @override
  _QualityCheckScreenState createState() => _QualityCheckScreenState();
}

class _QualityCheckScreenState extends State<QualityCheckScreen> {
  int selectedOperationId = 1;
  final Map<int, Set<int>> selectedReasons = {};

  @override
  Widget build(BuildContext context) {
    final currentOperation = garmentQualityData['operations']!.firstWhere((op) => op['id'] == selectedOperationId);
    final reasons = currentOperation['reasons'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Garment Quality Check'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: Column(
        children: [
          // Header with garment info
          _buildGarmentHeader(),

          // Operations horizontal scroll
          _buildOperationsScroll(),

          // Reasons vertical scroll
          Expanded(child: _buildReasonsList(reasons)),

          // Submit button
          _buildSubmitButton(widget.form),
        ],
      ),
    );
  }

  Widget _buildGarmentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, border: Border(bottom: BorderSide(color: Colors.blue.shade100, width: 1))),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.checkroom, size: 40, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Style #: DRN-2024-056', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Color: Navy Blue | Size: M', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text('Order #: PO-98765', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsScroll() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: garmentQualityData['operations']!.length,
        itemBuilder: (context, index) {
          final operation = garmentQualityData['operations']![index];
          final isSelected = operation['id'] == selectedOperationId;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedOperationId = int.parse(operation['id'].toString());
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(operation['icon'].toString(), style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    operation['name'].toString(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReasonsList(List<Map<String, dynamic>> reasons) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: reasons.length,
          itemBuilder: (context, index) {
            final reason = reasons[index];
            final isSelected = (selectedReasons[selectedOperationId] ?? {}).contains(reason['id']);

            return CheckboxListTile(
              title: Text(reason['name']),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  selectedReasons.putIfAbsent(selectedOperationId, () => {});
                  if (value == true) {
                    selectedReasons[selectedOperationId]!.add(reason['id']);
                  } else {
                    selectedReasons[selectedOperationId]!.remove(reason['id']);
                  }
                });
              },
              secondary: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: isSelected ? Colors.red.shade100 : Colors.grey.shade100, shape: BoxShape.circle),
                child: Icon(Icons.warning, size: 16, color: isSelected ? Colors.red : Colors.grey),
              ),
              activeColor: Colors.red,
              checkColor: Colors.white,
              tileColor: isSelected ? Colors.red.shade50 : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String form) {
    final hasSelectedReasons = (selectedReasons[selectedOperationId] ?? {}).isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1))),
      child: ElevatedButton(
        onPressed:
            hasSelectedReasons
                ? () {
                  _showSubmissionDialog(widget.form);
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: const Text('REJECT WITH SELECTED ISSUES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _showSubmissionDialog(String form) async {
    final currentReasons = garmentQualityData['operations']!.firstWhere((op) => op['id'] == selectedOperationId)['reasons'] as List;
    final selectedNames = currentReasons.where((reason) => (selectedReasons[selectedOperationId] ?? {}).contains(reason['id'])).map<String>((reason) => reason['name'] as String).join(', ');

    debugPrint('from : ${form}');
    debugPrint('operation : ${currentReasons[0]['name']}');
    debugPrint('reasons : ${selectedNames}');
    var cp = context.read<CountingProvider>();
    if (form == CheckedStatus.alter) {
      cp.alterItem();
    } else {
      cp.rejectItem();
    }

    var bp = context.read<BuyerProvider>();
    var pro = context.read<CountingProvider>();

    await pro.saveDataToFirebase(bp, status: form,info: [
      DefectModels(
          defectId: currentReasons.indexOf('name'),
          defectName: selectedNames,
          operationName: currentReasons[0]['name']
      )
    ]);

    //set counting data locally
    pro.saveCountingDataLocally(bp,from: true,info: {
      'operation':currentReasons[0]['name'],
      'reasons':selectedNames
    });

    Navigator.pop(context, selectedReasons);
  }
}

final garmentQualityData = {
  "operations": [
    {
      "id": 1,
      "name": "Stitching",
      "icon": "🧵",
      "reasons": [
        {"id": 101, "name": "Broken stitch"},
        {"id": 102, "name": "Uneven stitch"},
        {"id": 103, "name": "Loose thread"},
        {"id": 104, "name": "Wrong stitch type"},
        {"id": 105, "name": "Missing stitch"},
      ],
    },
    {
      "id": 2,
      "name": "Fabric",
      "icon": "👕",
      "reasons": [
        {"id": 201, "name": "Hole in fabric"},
        {"id": 202, "name": "Color mismatch"},
        {"id": 203, "name": "Fabric defect"},
        {"id": 204, "name": "Wrong material"},
      ],
    },
    {
      "id": 3,
      "name": "Buttons",
      "icon": "🔘",
      "reasons": [
        {"id": 301, "name": "Missing button"},
        {"id": 302, "name": "Loose button"},
        {"id": 303, "name": "Wrong button"},
        {"id": 304, "name": "Button hole misaligned"},
      ],
    },
    {
      "id": 4,
      "name": "Zippers",
      "icon": "🤐",
      "reasons": [
        {"id": 401, "name": "Zipper stuck"},
        {"id": 402, "name": "Zipper missing"},
        {"id": 403, "name": "Zipper teeth broken"},
        {"id": 404, "name": "Slider defective"},
      ],
    },
    {
      "id": 5,
      "name": "Labels",
      "icon": "🏷️",
      "reasons": [
        {"id": 501, "name": "Missing label"},
        {"id": 502, "name": "Wrong label"},
        {"id": 503, "name": "Misplaced label"},
        {"id": 504, "name": "Illegible text"},
      ],
    },
  ],
};
