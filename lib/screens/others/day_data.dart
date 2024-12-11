import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/utils/textstyles.dart';

class DayDataScreen extends StatefulWidget {
  final String date;
  final List<dynamic> data; // Assuming each dynamic item is a row
  final List<dynamic> titles;

  const DayDataScreen({
    super.key,
    required this.date,
    required this.data,
    required this.titles,
  });

  @override
  State<DayDataScreen> createState() => _DayDataScreenState();
}

class _DayDataScreenState extends State<DayDataScreen> {
  @override
  Widget build(BuildContext context) {
    // Remove the date from titles
    final titlesWithoutDate = List.of(widget.titles); // Create a copy to modify
    titlesWithoutDate.removeAt(0); // Assuming the date is the first item

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        border: null, // Remove the default bottom border
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Column(
          children: [
            ClipRRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  height: 40,
                  color: CupertinoTheme.of(context).barBackgroundColor,
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Other slivers go here
                ],
              ),
            ),
          ],
        ),
      ),

      /*  navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Back',
        middle: Text(widget.date),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color ??
                            CupertinoColors.systemGrey,
                    width: 1.0,
                  ),
                  columnWidths: {
                    for (int i = 0; i < titlesWithoutDate.length; i++)
                      i: const FixedColumnWidth(160.0),
                  },
                  children: [
                    // Header Row
                    TableRow(
                      children: titlesWithoutDate
                          .map((title) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  title.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                    ),
                    // Data Rows
                    ...widget.data.map((row) {
                      final rowData = List.generate(
                        titlesWithoutDate.length,
                        (index) =>
                            (index < row.length) ? row[index].toString() : '',
                      );
                      return TableRow(
                        children: rowData
                            .map((cell) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(cell),
                                ))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ), */
    );
  }
}
