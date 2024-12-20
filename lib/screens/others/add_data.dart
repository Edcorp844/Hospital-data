// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/services/data_api_service.dart';
import 'package:myapp/services/data_service.dart';
import 'package:myapp/utils/phone_formaters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _conditionBeforeController =
      TextEditingController();
  final TextEditingController _conditionAfterController =
      TextEditingController();

  final DataAPI dataAPI = DataAPI();

  bool _isSoulWon = false;
  final bool _followedUp = false;
  String? name;

  // Error states
  String? _nameError;
  String? _contactError;
  String? _addressError;
  String? _conditionBeforeError;
  String? _ministersNameError;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _conditionBeforeController.dispose();
    _conditionAfterController.dispose();

    super.dispose();
  }

  @override
  initState() {
    getName();
    super.initState();
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

  void validatePhone(String phone) {
    // Remove all spaces for validation purposes
    final cleanedPhone = phone.replaceAll(RegExp(r'\s+'), '');

    // Regular expression to validate phone numbers with a 3-digit country code
    final phoneRegExp = RegExp(
      r'^\+\d{3}\d{7,12}$', // +XXX followed by 7-12 digits
    );

    if (cleanedPhone.isEmpty) {
      setState(() {
        _contactController.text = '';
        _contactError = 'Phone number is required.';
      });
      return;
    }

    // Validate against the phone format
    if (!phoneRegExp.hasMatch(cleanedPhone)) {
      setState(() {
        _contactError =
            'Enter a valid phone number with a country code. eg +256xxxxxxxxxx';
      });
      return;
    }

    // If valid, clear the error message
    setState(() {
      _contactError = null;
    });
  }

  bool _validateFields() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name is required' : null;
      validatePhone(_contactController.text);
      _addressError =
          _addressController.text.isEmpty || _addressController.text == ''
              ? 'Address is required'
              : null;
      _conditionBeforeError = _conditionBeforeController.text.isEmpty
          ? 'Condition before is required'
          : null;
    });

    return _nameError == null &&
        _contactError == null &&
        _addressError == null &&
        _conditionBeforeError == null &&
        _ministersNameError == null;
  }

  void _addData() async {
    try {
      String date = dataAPI.formatDate(DateTime.now());
      String won = _isSoulWon ? 'Yes' : 'No';
      String followedUp = _followedUp ? 'Yes' : 'No';

      List<String> data = [
        date,
        _nameController.text,
        _contactController.text,
        _addressController.text,
        _conditionBeforeController.text,
        _conditionAfterController.text,
        won,
        followedUp,
        name ?? '',
      ];

      await dataAPI.postData([data]);
    } catch (err) {
      showCupertinoDialog(
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: "Back",
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            if (_validateFields()) {
              context.showLoadingDialog(_addData, () {
                context.pop();
              });
            }
          },
          child: Text(
            "Done",
            style: const CupertinoTextThemeData()
                .textStyle
                .copyWith(color: context.primaryColor),
          ),
        ),
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
                            validatePhone(value);
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
