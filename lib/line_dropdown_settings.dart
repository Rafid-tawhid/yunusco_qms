import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/home_screen.dart';
import 'package:nidle_qty/login_screen.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchDropdownScreen extends StatefulWidget {
  const SearchDropdownScreen({super.key});

  @override
  State<SearchDropdownScreen> createState() => _SearchDropdownScreenState();
}

class _SearchDropdownScreenState extends State<SearchDropdownScreen> {
  SearchFieldListItem<Map<String, dynamic>>? selectedSection;
  SearchFieldListItem<Map<String, dynamic>>? selectedLine;
  late SharedPreferences _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _getAllSections();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() => _isLoading = false);
  }

  void _getAllSections() {
    context.read<BuyerProvider>().getAllSections();
  }

  Widget _buildSuggestionItem(String text, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(isSelected ? Icons.check_circle : Icons.list, color: isSelected ? Colors.green : Colors.grey[600], size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.deepPurple : Colors.black87))),
        ],
      ),
    );
  }

  Future<void> _saveSelections() async {
    if (selectedSection != null && selectedLine != null) {
      await _prefs.setString('selectedSection', selectedSection!.item!['unitName']);
      await _prefs.setString('selectedSectionId', selectedSection!.item!['unitID'].toString());
      await _prefs.setString('selectedLine', selectedLine!.item!['name']);
      await _prefs.setString('selectedLineId', selectedLine!.item!['lineId'].toString());
      DashboardHelpers.setString('section', selectedSection!.item!['unitName']);
      DashboardHelpers.setString('line', selectedLine!.item!['name']);
      //get Lunch time
      var cp=context.read<CountingProvider>();
      cp.getLunchTimeBySectionId(selectedSection!.item!['unitID'].toString());
    }
  }

  Future<void> _loadSelections() async {
    final sectionName = _prefs.getString('selectedSection');
    final lineName = _prefs.getString('selectedLine');

    if (sectionName != null) {
      final sections = context.read<BuyerProvider>().allSection;
      final section = sections.firstWhere((s) => s['unitName'] == sectionName, orElse: () => {});

      if (section.isNotEmpty) {
        selectedSection = SearchFieldListItem(section['unitName'], item: section);

        await context.read<BuyerProvider>().getAllLinesBySectionId(_prefs.getString('selectedSectionId') ?? section['unitID'].toString());

        if (lineName != null) {
          final lines = context.read<BuyerProvider>().allLines;
          final line = lines.firstWhere((l) => l['name'] == lineName, orElse: () => {});

          if (line.isNotEmpty) {
            selectedLine = SearchFieldListItem(line['name'], item: line);
          }
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedSection == null && selectedLine == null) {
        _loadSelections();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Section & Line Selection'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Selections',
            onPressed: () async {
              DashboardHelpers.clearUser();
              await _prefs.remove('selectedSection');
              await _prefs.remove('selectedLine');
              setState(() {
                selectedSection = null;
                selectedLine = null;
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Dropdown
            Text('Select Section'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Consumer<BuyerProvider>(
                  builder: (context, provider, _) {
                    return SearchField<Map<String, dynamic>>(
                      hint: 'Search section...',
                      searchInputDecoration: SearchInputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type to search sections',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      maxSuggestionsInViewPort: 6,
                      suggestionsDecoration: SuggestionDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)],
                      ),
                      itemHeight: 60,
                      onSuggestionTap: (section) async {
                        setState(() {
                          selectedSection = section;
                          selectedLine = null;
                        });
                        await provider.getAllLinesBySectionId(section.item!['unitID'].toString());
                        await _saveSelections();
                      },
                      suggestions:
                          provider.allSection.map((section) {
                            return SearchFieldListItem(
                              section['unitName'],
                              item: section,
                              child: _buildSuggestionItem(section['unitName'], isSelected: selectedSection?.item?['unitName'] == section['unitName']),
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Line Dropdown
            Text('Select Line'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Consumer<BuyerProvider>(
                  builder: (context, provider, _) {
                    return SearchField<Map<String, dynamic>>(
                      hint: selectedSection != null ? 'Search line in ${selectedSection!.item!['unitName']}...' : 'Select section first...',
                      searchInputDecoration: SearchInputDecoration(border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey[600]), contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
                      maxSuggestionsInViewPort: 6,
                      suggestionsDecoration: SuggestionDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)],
                      ),
                      itemHeight: 60,
                      onSuggestionTap: (line) async {
                        setState(() => selectedLine = line);
                        await _saveSelections();
                      },
                      suggestions:
                          provider.allLines.map((line) {
                            return SearchFieldListItem(line['name'], item: line, child: _buildSuggestionItem(line['name'], isSelected: selectedLine?.item?['name'] == line['name']));
                          }).toList(),
                      enabled: selectedSection != null,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Selection Display
            if (selectedSection != null && selectedLine != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.deepPurple.withOpacity(0.3), width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SELECTED:', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    _buildSelectionRow(Icons.category, 'Section:', selectedSection!.item!['unitName']),
                    const SizedBox(height: 8),
                    _buildSelectionRow(Icons.line_style, 'Line:', selectedLine!.item!['name']),
                    const SizedBox(height: 8),
                    Consumer<CountingProvider>(
                      builder:
                          (context, pro, _) =>
                              pro.lunchTime == null
                                  ? SizedBox.shrink()
                                  : _buildSelectionRow(
                                    Icons.emoji_food_beverage_sharp,
                                    'Lunch:',
                                    DashboardHelpers.formatExactLunchTime(pro.lunchTime!['lunchStartTime'], pro.lunchTime!['lunchEndTime']),
                                  ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Add your submit action here
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => HomeScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('CONFIRM SELECTION', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
