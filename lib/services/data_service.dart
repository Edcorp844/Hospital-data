import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:gsheets/gsheets.dart';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:myapp/services/secrets.dart';

// pmimbarara@phaneroo-mbara-hospital-data.iam.gserviceaccount.com

//pmimbarara@phaneroo-mbara-hospital-data.iam.gserviceaccount.com

var sheetID = "1RhxLhmTOBcVmhywromOCnSr8PrdIxpECfgP5NRvTTCI";

final gSheetInit = GSheets(gSheetServicCredentials);
late Spreadsheet gsheetController;
late Spreadsheet ministers;
late Spreadsheet data;
late Spreadsheet appData;
Worksheet? sheet;
Worksheet? ministerSheet;
Worksheet? devotion;
Worksheet? events;
Worksheet? material;

Future<void> googleSheetsinit() async {
  try {
    gsheetController = await gSheetInit.spreadsheet(sheetID);
    sheet = gsheetController.worksheetByTitle("Sheet1");
    ministers = await gSheetInit
        .spreadsheet("1j44RqSUZoyCR9op2u9MLTSWVsJ3TOGMGvOefW9pbF0Y");
    ministerSheet = ministers.worksheetByTitle("Sheet1");
    appData = await gSheetInit
        .spreadsheet('1vSHPmQ8KVfbKDPkK_0pyaRNqFtLWeL9_9UzAubqqKwc');
    devotion = appData.worksheetByTitle("Sheet1");
    events = appData.worksheetByTitle("Sheet2");
    material = appData.worksheetByTitle("Sheet3");
  } on SocketException {
    rethrow;
  } on ClientException {
    rethrow;
  } catch (e) {
    throw Exception("An unexpected error occurred during initialization: $e");
  }
}

class GoogleSheetsService {
  GoogleSheetsService();
  Future<String> getMinisters() async {
    try {
      if (ministerSheet == null) {
        return jsonEncode({"error": "Sheet is not initialized"});
      }

      // Fetch all rows
      final values = await ministerSheet!.values.allRows(fromRow: 1);

      if (values.isEmpty || values.length <= 2) {
        return jsonEncode({"error": "No data found"});
      }

      // Skip the first two rows (header + metadata)
      final dataRows = values.skip(2);

      // Index for email column
      const emailIndex = 3;

      // Map to store ministers where email is the key
      final Map<String, Map<String, dynamic>> ministers = {};

      for (var row in dataRows) {
        if (row.length <= emailIndex || row[emailIndex].isEmpty) {
          continue; // Skip rows without valid emails
        }

        final email = row[emailIndex];

        ministers[email] = {
          "first_name": row.isNotEmpty ? row[0] : null,
          "last_name": row.length > 1 ? row[1] : null,
          "phone": row.length > 2 ? row[2] : null,
          "address": row.length > 4 ? row[4] : null,
          "date_of_birth": row.length > 5 ? row[5] : null,
          "is_student": row.length > 6 && row[6].toUpperCase() == "YES",
          "position": row.length > 7 ? row[7] : null,
        };
      }

      // Return JSON
      return jsonEncode(ministers);
    } catch (e) {
      return jsonEncode({"error": e.toString()});
    }
  }

  Future<String> getData() async {
    try {
      // Ensure the sheet is initialized
      if (sheet == null) {
        return jsonEncode({"error": "Sheet is not initialized"});
      }

      // Fetch all values from the specified range (starting from row 1)
      final values = await sheet!.values.allRows(fromRow: 1);

      // Check if there are values
      if (values.isEmpty) {
        return jsonEncode({"error": "No data found"});
      }

      // Extract headers, skipping the first two columns (No. and DATE)
      final headers = values[0].skip(1).map((e) => e.toString()).toList();

      // Extract the data rows, skipping the first two columns (No. and DATE)
      final data = values.skip(1).map((row) {
        return row
            .skip(1)
            .map((e) => e.toString())
            .toList(); // Skip first two columns for each row
      }).toList();

      // Reverse the data so the last row comes first
      final reversedData = data.reversed.toList();

      // Organize data by year and then by date
      final organizedData = <String, dynamic>{
        "title": headers,
      };

      for (var row in reversedData) {
        if (row.isNotEmpty) {
          final date = row[0]; // The first column now represents the date
          final year = extractYearFromDate(date); // Extract year from the date
          if (year != null && date.isNotEmpty) {
            // Initialize year group if it doesn't exist
            if (!organizedData.containsKey(year)) {
              organizedData[year] = <String, dynamic>{};
            }
            final yearGroup = organizedData[year] as Map<String, dynamic>;

            // Initialize date group if it doesn't exist
            if (!yearGroup.containsKey(date)) {
              yearGroup[date] = <List<String>>[];
            }
            (yearGroup[date] as List<List<String>>)
                .add(row.sublist(1)); // Exclude the date
          }
        }
      }

      // Return organized data as JSON
      return jsonEncode(organizedData);
    } catch (e) {
      // Handle errors and return as a JSON string
      return jsonEncode({"error": e.toString()});
    }
  }

// Helper function to extract the year from a date string
  String? extractYearFromDate(String date) {
    final yearRegExp = RegExp(r'\b\d{4}\b'); // Matches a 4-digit year
    final match = yearRegExp.firstMatch(date);
    return match?.group(0); // Returns the year or null if not found
  }

