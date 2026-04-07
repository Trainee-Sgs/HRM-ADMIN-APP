import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LeaveRequestResponse {
  final bool error;
  final String message;
  final int count;
  final List<LeaveRequestData> data;

  LeaveRequestResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: json['count'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => LeaveRequestData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class LeaveRequestData {
  final int id;
  final int? aid;
  final int? uid;
  final dynamic bid;
  final int? cid;
  final dynamic did;
  final String employeeName;
  final String? employeeId;
  final String? department;
  final String leaveType;
  final String? maxLeaveMonth;
  final String? maxLeaveYear;
  final String? leaveTaken;
  final String? balanceLeave;
  final String? appBy;
  final String? rejectReason;
  final String? leaveStartDate;
  final String? leaveEndDate;
  final String? totalDays;
  final String? reason;
  final String? status;
  final String? appDate;
  final String? appliedDate;
  final String? attachment;
  final dynamic del;
  final dynamic isD;
  final dynamic act;
  final String dtime;

  LeaveRequestData({
    required this.id,
    this.aid,
    this.uid,
    this.bid,
    this.cid,
    this.did,
    required this.employeeName,
    this.employeeId,
    this.department,
    required this.leaveType,
    this.maxLeaveMonth,
    this.maxLeaveYear,
    this.leaveTaken,
    this.balanceLeave,
    this.appBy,
    this.rejectReason,
    this.leaveStartDate,
    this.leaveEndDate,
    this.totalDays,
    this.reason,
    this.status,
    this.appDate,
    this.appliedDate,
    this.attachment,
    this.del,
    this.isD,
    this.act,
    required this.dtime,
  });

  factory LeaveRequestData.fromJson(Map<String, dynamic> json) {
    // Helper to extract int from either String or Int fields
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    return LeaveRequestData(
      id: parseId(json['id']),
      aid: json['aid'] != null ? parseId(json['aid']) : null,
      uid: parseId(json['uid']),
      bid: json['bid'],
      cid: json['cid'] != null ? parseId(json['cid']) : null,
      did: json['did'],
      employeeName: json['employee_name'] ?? "",
      employeeId: json['employee_id']?.toString(),
      department: json['department']?.toString(),
      leaveType: json['leave_type'] ?? "",
      maxLeaveMonth: json['max_leave_month']?.toString(),
      maxLeaveYear: json['max_leave_year']?.toString(),
      leaveTaken: json['leave_taken']?.toString(),
      balanceLeave: json['balance_leave']?.toString(),
      appBy: json['app_by'],
      rejectReason: json['reject_reason'],
      leaveStartDate: json['leave_start_date'],
      leaveEndDate: json['leave_end_date'],
      totalDays: json['total_days']?.toString(),
      reason: json['reason'],
      status: json['status'],
      appDate: json['app_date'],
      appliedDate: json['applied_date'],
      attachment: json['attachment'],
      del: json['del'],
      isD: json['is_d'],
      act: json['act'],
      dtime: json['dtime'] ?? "",
    );
  }
}

class LeaveApi {
  static const String _baseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<LeaveRequestResponse> fetchLeaveRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Fetch stored values or use defaults from the user prompt
      final String cid = prefs.getString('cid') ?? '21472147';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '123';
      final String deviceId = prefs.getString('device_id') ?? '1237';

      final Map<String, String> body = {
        'type': '2083',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_16112', // Specifically for Leave Request
        'select': '*',
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Leave Request response Status Code: ${response.statusCode}");
      print("Leave Request response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return LeaveRequestResponse.fromJson(decodedData);
      } else {
        throw Exception("Failed to load leave requests: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching leave requests: $e");
      throw Exception("Error fetching leave requests: $e");
    }
  }

  static Future<Map<String, dynamic>> updateLeaveStatus({
    required String id,
    required String uid,
    required String status,
    String? rejectReason,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '21472147';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '123';
      final String deviceId = prefs.getString('device_id') ?? '123';

      final Map<String, String> body = {
        'type': '2085',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_16112',
        'id': id,
        'uid': uid,
        'status': status,
        if (rejectReason != null) 'reject_reason': rejectReason,
      };

      print("--- UPDATING LEAVE STATUS ---");
      print("URL: $_baseUrl");
      print("BODY: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Update Leave Status Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Error updating leave status: $e");
      return {"error": true, "message": e.toString()};
    }
  }
}
