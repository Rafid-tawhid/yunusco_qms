import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/buyer_provider.dart';
import 'package:nidle_qty/utils/dashboard_helpers.dart';
import 'package:nidle_qty/widgets/select_line.dart';
import 'package:provider/provider.dart';

class LineSettingScreen extends StatefulWidget {
  const LineSettingScreen({super.key});

  @override
  State<LineSettingScreen> createState() => _LineSettingScreenState();
}

class _LineSettingScreenState extends State<LineSettingScreen> {

  String? selectedSection;
  String? selectedLine;
  bool isLoading = true;

  @override
  void initState() {
    _loadselectedSection();
    _getAllSections();
    super.initState();
  }
  Future<void> _loadselectedSection() async {
    var name=await DashboardHelpers.getString('selectedSection');
    var line = await DashboardHelpers.getString('line');
    setState(() {
      selectedSection = name;
      selectedLine=line;
      isLoading = false;
    });
  }

  Future<void> _saveselectedSection(String name,String id) async {
    DashboardHelpers.setString('selectedSection', name);
    setState(() {
      selectedSection = name;
    });
    Navigator.push(context, CupertinoPageRoute(builder: (context)=>SelectLine(sectionId: id))).then((v){
      debugPrint('Selected Line $v');
      if(v['name']!=null){
        setState(() {
          selectedLine=v['name']??'';
        });
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Section'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Current Selection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Section: ',style: TextStyle(fontSize: 16,color: Colors.blue,fontWeight: FontWeight.bold),),
                        Text(
                          selectedSection==''? 'None':selectedSection??'',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedSection == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        Spacer(),
                        Text('Line: ',style: TextStyle(fontSize: 16,color: Colors.blue,fontWeight: FontWeight.bold),),
                        Text(
                          selectedLine==''? 'None':selectedLine??'',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedLine == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Available Sections',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<BuyerProvider>(
              builder: (context,pro,_)=>Expanded(
                child: ListView.separated(
                  itemCount: pro.allSection.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final name = pro.allSection[index]['unitName'] as String;
                    final id = pro.allSection[index]['unitID'].toString();
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: selectedSection == name
                          ? Colors.blue.withOpacity(0.1)
                          : null,
                      child: ListTile(
                        title: Text(
                          'Section : ${name}',
                          style: TextStyle(
                            fontWeight: selectedSection == name
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: selectedSection == name
                            ? const Icon(Icons.check_circle,
                            color: Colors.green)
                            : null,
                        onTap: () => _saveselectedSection(name,id),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getAllSections() async{
    var bp=context.read<BuyerProvider>();
    if(bp.allSection.isEmpty){
      bp.getAllSections();
    }
  }
}
