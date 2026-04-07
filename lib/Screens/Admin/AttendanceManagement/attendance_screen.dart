import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:hrm_admin_app/Models/attendance_api.dart';
import 'weekly_history.dart';
import 'checkin.dart';
import 'package:hrm_admin_app/Screens/Admin/AttendanceManagement/check_out.dart';
import 'package:hrm_admin_app/Screens/Admin/admin_dashboard.dart';
import 'package:hrm_admin_app/Screens/Admin/AttendanceManagement/marketing_attendance.dart';

class EmployeeApi {
  static Future<Map<String, dynamic>> getEmployeeDetails({
    required String uid,
    required String cid,
    required String deviceId,
    required String lat,
    required String lng,
    String? token,
  }) async {
    return {"error": false, "data": {}};
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

// Removed internal BreakEntry (moved to attendance_api.dart)

class AttendanceScreenState extends State<AttendanceScreen> {
  bool breakSwitch = false;
  int bottomNavIndex = 1;
  int selectedTab = 1; // Default to Monthly as per typical dashboard usage here
  bool isCheckedIn = false;
  bool isTodayFinished = false;
  Timer? breakTimer;
  Duration breakDuration = Duration.zero;
  Duration totalBreakDuration = Duration.zero;
  bool isLoading = false;
  String uid = ""; // Session UID (Original Login ID)
  String? serverUidString; // To store the original value from server
  String userName = "User";
  String profilePhoto = "";
  String breakPurpose = "Tea"; // Default/Sample purpose
  final TextEditingController purposeController = TextEditingController();
  List<BreakEntry> breakHistory = [];
  DateTime? currentBreakInTime;

  // API Integration fields
  String cid = ""; // Company ID
  String? employeeCode;
  String? employeeName;
  String? deviceId;
  Position? currentPosition;
  int? currentBreakId; // Store break_id from API response

  Map<String, dynamic>? attendanceHistory;

  bool isHistoryLoading = false;
  bool isBreakHistoryLoading = false;
  String leaveTakenStr = "0";
  String lopTakenStr = "0";
  int daysWorked = 0; // Monthly approved days (both in+out valid)
  int weeklyDaysWorked = 0; // Weekly approved days (within current Mon-Sun)

  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Load basic local data immediately (No network, very fast)
    final prefs = await SharedPreferences.getInstance();

    // 🚨 STRICT RESET: Start with false, then verify from local storage
    if (mounted) {
      setState(() {
        isCheckedIn = false;
        isTodayFinished = false;

        final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final String lastCheckIn = prefs.getString('last_checkin_date') ?? "";
        final String lastCheckOut = prefs.getString('last_checkout_date') ?? "";

        if (lastCheckIn == today && lastCheckOut != today) {
          isCheckedIn = true;
        } else if (lastCheckOut == today) {
          isTodayFinished = true;
        }
      });
    }

    await _loadUid();

    // 2. Start all network calls in parallel to improve performance
    setState(() => isHistoryLoading = true);

    _getDeviceId(); // Non-blocking

    try {
      // Parallel execution of independent APIs
      await Future.wait([
        _loadEmployeeData(),
        _fetchAttendanceSummary(),
        _fetchLeaveStatistics(),
        _fetchBreakHistory(),
      ]);
    } catch (e) {
      debugPrint("Parallel initialization error: $e");
    } finally {
      if (mounted) {
        setState(() => isHistoryLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    breakTimer?.cancel();
    purposeController.dispose();
    super.dispose();
  }

  Future<void> _fetchBreakHistory({VoidCallback? onUpdate}) async {
    if (!mounted) return;
    setState(() {
      isBreakHistoryLoading = false;
      breakHistory = []; // Initialize empty or with mock data
      totalBreakDuration = Duration.zero;
    });
    if (onUpdate != null) onUpdate();
  }


  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // ✅ Standardized UID priority: login_cus_id (Primary)
      uid =
          prefs.getString('login_cus_id') ??
          prefs.getString('server_uid') ??
          prefs.getString('employee_table_id') ??
          prefs.getInt('uid')?.toString() ??
          "";
      cid = prefs.getString('cid') ?? "";
      serverUidString = prefs.getString('server_uid') ?? uid;
      userName = prefs.getString('name') ?? "User";
      employeeName = prefs.getString('name');
      employeeCode = prefs.getString('employee_code');
      profilePhoto = prefs.getString('profile_photo') ?? "";
      deviceId = prefs.getString('device_id') ?? "";

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastCheckIn = prefs.getString('last_checkin_date');
      final lastCheckOut = prefs.getString('last_checkout_date');

      // Reset isCheckedIn if it's a new day
      if (lastCheckIn == today && lastCheckOut != today) {
        isCheckedIn = true;
      } else {
        isCheckedIn = false;
        // Also clear local persistent state if it's stale
        if (lastCheckIn != today) {
          prefs.setBool('isCheckedIn', false);
        }
      }

      isTodayFinished = lastCheckOut == today;

      // Restore Break state
      bool isOnBreakStored = prefs.getBool('is_on_break') ?? false;

      // ✅ RELAXED SYNC: Always try to restore break if it's in local memory
      if (isOnBreakStored) {
        String? startTimeStr = prefs.getString('break_start_time');
        if (startTimeStr != null) {
          try {
            DateTime startTime = DateTime.parse(startTimeStr);
            currentBreakInTime = startTime;
            breakSwitch = true;
            currentBreakId = prefs.getInt('current_break_id') ?? currentBreakId;
            breakPurpose = prefs.getString('break_purpose') ?? "Tea";
            breakDuration = DateTime.now().difference(startTime);
            startBreakTimer();
          } catch (e) {
            debugPrint("Error restoring break timer: $e");
          }
        }
      } else {
        breakSwitch = false;
        breakDuration = Duration.zero;
      }
    });
    debugPrint(
      "LOADED INITIAL STATE: deviceId=$deviceId, isCheckedIn=$isCheckedIn, uid=$uid, cid=$cid",
    );
  }

  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Get identifiers from SharedPreferences
    final String storedUid =
        prefs.getString('login_cus_id') ??
        prefs.getString('server_uid') ??
        prefs.getString('employee_table_id') ??
        prefs.getInt('uid')?.toString() ??
        "";
    final storedCid = prefs.getString('cid') ?? "";
    final storedCode = prefs.getString('employee_code');
    final storedName = prefs.getString('name');

    setState(() {
      uid = storedUid;
      cid = storedCid;
      employeeCode = storedCode;
      employeeName = storedName ?? userName;
      profilePhoto = prefs.getString('profile_photo') ?? "";
    });

    debugPrint(
      "Initial Load: uid=$uid, cid=$cid, code=$employeeCode, name=$employeeName",
    );

    // 2. Fetch full details from server to sync state
    try {
      final lat = prefs.getDouble('lat')?.toString() ?? "0.0";
      final lng = prefs.getDouble('lng')?.toString() ?? "0.0";
      final dId = prefs.getString('device_id') ?? deviceId ?? "";

      final res = await EmployeeApi.getEmployeeDetails(
        uid: uid.toString(),
        cid: cid,
        deviceId: dId,
        lat: lat,
        lng: lng,
        token: prefs.getString('token'),
      );

      if (res["error"] == false) {
        debugPrint("FULL SYNC RESPONSE: ${jsonEncode(res)}");
        final data = res["data"] ?? res;

        // UPDATE TOKEN IF RETURNED
        final String? newToken = res["token"] ?? data["token"];
        if (newToken != null && newToken.isNotEmpty) {
          await prefs.setString('token', newToken);
          debugPrint("Employee Sync: New Session Token Saved => $newToken");
        }

        // Multi-Identifier Discovery
        String? foundId = data["id"]?.toString(); // Numeric DB ID
        String? foundUid = data["uid"]
            ?.toString(); // Potential String UID/Code (e.g. 31)

        final String? serverCid =
            data["cid"]?.toString() ?? data["cus_id"]?.toString();
        final String? serverName = data["name"]?.toString();

        debugPrint(
          "IDENTIFIED => Record ID: $foundId, Server UID: $foundUid, CID: $serverCid, Current Auth UID: $uid",
        );

        setState(() {
          // IMPORTANT: Do NOT overwrite the login 'uid' (e.g. 78) with record 'id' (92)
          // Most APIs expect the login identifier (78) as 'uid'
          if (foundUid != null && foundUid != "null") {
            serverUidString = foundUid;
          }
          if (serverCid != null &&
              serverCid != "null" &&
              serverCid.isNotEmpty) {
            cid = serverCid;
          }
          if (serverName != null) {
            employeeName = serverName;
            userName = serverName;
          }
          if (data["employee_code"] != null) {
            employeeCode = data["employee_code"].toString();
          }
          if (data["profile_photo"] != null) {
            profilePhoto = data["profile_photo"].toString();
          }
        });

        // Persist synced identifiers (preserving the main UID from login)
        await prefs.setString('cid', cid);
        if (serverUidString != null) {
          await prefs.setString('server_uid', serverUidString!);
        }
        if (foundId != null) {
          await prefs.setString('employee_table_id', foundId);
        }
        if (employeeName != null) await prefs.setString('name', employeeName!);
        if (employeeCode != null) {
          await prefs.setString('employee_code', employeeCode!);
        }
        if (profilePhoto.isNotEmpty) {
          await prefs.setString('profile_photo', profilePhoto);
        }
      } else {
        debugPrint("DETAILS SYNC FAILED => ${res["error_msg"]}");
      }
    } catch (e) {
      debugPrint("Error in _loadEmployeeData sync: $e");
    }
  }

