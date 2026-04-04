import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marketing_attendance.dart';
import 'break_report.dart';
import 'shift_management_report.dart';
import 'mobile_attendance_report.dart';
import 'overall_attendance_report.dart';
import 'attendance_present_report.dart';

class AttendanceManagementScreen extends StatelessWidget {
  AttendanceManagementScreen({super.key});

  final List<Map<String, dynamic>> attendanceFeatures = [
    {
      "title": "Break Report",
      "icon": Icons.coffee_outlined,
      "color": const Color(0xFFE3F2FD),
      "target": "BreakReportScreen",
    },
    {
      "title": "Shift Types & Allocation",
      "icon": Icons.access_time_outlined,
      "color": const Color(0xFFE8F5E9),
      "target": "ShiftManagementScreen",
    },
    {
      "title": "Mobile Attendance Report",
      "icon": Icons.phone_android_outlined,
      "color": const Color(0xFFFFF3E0),
      "target": "MobileAttendanceScreen",
    },
    {
      "title": "Overall Attendance",
      "icon": Icons.groups_outlined,
      "color": const Color(0xFFE0F7FA),
      "target": "OverallAttendanceScreen",
    },
    {
      "title": "Attendance Status",
      "icon": Icons.fact_check_outlined,
      "color": const Color(0xFFF1F8E9),
    },
    {
      "title": "Marketing",
      "icon": Icons.campaign_outlined,
      "color": const Color(0xFFFFF9DB),
      "target": "MarketingAttendanceScreen",
    },
    {
      "title": "Attendance Reports",
      "icon": Icons.description_outlined,
      "color": const Color(0xFFE7F5FF),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Attendance Management",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: attendanceFeatures.length,
        itemBuilder: (context, index) {
          final item = attendanceFeatures[index];
          return _buildFeatureItem(context, item);
        },
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: item['color'],
            shape: BoxShape.circle,
          ),
          child: Icon(
            item['icon'],
            color: const Color(0xFF263238),
            size: 22.sp,
          ),
        ),
        title: Text(
          item['title'],
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.black38,
          size: 14.sp,
        ),
        onTap: () {
          if (item['target'] == "BreakReportScreen") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BreakReportScreen(),
              ),
            );
          } else if (item['target'] == "ShiftManagementScreen") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShiftManagementScreen(),
              ),
            );
          } else if (item['target'] == "MobileAttendanceScreen") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MobileAttendanceScreen(),
              ),
            );
          } else if (item['target'] == "OverallAttendanceScreen") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OverallAttendanceScreen(),
              ),
            );
          } else if (item['target'] == "MarketingAttendanceScreen") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarketingAttendanceScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}
