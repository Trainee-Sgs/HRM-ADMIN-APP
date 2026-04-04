import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendancePresentReportScreen extends StatefulWidget {
  const AttendancePresentReportScreen({super.key});

  @override
  State<AttendancePresentReportScreen> createState() => _AttendancePresentReportScreenState();
}

class _AttendancePresentReportScreenState extends State<AttendancePresentReportScreen> {
  final List<Map<String, dynamic>> _generalStaff = [
    {"name": "Kavi Priyan", "id": "EMP001", "dept": "Development", "time": "09:05 AM", "type": "Office"},
    {"name": "Arun Kumar", "id": "EMP002", "dept": "HR", "time": "08:55 AM", "type": "Office"},
    {"name": "Santhosh Mani", "id": "EMP003", "dept": "Creative", "time": "09:30 AM", "type": "Office"},
    {"name": "Deepak Raj", "id": "EMP004", "dept": "QA", "time": "09:12 AM", "type": "Office"},
  ];

  final List<Map<String, dynamic>> _marketingStaff = [
    {"name": "Vijay Sethu", "id": "MKT001", "dept": "Marketing", "time": "09:15 AM", "type": "Field"},
    {"name": "Madhavan R", "id": "MKT002", "dept": "Sales", "time": "09:40 AM", "type": "Field"},
    {"name": "Suriya Sivakumar", "id": "MKT003", "dept": "Branding", "time": "09:00 AM", "type": "Field"},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: Text(
            "Present Staff Report",
            style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF26A69A),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "General Staff"),
              Tab(text: "Marketing Staff"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStaffList(_generalStaff),
            _buildStaffList(_marketingStaff),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffList(List<Map<String, dynamic>> staff) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: staff.length,
      itemBuilder: (context, index) {
        final person = staff[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF26A69A).withOpacity(0.1),
                child: Text(
                  person['name'][0],
                  style: const TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person['name'],
                      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${person['id']} | ${person['dept']}",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    person['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      person['type'],
                      style: GoogleFonts.poppins(fontSize: 9.sp, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
