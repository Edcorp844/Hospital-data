import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/main.dart';
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
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Remove the date from titles
    final titlesWithoutDate = List.of(widget.titles); // Create a copy to modify
    titlesWithoutDate.removeAt(0); // Assuming the date is the first item

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        border: null, // Remove the default bottom border
        previousPageTitle: 'Back',

        middle: Text(widget.date),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Text('Report', style: actionsTextStyle),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            ClipRRect(
              child: Container(
                  padding: const EdgeInsets.all(16),
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  child: Row(
                      children: titlesWithoutDate
                          .sublist(0, (titlesWithoutDate.length / 2).floor())
                          .map((title) => Row(
                                children: [
                                  Text(title.toString()),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              ))
                          .toList())),
            ),
            Expanded(
              child: CupertinoScrollbar(
                thumbVisibility: true,
                thicknessWhileDragging: 6,
                radiusWhileDragging: const Radius.circular(10),
                controller: scrollController,
                child: SingleChildScrollView(
                  child: Column(children: [
                    for (List row in widget.data) ...[
                      Container(
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 16,
                        ),
                        child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Text(
                                '${row[0] ?? ''}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 2,
                              height: 20,
                              decoration:
                                  BoxDecoration(color: context.primaryColor),
                            ),
                            const SizedBox(width: 10), // Optional spacing
                            Expanded(
                              // This ensures the last Container takes up remaining space
                              child: CupertinoContextMenu(
                                actions: [
                                  CupertinoContextMenuAction(
                                    trailingIcon: CupertinoIcons.phone,
                                    onPressed: () {
                                      debugPrint('Call button pressed');
                                      context.pop();
                                    },
                                    child: const Text('Call'),
                                  ),
                                  CupertinoContextMenuAction(
                                    trailingIcon: CupertinoIcons.doc_on_doc,
                                    onPressed: () {
                                      debugPrint('Call button pressed');
                                      context.pop();
                                    },
                                    child: const Text('Copy'),
                                  ),
                                  CupertinoContextMenuAction(
                                    trailingIcon: CupertinoIcons.pencil_circle,
                                    onPressed: () {
                                      debugPrint('Call button pressed');
                                      context.pop();
                                    },
                                    child: const Text('Edit'),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 8,
                                    bottom: 8,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10)),
                                      color: CupertinoDynamicColor.maybeResolve(
                                          const CupertinoDynamicColor
                                              .withBrightness(
                                              color: CupertinoColors
                                                  .lightBackgroundGray,
                                              darkColor: CupertinoColors
                                                  .darkBackgroundGray),
                                          context)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Aligns content to the start
                                    children: [
                                      Text(
                                        '${row[1] ?? ''}',
                                        style: const TextStyle(
                                            color: CupertinoColors.systemPink),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${row[2] ?? ''}',
                                        style: const TextStyle(
                                            color:
                                                CupertinoColors.systemPurple),
                                      ),
                                      const SizedBox(height: 5),
                                      Text('${row[3] ?? ''}',
                                          style: const TextStyle(
                                              color:
                                                  CupertinoColors.systemBlue)),
                                      const SizedBox(height: 5),
                                      Text('${row[4] ?? ''}'),
                                      const SizedBox(height: 5),
                                      Text(
                                          (row[5] == 'Yes' || row[5] == 'YES')
                                              ? 'Soul won'
                                              : 'Was Already Born Again',
                                          style: const TextStyle(
                                              color:
                                                  CupertinoColors.systemGreen)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ]),
                ),
              ),
            )
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
