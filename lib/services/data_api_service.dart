import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/services/data_service.dart';

class DataAPI {
  final String baseUrl = "http://203.161.62.73:5000";

  DataAPI();

  // Method to post data to the server
  Future<void> postData(List<List<String>> data) async {
    try {
      await GoogleSheetsService().postData(data);
    } catch (e) {
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> getDataStream() async* {
    yield* Stream.periodic(const Duration(milliseconds: 1000))
        .asyncMap((_) async {
      return jsonDecode(await GoogleSheetsService().getData())
          as Map<String, dynamic>;
    });
  }

  // Helper method to get the day suffix for date formatting
  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Method to format the date as '20th JULY, 2024'
  String formatDate(DateTime date) {
    final day = date.day;
    final daySuffix = getDaySuffix(day);
    final month = DateFormat('MMMM').format(date).toUpperCase();
    final year = date.year;

    return '$day$daySuffix $month, $year';
  }
}

class DataAPIError extends Error {
  final String message;

  DataAPIError(this.message);

  @override
  String toString() {
    return message;
  }
}

class DataAPIException implements Exception {
  final String message;

  DataAPIException(this.message);

  @override
  String toString() {
    return message;
  }
}
