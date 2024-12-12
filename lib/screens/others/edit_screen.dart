import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/services/data_service.dart';
import 'package:myapp/utils/phone_formaters.dart';
import 'package:myapp/utils/textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key, required this.row});

  final List<dynamic> row;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _conditionBeforeController =
      TextEditingController();
  final TextEditingController _conditionAfterController =
      TextEditingController();

  //final DataAPI dataAPI = DataAPI();

  late bool _isSoulWon;
  final bool _followedUp = false;
  String? name;

  // Error states
  String? _nameError;
  String? _contactError;
  String? _addressError;
  String? _conditionBeforeError;

  @override
  void initState() {
    getName();
    _nameController.text = widget.row[0];
    _addressController.text = widget.row[2];
    _contactController.text = widget.row[1];
    _conditionBeforeController.text = widget.row[3];
    _conditionAfterController.text = widget.row[4];
    _isSoulWon =
        widget.row[5] == 'Yes' || widget.row[5] == 'YES' ? true : false;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _conditionBeforeController.dispose();
    _conditionAfterController.dispose();

    super.dispose();
  }

  getName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');

      final data = await GoogleSheetsService().getMinisters();
      final Map<String, dynamic> ministers = jsonDecode(data);
      if (ministers.containsKey(email)) {
        final minister = ministers[email];
        setState(() {
          name = "${minister["last_name"]} ${minister['first_name']}";
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _updateData() async {
    try {
      // Fetch all rows of data (you can also limit the number of rows to avoid unnecessary data fetching)
      var allRows = await GoogleSheetsService().fetchAllRows();
      debugPrint(widget.row.toString());

      // Find the row that matches all conditions (address, name, contact, date)
      var rowToUpdate = allRows?.firstWhere(
        (row) =>
            row[2] == widget.row[0] && // Check if the date matches
            row[3] == widget.row[1] && // Check if the name matches
            row[4] == widget.row[2] && // Check if the contact matches
            row[5] == widget.row[3], // Check if the address matches
        orElse: () {
          throw Exception('No Matching data found');
        }, // Return null if not found
      );

      String won = _isSoulWon ? 'Yes' : 'No';
      String followedUp = _followedUp ? 'Yes' : 'No';

      List<String> newData = [
        rowToUpdate?[0],
        rowToUpdate?[1],
        _nameController.text,
        _contactController.text,
        _addressController.text,
        _conditionBeforeController.text,
        _conditionAfterController.text,
        won,
        followedUp,
        name ?? '',
      ];

      if (rowToUpdate != null) {
        // Modify the row with the new data
        int rowIndex = allRows!.indexOf(rowToUpdate);
        allRows[rowIndex] = newData;

        // Update the row in the sheet (replace the old row with the updated data)
        await GoogleSheetsService()
            .updateRow(rowIndex + 1, newData); // +1 for 1-based index
      } else {
        throw Exception('No Matching data found');
      }
    } catch (err) {
      showCupertinoDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Error"),
          content: Text(err.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void poptwice() {
    context.pop();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Cancel', style: actionsTextStyle),
            onPressed: () {
              context.pop();
            }),
        trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text('Done', style: actionsTextStyle),
            onPressed: () {
              context.showLoadingDialog(_updateData, poptwice);
            }),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CupertinoFormSection.insetGrouped(
                    header: const Text('Personal Details'),
                    children: [
                      CupertinoFormRow(
                        prefix: const Text("Name"),
                        error: _nameError != null ? Text('$_nameError') : null,
                        child: CupertinoTextFormFieldRow(
                          controller: _nameController,
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: const Text("Phone"),
                        error: _contactError != null
                            ? Text('$_contactError')
                            : null,
                        child: CupertinoTextFormFieldRow(
                          onChanged: (value) {
                            //validatePhone(value);
                          },
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            ugFormatter,
                          ],
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: const Text("Address"),
                        error: _addressError != null
                            ? Text('$_addressError')
                            : null,
                        child: CupertinoTextFormFieldRow(
                          controller: _addressController,
                        ),
                      ),
                    ],
                  ),
                  CupertinoFormSection.insetGrouped(
                    header: const Text('Condition'),
                    children: [
                      CupertinoFormRow(
                        helper: const Text(
                          "Condition before",
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                        error: _conditionBeforeError != null
                            ? Text('$_conditionBeforeError')
                            : null,
                        child: CupertinoTextFormFieldRow(
                          controller: _conditionBeforeController,
                        ),
                      ),
                      CupertinoFormRow(
                        helper: const Text(
                          "Condition after",
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                        child: CupertinoTextFormFieldRow(
                          controller: _conditionAfterController,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  CupertinoFormSection.insetGrouped(
                    header: const Text('Soul Condition'),
                    children: [
                      CupertinoFormRow(
                        prefix: const Text("Won Soul?"),
                        child: CupertinoSwitch(
                          value: _isSoulWon,
                          onChanged: (bool value) {
                            setState(() {
                              _isSoulWon = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