  Future<void> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }
      debugPrint("Device ID: $deviceId");
    } catch (e) {
      debugPrint("Error getting device ID: $e");
      deviceId = "unknown";
    }
  }

  Future<void> _fetchAttendanceSummary() async {
    if (!mounted) return;
    setState(() {
      isHistoryLoading = false;
      attendanceHistory = {};
      daysWorked = 0;
      weeklyDaysWorked = 0;
    });
  }


  Future<void> _fetchLeaveStatistics() async {
    if (!mounted) return;
    setState(() {
      leaveTakenStr = "0";
      lopTakenStr = "0";
    });
  }

  /// Handle Break In API Call
  Future<void> handleBreakIn() async {
    setState(() {
      breakSwitch = true;
      currentBreakInTime = DateTime.now();
      breakDuration = Duration.zero;
    });
    startBreakTimer();
  }

  /// Handle Break Out API Call
  Future<void> handleBreakOut() async {
    setState(() => breakSwitch = false);
    stopBreakTimer();
  }

  void startBreakTimer() {
    breakTimer?.cancel();
    breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && currentBreakInTime != null) {
        setState(() {
          breakDuration = DateTime.now().difference(currentBreakInTime!);
        });
      }
    });
  }

  void stopBreakTimer() {
    breakTimer?.cancel();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _showBreakPurposeDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F6F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        "assets/cup.png",
                        width: 32,
                        height: 32,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Start Break",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Please specify the purpose of your break before starting.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  "Break Purpose",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: purposeController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF00A79D)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF00A79D),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Color(0xFF00A79D)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (purposeController.text.trim().isNotEmpty) {
                            setState(() {
                              breakPurpose = purposeController.text.trim();
                            });
                            Navigator.pop(context);
                            handleBreakIn();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a purpose"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A79D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          "Start Break",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBreakReportDialog() async {
    bool initiallyFetchedForDialog = false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;

            // Trigger fetch once for the dialog and refresh UI through setDialogState
            if (!initiallyFetchedForDialog) {
              initiallyFetchedForDialog = true;
              Future.microtask(() {
                _fetchBreakHistory(
                  onUpdate: () {
                    if (context.mounted) setDialogState(() {});
                  },
                );
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: h * 0.85,
                  maxWidth: w * 0.95,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F6F4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                "assets/cup.png",
                                width: 32,
                                height: 32,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Break Report",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "View all your breaks taken today",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      // Summary Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F6F4),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00A79D,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/cup.png",
                                          width: 20,
                                          height: 20,
                                          color: const Color(0xFF00A79D),
                                        ),
                                        const SizedBox(width: 6),
                                        const Flexible(
                                          child: Text(
                                            "Total Breaks",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        "${breakHistory.length}",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00A79D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF9800,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.access_time,
                                          size: 20,
                                          color: Color(0xFFFF9800),
                                        ),
                                        SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            "Total Time",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _formatDurationHoursMinutes(
                                          totalBreakDuration,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Break History Section
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Break History",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Break History List
                      isBreakHistoryLoading
                          ? const Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(),
                            )
                          : breakHistory.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/cup.png",
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "No breaks taken yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Your break history will appear here",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: breakHistory.length,
                              itemBuilder: (context, index) {
                                final entry = breakHistory[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6F6F4),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Image.asset(
                                          "assets/cup.png",
                                          width: 20,
                                          height: 20,
                                          color: const Color(0xFF00A79D),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.purpose,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 4,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.login,
                                                      size: 14,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatTime(
                                                        entry.breakInTime,
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.logout,
                                                      size: 14,
                                                      color: Colors.red,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      entry.breakOutTime != null
                                                          ? _formatTime(
                                                              entry
                                                                  .breakOutTime!,
                                                            )
                                                          : "--:--",
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3E0),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            _formatDurationHoursMinutes(
                                              entry.duration,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFFF9800),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatDurationHoursMinutes(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}m";
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: const Color(0xffEFEFEF),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final Color teal = const Color(0xFF00A79D);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A79D),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Attendance',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: h * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // DEBUG LABEL
              timeTrackingCard(w, h),
              if (breakSwitch) ...[
                SizedBox(height: h * 0.02),
                onBreakInfoCard(w, h),
              ],
              SizedBox(height: h * 0.02),
              Center(
                child: const Text(
                  "Make sure your location and camera \npermissions are enabled",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
              greetingCard(w, h),
              SizedBox(height: h * 0.02),
              breakReportCard(w, h),
              SizedBox(height: h * 0.015),
              todayWorkProgressCard(w, h),
              SizedBox(height: h * 0.015),
              attendanceProgressCard(w, h, teal),
              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget onBreakInfoCard(double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6), // Light yellow background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9D773), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/cup.png", width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "On Break",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Purpose: $breakPurpose",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const Text(
                  "Click the toggle above to end your break",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget breakReportCard(double w, double h) {
    return GestureDetector(
      onTap: () {
        _fetchBreakHistory();
        _showBreakReportDialog();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.018,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF1F1F1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xffE6F6F4),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset("assets/cup.png", width: 22, height: 22),
                ),
                SizedBox(width: w * 0.03),
                const Text(
                  "Break Report",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Icon(
              Icons.trending_up_outlined,
              size: 22,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget todayWorkProgressCard(double w, double h) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MarketingAttendanceScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: h * 0.018,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF1F1F1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xffE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xff2196F3),
                      size: 26,
                    ),
                  ),
                  SizedBox(width: w * 0.03),
                  const Flexible(
                    child: Text(
                      "Today Work Progress Report",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.trending_up_outlined,
              size: 22,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget timeTrackingCard(double w, double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset("assets/time.png", width: 26, height: 26),
            SizedBox(width: w * 0.02),
            const Text(
              "Time Tracking",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
        SizedBox(height: h * 0.02),
        if (isTodayFinished)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Your attendance for today is completed!",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          if (!isCheckedIn)
            checkInOutButton(
              label: "Attendance In",
              color: const Color(0xFF4CAF50),
              borderColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
              icon: Icons.login,
              w: w,
              h: h,
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckInVerificationScreen(),
                  ),
                );

                if (result == true) {
                  setState(() {
                    isCheckedIn = true;
                  });
                }
              },
            ),
          if (isCheckedIn)
            checkInOutButton(
              label: "Attendance out",
              color: const Color(0xFFF44336),
              borderColor: const Color(0xFFF44336),
              icon: Icons.logout,
              w: w,
              h: h,
              onTap: () async {
                if (breakSwitch) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please end your break before checking out',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckOutVerificationScreen(),
                  ),
                );

                if (result == true) {
                  final prefs = await SharedPreferences.getInstance();
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  await prefs.setBool('isCheckedIn', false);
                  await prefs.setString('last_checkout_date', today);

                  setState(() {
                    isCheckedIn = false;
                    isTodayFinished = true;
                    if (breakSwitch) {
                      breakSwitch = false;
                      stopBreakTimer();
                    }
                  });
                }
              },
            ),
        ],
        SizedBox(height: h * 0.014),
        breakButton(w, h),
      ],
    );
  }

  Widget checkInOutButton({
    required String label,
    required Color color,
    required Color borderColor,
    required IconData icon,
    required double w,
    required double h,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: color.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xff90BD83),
            ),
          ],
        ),
      ),
    );
  }

  Widget breakButton(double w, double h) {
    return SizedBox(
      height: h * 0.058,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isLoading
              ? Colors.grey.shade400
              : (!isCheckedIn ? Colors.grey.shade400 : const Color(0xff727272)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading
            ? null
            : () async {
                debugPrint(
                  "Break Button Pressed. Current isCheckedIn: $isCheckedIn",
                );
                debugPrint(
                  "Break Button Pressed. Current isCheckedIn: $isCheckedIn, breakSwitch: $breakSwitch",
                );
                if (!isCheckedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You must check in first before taking a break!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (breakSwitch) {
                  await handleBreakOut();
                } else {
                  await _showBreakPurposeDialog();
                }
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Image.asset(
                      "assets/cup.png",
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      isLoading
                          ? "Processing..."
                          : breakSwitch
                          ? "Break Out (${formatDuration(breakDuration)})"
                          : "Break In (${formatDuration(breakDuration)})",
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Switch(
                value: breakSwitch,
                activeThumbColor: const Color(0xffD9D9D9),
                activeTrackColor: const Color(0xff1B2C61),
                inactiveThumbColor: const Color(0xffD9D9D9),
                inactiveTrackColor: Colors.grey.shade500,
                onChanged: (value) async {
                  debugPrint(
                    "Break Switch Changed: $value, isCheckedIn: $isCheckedIn",
                  );
                  debugPrint(
                    "Break Switch Changed: $value, isCheckedIn: $isCheckedIn",
                  );
                  if (!isCheckedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You must check in first before taking a break!',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (value) {
                    await _showBreakPurposeDialog();
                  } else {
                    await handleBreakOut();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget greetingCard(double w, double h) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffEFEFEF),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.all(w * 0.04),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: w * 0.08,
                backgroundImage: profilePhoto.isNotEmpty
                    ? NetworkImage(profilePhoto)
                    : null,
                child: profilePhoto.isEmpty
                    ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : "?")
                    : null,
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good Morning, $userName!",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Ready to make today productive?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Day Shift",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isTodayFinished
                                ? Colors.blue
                                : (isCheckedIn ? Colors.green : Colors.grey),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTodayFinished
                              ? "Completed"
                              : (isCheckedIn ? "Checked In" : "Not Checked In"),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isTodayFinished
                                ? Colors.blue
                                : (isCheckedIn ? Colors.green : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          shiftBreakInfo(w, h),
        ],
      ),
    );
  }

  Widget shiftBreakInfo(double w, double h) {
    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Current Shift",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Day Shift",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  isCheckedIn ? "09:00 - 18:00" : "--:--",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Break Duration",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.05,
                    vertical: h * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${formatDuration(breakDuration)} / 1 hr",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget attendanceProgressCard(double w, double h, Color teal) {
    final now = DateTime.now();

    // ----- Weekly Calculation (Mon–today) -----
    final int weekDaysElapsed = now.weekday.clamp(1, 5); // Mon–Fri
    final int weeklyPresent = weeklyDaysWorked.clamp(0, weekDaysElapsed);
    final double weekProgress = weekDaysElapsed > 0
        ? (weeklyPresent / weekDaysElapsed).clamp(0.0, 1.0)
        : 0.0;

    // ----- Monthly Calculation (1st to today) -----
    final int monthDaysElapsed = now.day;
    final int monthlyPresent = daysWorked;
    final double monthProgress = monthDaysElapsed > 0
        ? (monthlyPresent / monthDaysElapsed).clamp(0.0, 1.0)
        : 0.0;

    // Active tab values
    final double progress = selectedTab == 0 ? weekProgress : monthProgress;
    final int daysPresent = selectedTab == 0 ? weeklyPresent : monthlyPresent;
    final int totalDays = selectedTab == 0 ? weekDaysElapsed : monthDaysElapsed;
    final String periodLabel = selectedTab == 0 ? "This Week" : "This Month";

    return Container(
      padding: EdgeInsets.all(w * 0.04),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Attendance Progress",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: h * 0.015),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Row(
              children: [
                Expanded(child: tabButton("Weekly", 0)),
                const SizedBox(width: 10),
                Expanded(child: tabButton("Monthly", 1)),
              ],
            ),
          ),
          SizedBox(height: h * 0.02),
          Row(
            children: [
              Icon(Icons.trending_up_outlined),
              SizedBox(width: 8),
              Text(
                selectedTab == 0
                    ? "This Weekly Progress"
                    : "This Monthly Progress",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          if (selectedTab == 0)
            Row(
              children: [
                Expanded(
                  child: statsBox(
                    "Total Hours",
                    attendanceHistory != null &&
                            attendanceHistory!["total_hours_worked"] != null
                        ? "${attendanceHistory!["total_hours_worked"]}h"
                        : "0h",
                    valueColor: Colors.black,
                  ),
                ),
                SizedBox(width: w * 0.03),
                Expanded(
                  child: statsBox(
                    "Overtime",
                    attendanceHistory != null &&
                            attendanceHistory!["overtime"] != null
                        ? attendanceHistory!["overtime"].toString()
                        : "0h 00m",
                    valueColor: Colors.red,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: monthlyStatBox(
                        "Day Worked",
                        daysWorked.toString(),
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: monthlyStatBox(
                        "Leave Taken",
                        leaveTakenStr,
                        highlight: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: monthlyStatBox(
                        "Unpaid(LOP)",
                        lopTakenStr,
                        highlight: true,
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    Expanded(
                      child: monthlyStatBox(
                        "Overtime",
                        attendanceHistory != null &&
                                attendanceHistory!["monthly_overtime"] != null
                            ? attendanceHistory!["monthly_overtime"].toString()
                            : "0h 00m",
                        highlight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          SizedBox(height: h * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Attendance Progress",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.01),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: teal,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          SizedBox(height: h * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                periodLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$daysPresent/$totalDays days",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                padding: EdgeInsets.symmetric(vertical: h * 0.014),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceHistoryScreen(),
                  ),
                );
              },
              child: const Text(
                "Attendance History",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget monthlyStatBox(String title, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffEFEFEF), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: highlight ? Colors.deepOrange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget tabButton(String text, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selectedTab == index
              ? const Color(0xff26A69A)
              : const Color(0xffC9C9C9),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selectedTab == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget statsBox(
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    final bool isOvertime = title.toLowerCase().contains("overtime");
    final Color finalColor = isOvertime ? Colors.red : valueColor;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffEFEFEF), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value.split(' ')[0],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: finalColor,
                    ),
                  ),
                  if (value.contains(' '))
                    TextSpan(
                      text: " ${value.split(' ')[1]}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: finalColor.withValues(alpha: 0.85),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
