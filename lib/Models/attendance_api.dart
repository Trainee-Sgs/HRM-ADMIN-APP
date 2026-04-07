import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BreakEntry {
  final String purpose;
  final DateTime breakInTime;
  final DateTime? breakOutTime;
  final Duration duration;

  BreakEntry({
    required this.purpose,
    required this.breakInTime,
    this.breakOutTime,
    required this.duration,
  });
}

class BreakReportResponse {
  final bool error;
  final String message;
  final int count;
  final List<BreakReportData> data;

  BreakReportResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
  });

  factory BreakReportResponse.fromJson(Map<String, dynamic> json) {
    return BreakReportResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: json['count'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => BreakReportData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BreakReportData {
  final int id;
  final dynamic aid;
  final int uid;
  final dynamic bid;
  final int cid;
  final dynamic did;
  final String breakIn;
  final String employeeCode;
  final String employeeName;
  final String breakOut;
  final String reason;
  final dynamic del;
  final dynamic isD;
  final dynamic act;
  final String dtime;

  BreakReportData({
    required this.id,
    this.aid,
    required this.uid,
    this.bid,
    required this.cid,
    this.did,
    required this.breakIn,
    required this.employeeCode,
    required this.employeeName,
    required this.breakOut,
    required this.reason,
    this.del,
    this.isD,
    this.act,
    required this.dtime,
  });

  factory BreakReportData.fromJson(Map<String, dynamic> json) {
    return BreakReportData(
      id: json['id'] ?? 0,
      aid: json['aid'],
      uid: json['uid'] ?? 0,
      bid: json['bid'],
      cid: json['cid'] ?? 0,
      did: json['did'],
      breakIn: json['break_in'] ?? "",
      employeeCode: json['employee_code'] ?? "",
      employeeName: json['employee_name'] ?? "",
      breakOut: json['break_out'] ?? "",
      reason: json['reason'] ?? "",
      del: json['del'],
      isD: json['is_d'],
      act: json['act'],
      dtime: json['dtime'] ?? "",
    );
  }
}

class ShiftTypeResponse {
  final bool error;
  final String message;
  final int count;
  final List<ShiftTypeData> data;

  ShiftTypeResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
  });

  factory ShiftTypeResponse.fromJson(Map<String, dynamic> json) {
    return ShiftTypeResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: json['count'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => ShiftTypeData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ShiftTypeData {
  final int id;
  final dynamic aid;
  final int uid;
  final dynamic bid;
  final int cid;
  final dynamic did;
  final String shiftCode;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String breakDuration;
  final String totalHours;
  final String graceTime;
  final String remarks;
  final dynamic overtimeStart;
  final dynamic del;
  final dynamic isD;
  final dynamic act;
  final String dtime;

  ShiftTypeData({
    required this.id,
    this.aid,
    required this.uid,
    this.bid,
    required this.cid,
    this.did,
    required this.shiftCode,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.breakDuration,
    required this.totalHours,
    required this.graceTime,
    required this.remarks,
    this.overtimeStart,
    this.del,
    this.isD,
    this.act,
    required this.dtime,
  });

  factory ShiftTypeData.fromJson(Map<String, dynamic> json) {
    return ShiftTypeData(
      id: json['id'] ?? 0,
      aid: json['aid'],
      uid: json['uid'] ?? 0,
      bid: json['bid'],
      cid: json['cid'] ?? 0,
      did: json['did'],
      shiftCode: json['shift_code'] ?? "",
      shiftName: json['shift_name'] ?? "",
      startTime: json['start_time'] ?? "",
      endTime: json['end_time'] ?? "",
      breakDuration: json['break_duration'] ?? "",
      totalHours: json['total_hours'] ?? "",
      graceTime: json['grace_time'] ?? "",
      remarks: json['remarks'] ?? "",
      overtimeStart: json['overtime_start'],
      del: json['del'],
      isD: json['is_d'],
      act: json['act'],
      dtime: json['dtime'] ?? "",
    );
  }
}

class AttendanceApi {
  static const String _baseUrl = "https://erpsmart.in/total/api/m_api/";

  static Future<BreakReportResponse> fetchBreakReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '21472147';
      final String deviceId = prefs.getString('device_id') ?? '123';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '123';

      final Map<String, String> body = {
        'type': '2083',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_15932',
        'select': '*',
      };

      print("Break Report Request body: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Break Report response Status Code: ${response.statusCode}");
      print("Break Report response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return BreakReportResponse.fromJson(decodedData);
      } else {
        throw Exception("Failed to load break report: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching break report: $e");
      throw Exception("Error fetching break report: $e");
    }
  }

  static Future<ShiftTypeResponse> fetchShiftTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '21472147';
      final String deviceId = prefs.getString('device_id') ?? '123';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '123';

      final Map<String, String> body = {
        'type': '2083',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_15911',
        'select': '*',
      };

      print("Shift Types Request body: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Shift Types response Status Code: ${response.statusCode}");
      print("Shift Types response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return ShiftTypeResponse.fromJson(decodedData);
      } else {
        throw Exception("Failed to load shift types: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching shift types: $e");
      throw Exception("Error fetching shift types: $e");
    }
  }

  static Future<ShiftAllocationResponse> fetchShiftAllocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '21472147';
      final String deviceId = prefs.getString('device_id') ?? '123';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '123';

      final Map<String, String> body = {
        'type': '2083',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_15921',
        'select': '*',
      };

      print("Shift Allocations Request body: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Shift Allocations response Status Code: ${response.statusCode}");
      print("Shift Allocations response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return ShiftAllocationResponse.fromJson(decodedData);
      } else {
        throw Exception("Failed to load shift allocations: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching shift allocations: $e");
      throw Exception("Error fetching shift allocations: $e");
    }
  }

  static Future<MobileAttendanceResponse> fetchMobileAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '21472147';
      final String deviceId = prefs.getString('device_id') ?? '123';
      final String lt = prefs.getString('lt') ?? '123';
      final String ln = prefs.getString('ln') ?? '123';

      final Map<String, String> body = {
        'type': '2083',
        'cid': cid,
        'lt': lt,
        'ln': ln,
        'device_id': deviceId,
        'form': 'sm_main_form_15930',
        'select': '*',
      };

      print("Mobile Attendance Request body: $body");

      final response = await http.post(
        Uri.parse(_baseUrl),
        body: body,
      );

      print("Mobile Attendance response Status Code: ${response.statusCode}");
      print("Mobile Attendance response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return MobileAttendanceResponse.fromJson(decodedData);
      } else {
        throw Exception("Failed to load mobile attendance: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching mobile attendance: $e");
      throw Exception("Error fetching mobile attendance: $e");
    }
  }

  // ---------- New Consolidated Sync Methods ----------

  static Future<Map<String, dynamic>> fetchWorkTypes({required String cid, required String deviceId, required String lat, required String lng}) async {
    final body = {
      "type": "2053",
      "cid": cid,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
    };
    final response = await http.post(Uri.parse(_baseUrl), body: body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchTransportTypes({required String cid, required String deviceId, required String lat, required String lng}) async {
    final body = {
      "type": "2054",
      "cid": cid,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
    };
    final response = await http.post(Uri.parse(_baseUrl), body: body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkIn({
    required String cid,
    required String uid,
    required String inTime,
    required String loc,
    required String workMode,
    required String deviceId,
    required String lat,
    required String lng,
    String? transportId,
    String? token,
    File? selfie,
    File? vehiclePhoto,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.fields.addAll({
      "type": "2046",
      "cid": cid,
      "uid": uid,
      "in_time": inTime,
      "loc": loc,
      "wrk_mde": workMode,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
      if (transportId != null) "transport_id": transportId,
      if (token != null) "token": token,
    });

    if (selfie != null) {
      request.files.add(await http.MultipartFile.fromPath('selfie', selfie.path));
    }
    if (vehiclePhoto != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', vehiclePhoto.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> checkOut({
    required String cid,
    required String uid,
    required String outTime,
    required String loc,
    required String workMode,
    required String deviceId,
    required String lat,
    required String lng,
    String? transportId,
    String? token,
    File? selfie,
    File? vehiclePhoto,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
    request.fields.addAll({
      "type": "2047",
      "cid": cid,
      "uid": uid,
      "out_time": outTime,
      "loc": loc,
      "wrk_mde": workMode,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
      if (transportId != null) "transport_id": transportId,
      if (token != null) "token": token,
    });

    if (selfie != null) {
      request.files.add(await http.MultipartFile.fromPath('selfie', selfie.path));
    }
    if (vehiclePhoto != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', vehiclePhoto.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchAttendanceSummary({
    required String cid,
    required String uid,
    required String deviceId,
    required String lat,
    required String lng,
    String? token,
  }) async {
    final body = {
      "type": "2064",
      "cid": cid,
      "uid": uid,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
      "report_type": "attendance",
      if (token != null) "token": token,
    };
    final response = await http.post(Uri.parse(_baseUrl), body: body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchLeaveStatistics({
    required String cid,
    required String uid,
    required String deviceId,
    required String lat,
    required String lng,
    String? token,
  }) async {
    final body = {
      "type": "2052",
      "cid": cid,
      "uid": uid,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
      if (token != null) "token": token,
    };
    final response = await http.post(Uri.parse(_baseUrl), body: body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchBreakHistory({
    required String cid,
    required String uid,
    required String deviceId,
    required String lat,
    required String lng,
    String? token,
  }) async {
    final body = {
      "type": "2079",
      "cid": cid,
      "uid": uid,
      "id": uid,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
      if (token != null) "token": token,
    };
    final response = await http.post(Uri.parse(_baseUrl), body: body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> breakIn({
    required String cid,
    required String uid,
    required String deviceId,
    required String lat,
    required String lng,
    required String reason,
    String? token,
  }) async {
    final body = {
      "type": "2055",
      "cid": cid,
      "uid": uid,
      "id": uid,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
      "reason": reason,
      if (token != null) "token": token,
    };
    final response = await http.post(Uri.parse(_baseUrl), body: body);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> breakOut({
    required String cid,
    required String uid,
    required String deviceId,
    required String lat,
    required String lng,
    String? token,
  }) async {
    final body = {
      "type": "2056",
      "cid": cid,
      "uid": uid,
      "id": uid,
      "device_id": deviceId,
      "lt": lat,
      "ln": lng,
      if (token != null) "token": token,
    };
    final response = await http.post(Uri.parse(_baseUrl), body: body);
    return jsonDecode(response.body);
  }
}

class MobileAttendanceResponse {
  final bool error;
  final String message;
  final int count;
  final List<MobileAttendanceData> data;

  MobileAttendanceResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
  });

  factory MobileAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return MobileAttendanceResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: json['count'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => MobileAttendanceData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MobileAttendanceData {
  final int id;
  final dynamic aid;
  final int uid;
  final dynamic bid;
  final int cid;
  final dynamic did;
  final String inTime;
  final String eName;
  final String? photo;
  final String? transportId;
  final String employeeName;
  final String loc;
  final String? attendanceStatus;
  final String? approvalStatus;
  final String selfie;
  final String? outTime;
  final String status;
  final String? bIn;
  final String? bOut;
  final String? bStatus;
  final String date;
  final dynamic ot;
  final dynamic ovr;
  final String wrkMde;
  final dynamic del;
  final dynamic isD;
  final dynamic act;
  final String dtime;
  final String? approvedBy;
  final String? approvalDate;

  MobileAttendanceData({
    required this.id,
    this.aid,
    required this.uid,
    this.bid,
    required this.cid,
    this.did,
    required this.inTime,
    required this.eName,
    this.photo,
    this.transportId,
    required this.employeeName,
    required this.loc,
    this.attendanceStatus,
    this.approvalStatus,
    required this.selfie,
    this.outTime,
    required this.status,
    this.bIn,
    this.bOut,
    this.bStatus,
    required this.date,
    this.ot,
    this.ovr,
    required this.wrkMde,
    this.del,
    this.isD,
    this.act,
    required this.dtime,
    this.approvedBy,
    this.approvalDate,
  });

  factory MobileAttendanceData.fromJson(Map<String, dynamic> json) {
    return MobileAttendanceData(
      id: json['id'] ?? 0,
      aid: json['aid'],
      uid: json['uid'] ?? 0,
      bid: json['bid'],
      cid: json['cid'] ?? 0,
      did: json['did'],
      inTime: json['in_time'] ?? "",
      eName: json['e_name'] ?? "",
      photo: json['photo'],
      transportId: json['transport_id'],
      employeeName: json['employee_name'] ?? "",
      loc: json['loc'] ?? "",
      attendanceStatus: json['attendance_status'],
      approvalStatus: json['approval_status'],
      selfie: json['selfie'] ?? "",
      outTime: json['out_time'],
      status: json['status'] ?? "",
      bIn: json['b_in'],
      bOut: json['b_out'],
      bStatus: json['b_status'],
      date: json['date'] ?? "",
      ot: json['ot'],
      ovr: json['ovr'],
      wrkMde: json['wrk_mde'] ?? "",
      del: json['del'],
      isD: json['is_d'],
      act: json['act'],
      dtime: json['dtime'] ?? "",
      approvedBy: json['approved_by'],
      approvalDate: json['approval_date'],
    );
  }
}

class ShiftAllocationResponse {
  final bool error;
  final String message;
  final int count;
  final List<ShiftAllocationData> data;

  ShiftAllocationResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.data,
  });

  factory ShiftAllocationResponse.fromJson(Map<String, dynamic> json) {
    return ShiftAllocationResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? "",
      count: json['count'] ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => ShiftAllocationData.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ShiftAllocationData {
  final int id;
  final dynamic aid;
  final int uid;
  final dynamic bid;
  final int cid;
  final dynamic did;
  final String employeeName;
  final String shiftType;
  final String employeeCode;
  final String department;
  final String allocateDate;
  final String remarks;
  final dynamic del;
  final dynamic isD;
  final dynamic act;
  final String dtime;

  ShiftAllocationData({
    required this.id,
    this.aid,
    required this.uid,
    this.bid,
    required this.cid,
    this.did,
    required this.employeeName,
    required this.shiftType,
    required this.employeeCode,
    required this.department,
    required this.allocateDate,
    required this.remarks,
    this.del,
    this.isD,
    this.act,
    required this.dtime,
  });

  factory ShiftAllocationData.fromJson(Map<String, dynamic> json) {
    return ShiftAllocationData(
      id: json['id'] ?? 0,
      aid: json['aid'],
      uid: json['uid'] ?? 0,
      bid: json['bid'],
      cid: json['cid'] ?? 0,
      did: json['did'],
      employeeName: json['employee_name'] ?? "",
      shiftType: json['shift_type'] ?? "",
      employeeCode: json['employee_code'] ?? "",
      department: json['department'] ?? "",
      allocateDate: json['allocate_date'] ?? "",
      remarks: json['remarks'] ?? "",
      del: json['del'],
      isD: json['is_d'],
      act: json['act'],
      dtime: json['dtime'] ?? "",
    );
  }
}
