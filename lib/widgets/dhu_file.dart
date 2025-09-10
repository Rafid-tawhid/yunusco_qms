import 'package:flutter/material.dart';

import '../utils/constants.dart';

class SectionDataScreen extends StatelessWidget {
  final List<Map<String, dynamic>> sections;

  SectionDataScreen({required this.sections});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Section Wise DHU',style: customTextStyle(18, Colors.black, FontWeight.bold),),
        SizedBox(height: 12,),
        ListView.builder(
          itemCount: sections.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final section = sections[index];
            final sectionName = section['SectionName'] as String;
            final sectionDHU = section['SectionDHU'] as double;
            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorBasedOnDHU(sectionDHU),
                  child: Text(
                    sectionName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'Section $sectionName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text('DHU Value: $sectionDHU'),
                trailing: Text(
                    sectionDHU.toStringAsFixed(2),
                    style: customTextStyle(16, Colors.black, FontWeight.normal)
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getColorBasedOnDHU(double dhu) {
    if (dhu < 1) return Colors.green;
    if (dhu < 1.5) return Colors.orange;
    return Colors.red;
  }
}


class LineWiseDHU extends StatelessWidget {
  final List<Map<String, dynamic>> lines;

  LineWiseDHU({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Line Wise DHU',style: customTextStyle(18, Colors.black, FontWeight.bold),),
        SizedBox(height: 12,),
        ListView.builder(
          itemCount: lines.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final section = lines[index];
            final sectionName = section['LineName'] as String;
            final sectionDHU = section['LineDHU'] as double;
            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorBasedOnDHU(sectionDHU),
                  child: Text(
                    sectionName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'Section $sectionName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text('DHU Value: $sectionDHU'),
                trailing: Text(
                    sectionDHU.toStringAsFixed(2),
                    style: customTextStyle(16, Colors.black, FontWeight.normal)
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getColorBasedOnDHU(double dhu) {
    if (dhu < 0.5) return Colors.green;
    if (dhu < 1.0) return Colors.orange;
    return Colors.red;
  }
}