  Future<void> postData(List<List<String>> data) async {
    try {
      // Ensure the sheet is initialized
      if (sheet == null) {
        throw Error();
      }

      // Insert data into the sheet (starting from the last row)
      for (var row in data) {
        var safeRow = row.map((cell) {
          return "'$cell";
        }).toList();

        await sheet!.values.appendRow(safeRow, fromColumn: 2);
      }
    } on SocketException {
      throw Exception(
          "Failed to connect to the server. Please check your internet connection.");
    } on ClientException {
      throw Exception("An error occurred while accessing the service.");
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasAccess(String email) async {
    try {
      // Call the existing function that retrieves data as a map
      final data = await GoogleSheetsService().getMinisters();

      // Parse the data (assuming `getMinisters` returns JSON)
      final Map<String, dynamic> ministers = jsonDecode(data);

      // Check if the email exists in the map keys
      return ministers.containsKey(email);
    } catch (e) {
      return false; // Default to no access on error
    }
  }

  Future<Map<String, dynamic>> getDevotion() async {
    try {
      if (devotion == null) {
        throw jsonEncode({"error": "Sheet is not initialized"});
      }

      // Fetch all rows
      final values = await devotion!.values.allRows(fromRow: 1);

      if (values.isEmpty || values[0].isEmpty) {
        throw jsonEncode({"error": "No data found in the sheet"});
      }

      // Extract the first row (keys are column names, values are row 1 data)
      final firstRow = values[0];
      Map<String, dynamic> map = {};
      List<String> columns = [
        'Category',
        'Date',
        'Scripture',
        'heading',
        'body',
        'FurtherStudy',
        'GoldenNugget',
        'Prayer',
      ];

      for (int i = 0; i < firstRow.length; i++) {
        map[columns[i]] = firstRow[i];
      }

      return map;
    } catch (e) {
      return {"error": "Failed to fetch data: $e"};
    }
  }

  Future<Map<String, dynamic>> getEvents() async {
    try {
      if (events == null) {
        throw Exception("Sheet is not initialized");
      }

      // Fetch all rows
      final values = await events!.values.allRows();

      if (values.isEmpty || values[0].isEmpty) {
        throw Exception("No data found in the sheet");
      }
      Map<String, dynamic> map = {};
      for (var row in values) {
        map[row[0]] = row[1];
      }
      return map;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMaterial() async {
    try {
      if (material == null) {
        throw Exception("Sheet is not initialized");
      }

      // Fetch all rows
      final values = await material!.values.allRows();

      if (values.isEmpty || values[0].isEmpty) {
        throw Exception("No data found in the sheet");
      }
      Map<String, dynamic> map = {};
      for (var row in values) {
        map[row[0]] = row[1];
      }
      return map;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<List>?> fetchAllRows() async {
    try {
      if (sheet != null) {
        var rows = await sheet?.values.allRows();
        return rows;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Update row in the Google Sheet
  Future<void> updateRow(int rowIndex, List<String> data) async {
    try {
      if (sheet != null) {
        var safeRow = data.map((cell) {
          return "'$cell";
        }).toList();
        await sheet?.values.insertRow(rowIndex, safeRow).then((_) {
          debugPrint("Row updated successfully");
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
