import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OverallAttendanceScreen extends StatefulWidget {
  const OverallAttendanceScreen({super.key});

  @override
  State<OverallAttendanceScreen> createState() => _OverallAttendanceScreenState();
}

class _OverallAttendanceScreenState extends State<OverallAttendanceScreen> {
  final List<Map<String, dynamic>> _attendanceData = [
    {
      "name": "Kavi Priyan",
      "id": "EMP001",
      "checkIn": "09:05 AM",
      "breakIn": "01:30 PM",
      "breakOut": "02:15 PM",
      "checkOut": "--:--",
      "status": "Present",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Kavi",
    },
    {
      "name": "Arun Kumar",
      "id": "EMP002",
      "checkIn": "08:55 AM",
      "breakIn": "01:10 PM",
      "breakOut": "01:55 PM",
      "checkOut": "06:05 PM",
      "status": "Completed",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Arun",
    },
    {
      "name": "Santhosh Mani",
      "id": "EMP003",
      "checkIn": "09:30 AM",
      "breakIn": "02:00 PM",
      "breakOut": "02:45 PM",
      "checkOut": "--:--",
      "status": "Present",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Santhosh",
    },
    {
      "name": "Deepak Raj",
      "id": "EMP004",
      "checkIn": "09:12 AM",
      "breakIn": "--:--",
      "breakOut": "--:--",
      "checkOut": "--:--",
      "status": "On Break",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Deepak",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Overall Attendance Report",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _attendanceData.length,
              itemBuilder: (context, index) => _attendanceCard(_attendanceData[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryStat("Present", "116", Colors.green),
          _summaryStat("Absent", "012", Colors.red),
          _summaryStat("On Break", "005", Colors.orange),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
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

  Widget _attendanceCard(Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(15.w),
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
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: NetworkImage(data['photo']),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ID: ${data['id']}",
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (data['status'] == 'Completed' ? Colors.green : (data['status'] == 'On Break' ? Colors.orange : Colors.blue)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  data['status'],
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: data['status'] == 'Completed' ? Colors.green : (data['status'] == 'On Break' ? Colors.orange : Colors.blue),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeCol("Check In", data['checkIn'], Icons.login),
              _timeCol("Break In", data['breakIn'], Icons.coffee_outlined),
              _timeCol("Break Out", data['breakOut'], Icons.restaurant),
              _timeCol("Check Out", data['checkOut'], Icons.logout),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeCol(String label, String time, IconData icon) {
    bool isPending = time == "--:--";
    return Column(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade400),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 9.sp, color: Colors.grey),
        ),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: isPending ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
