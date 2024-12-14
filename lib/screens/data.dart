import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/screens/others/add_data.dart';
import 'package:myapp/screens/others/day_data.dart';
import 'package:myapp/services/data_api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final DataAPI dataAPI = DataAPI();
  final scrollController = ScrollController();

  late final Connectivity _connectivity;
  late final Stream<List<ConnectivityResult>> _connectivityStream;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((result) async {
      if (result[0] != ConnectivityResult.none) {
        setState(() {
          _isOnline = true;
        });
      } else {
        setState(() {
          _isOnline = false;
        });
      }
    });
  }

  String? extractYearFromDate(String date) {
    final yearRegExp = RegExp(r'\b\d{4}\b'); // Matches a 4-digit year
    final match = yearRegExp.firstMatch(date);
    return match?.group(0); // Returns the year or null if not found
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(slivers: [
        CupertinoSliverNavigationBar(
          stretch: true,
          largeTitle: const Text("Data"),
          trailing: GestureDetector(
              onTap: () {
                context.push(const AddDataScreen());
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 2,
                          color: Color.fromARGB(87, 0, 0, 0))
                    ],
                    color: CupertinoTheme.of(context).primaryColor),
                child: const Text(
                  'New',
                  style: TextStyle(color: Colors.white),
                ),
              )),
        ),
        SliverFillRemaining(
          child: _isOnline
              ? CupertinoScrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  thicknessWhileDragging: 20,
                  child: SingleChildScrollView(
                    child: StreamBuilder<Map<String, dynamic>>(
                      stream: dataAPI.getDataStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                              height: context.height - 90,
                              child: const Center(
                                  child: CupertinoActivityIndicator()));
                        } else if (snapshot.hasError) {
                          debugPrint(snapshot.error.toString());
                          return SizedBox(
                            height: context.height - 90,
                            child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/empty-folder.svg',
                                      colorFilter: ColorFilter.mode(
                                          CupertinoTheme.of(context)
                                              .primaryColor,
                                          BlendMode.srcIn),
                                    ),
                                    Text('Error: ${snapshot.error}'),
                                  ]),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return SizedBox(
                            height: context.height - 90,
                            child: Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/empty-folder.svg',
                                      colorFilter: ColorFilter.mode(
                                          CupertinoTheme.of(context)
                                              .primaryColor,
                                          BlendMode.srcIn),
                                    ),
                                    const Text('No data available'),
                                  ]),
                            ),
                          );
                        } else {
                          final data = snapshot.data!;
                          print(data);
                          final titles = data['title'] != null
                              ? data['title'] as List<dynamic>
                              : [];
                          final dataByDate = Map<String, dynamic>.from(data)
                            ..remove('title');

                          // Group data by year
                          final groupedDataByYear =
                              <String, List<Map<String, dynamic>>>{};
                          dataByDate.forEach((date, value) {
                            final year =
                                extractYearFromDate(date) ?? "Unknown Year";
                            groupedDataByYear
                                .putIfAbsent(year, () => [])
                                .add({date: value});
                          });

                          // Sort years
                          final sortedYears = groupedDataByYear.keys.toList()
                            ..sort((a, b) => b.compareTo(
                                a)); // Sort years in descending order

                          return Column(
                            children: [
                              for (final year in sortedYears)
                                CupertinoListSection.insetGrouped(
                                  header: Text(
                                    year,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    for (final entry
                                        in groupedDataByYear[year]!)
                                      // Traverse through the nested data
                                      for (final subEntry
                                          in entry.values.first.entries)
                                        CupertinoListTile(
                                          onTap: () {
                                            context.push(DayDataScreen(
                                              date: subEntry.key,
                                              data: subEntry.value
                                                  as List<dynamic>,
                                              titles: titles,
                                            ));
                                          },
                                          title: Text(
                                              subEntry.key), // Key as title
                                          subtitle: Text(
                                              "${subEntry.value[0][0]} ..."),
                                          // Value as subtitle
                                          trailing: const Icon(
                                            CupertinoIcons.chevron_right,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ],
                                ),
                              const SizedBox(height: 100),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                )
              : Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/empty-folder.svg',
                          colorFilter: ColorFilter.mode(
                              CupertinoTheme.of(context).primaryColor,
                              BlendMode.srcIn),
                        ),
                        const Text(
                            'Network error. Check you Internet connection'),
                      ]),
                ),
        )
      ]),
    );
  }
}
