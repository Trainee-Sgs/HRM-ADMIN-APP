import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Models/attendance_api.dart';
import 'package:intl/intl.dart';

class BreakReportScreen extends StatefulWidget {
  const BreakReportScreen({super.key});

  @override
  State<BreakReportScreen> createState() => _BreakReportScreenState();
}

class _BreakReportScreenState extends State<BreakReportScreen> {
  List<BreakReportData> _breakRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBreakData();
  }

  Future<void> _fetchBreakData() async {
    setState(() => _isLoading = true);
    try {
      final response = await AttendanceApi.fetchBreakReport();
      if (mounted) {
        setState(() {
          _breakRecords = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching break report: $e")),
        );
      }
    }
  }

  String _formatDateTime(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return "--:--";
    try {
      DateTime dt = DateTime.parse(dateTimeStr);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _calculateDuration(String start, String end) {
    if (start.isEmpty || end.isEmpty) return "--";
    try {
      DateTime dtStart = DateTime.parse(start);
      DateTime dtEnd = DateTime.parse(end);
      Duration diff = dtEnd.difference(dtStart);
      if (diff.inMinutes < 60) {
        return "${diff.inMinutes} mins";
      } else {
        return "${diff.inHours}h ${diff.inMinutes % 60}m";
      }
    } catch (e) {
      return "--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Break Report",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBreakData,
        child: Column(
          children: [
            _buildBreakSummary(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _breakRecords.isEmpty
                      ? const Center(child: Text("No break records found"))
                      : ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _breakRecords.length,
                          itemBuilder: (context, index) =>
                              _breakCard(_breakRecords[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakSummary() {
    int currentlyOnBreak = _breakRecords.where((b) => b.breakOut.isEmpty).length;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryCard("On Break", "$currentlyOnBreak", Colors.orange),
          _summaryCard("Total Entries", "${_breakRecords.length}", Colors.green),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _breakCard(BreakReportData data) {
    bool onBreak = data.breakOut.isEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.teal.withOpacity(0.1),
                ),
                child: Icon(Icons.person, color: Colors.teal, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.employeeName,
                      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "ID: ${data.employeeCode}",
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (onBreak ? Colors.orange : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  onBreak ? "On Break" : "Returned",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: onBreak ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          if (data.reason.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              "Reason: ${data.reason}",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.blueGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailItem("Break In", _formatDateTime(data.breakIn), Icons.coffee),
              _detailItem("Break Out", _formatDateTime(data.breakOut), Icons.restaurant),
              _detailItem("Duration", _calculateDuration(data.breakIn, data.breakOut), Icons.timer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade400),
        SizedBox(height: 4.h),
        Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
