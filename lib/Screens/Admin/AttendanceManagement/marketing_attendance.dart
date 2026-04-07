import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Models/marketing_api.dart';

class MarketingAttendanceScreen extends StatefulWidget {
  const MarketingAttendanceScreen({super.key});

  @override
  State<MarketingAttendanceScreen> createState() =>
      _MarketingAttendanceScreenState();
}

class _MarketingAttendanceScreenState extends State<MarketingAttendanceScreen> {
  List<MarketingAttendanceData> _marketingLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final response = await MarketingApi.fetchMarketingAttendance();
      if (mounted) {
        setState(() {
          _marketingLogs = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching marketing logs: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Marketing Attendance",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLogs,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _marketingLogs.isEmpty
            ? const Center(child: Text("No records found"))
            : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _marketingLogs.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: _buildLiveStatusHeader(),
                    );
                  }
                  return _marketingReportCard(_marketingLogs[index - 1]);
                },
              ),
      ),
    );
  }

  Widget _buildLiveStatusHeader() {
    int active = _marketingLogs.where((l) => l.checkOutTime.isEmpty).length;
    int returned = _marketingLogs
        .where((l) => l.checkOutTime.isNotEmpty)
        .length;
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat("In-Field", "$active", Colors.blue),
          _stat("Total Logs", "${_marketingLogs.length}", Colors.teal),
          _stat("Returned", "$returned", Colors.green),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _marketingReportCard(MarketingAttendanceData log) {
    bool inField = log.checkOutTime.isEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.1),
                ),
                child: Icon(Icons.person, color: Colors.teal, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.employeeName,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: ${log.employeeId} | ${log.date}",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (inField ? Colors.blue : Colors.green).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  inField ? "In-Field" : "Returned",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: inField ? Colors.blue : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Client & Purpose
          Row(
            children: [
              Expanded(
                child: _dataItem(Icons.business, "Client", log.clientName),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _dataItem(
                  Icons.assignment_outlined,
                  "Purpose",
                  log.purposeOfVisit,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Times
          Row(
            children: [
              Expanded(
                child: _dataItem(Icons.login, "Check-In", log.checkInTime),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _dataItem(
                  Icons.logout,
                  "Check-Out",
                  log.checkOutTime.isEmpty ? "--:--" : log.checkOutTime,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Location
          _dataItem(Icons.location_on_outlined, "Visit Location", log.location),

          if (log.remarks.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              "Remarks",
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              log.remarks,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          if (log.attachments != null && log.attachments!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Attachments Available",
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dataItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: Colors.grey.shade400),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          value.isEmpty ? "--" : value,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
