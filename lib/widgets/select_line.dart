import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:provider/provider.dart';

class SelectLine extends StatefulWidget {
  final String sectionId;

  const SelectLine({required this.sectionId, Key? key}) : super(key: key);

  @override
  _ItemSelectionWidgetState createState() => _ItemSelectionWidgetState();
}

class _ItemSelectionWidgetState extends State<SelectLine> {
  int? selectedIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final bp = context.read<BuyerProvider>();
    await bp.getAllLinesBySectionId(widget.sectionId);
    await getPreviousSelectedLines();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Line'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select an Item:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildListContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildListContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Consumer<BuyerProvider>(
        builder: (context, provider, _) {
          if (provider.allLines.isEmpty) {
            //set current line empty
            DashboardHelpers.setString('line', '');
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No lines available', textAlign: TextAlign.center),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.allLines.length,
            itemBuilder: (context, index) {
              final item = provider.allLines[index];
              final isSelected = selectedIndex == index;

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    item['name'] ?? 'No Name',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'Line: ${item['lineId']}, Section: ${item['sectionId']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  leading: Radio<int>(
                    value: index,
                    groupValue: selectedIndex,
                    onChanged: (int? value) => _handleSelection(value, item),
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                  ),
                  tileColor: isSelected ? Colors.blue.shade50 : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onTap: () => _handleSelection(index, item),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleSelection(int? index, Map<String, dynamic> item) {
    setState(() => selectedIndex = index);
    DashboardHelpers.setString('line', item['name']);
    Navigator.pop(context,item);
  }

  Future<void> getPreviousSelectedLines() async {
    var line = await DashboardHelpers.getString('line');
    debugPrint('line $line');
    var bp = context.read<BuyerProvider>();

    for (var e in bp.allLines) {
      if (e['name'] == line) {
        setState(() {
          selectedIndex = bp.allLines.indexOf(e);
        });
        break;
      }
    }
  }
}
