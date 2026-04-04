import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BreakReportScreen extends StatefulWidget {
  const BreakReportScreen({super.key});

  @override
  State<BreakReportScreen> createState() => _BreakReportScreenState();
}

class _BreakReportScreenState extends State<BreakReportScreen> {
  final List<Map<String, dynamic>> _breakData = [
    {
      "name": "Kavi Priyan",
      "id": "EMP001",
      "breakIn": "01:30 PM",
      "breakOut": "02:15 PM",
      "duration": "45 mins",
      "status": "Returned",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Kavi",
    },
    {
      "name": "Deepak Raj",
      "id": "EMP004",
      "breakIn": "02:10 PM",
      "breakOut": "--:--",
      "duration": "35 mins",
      "status": "Currently on Break",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Deepak",
    },
    {
      "name": "Arun Kumar",
      "id": "EMP002",
      "breakIn": "01:10 PM",
      "breakOut": "01:55 PM",
      "duration": "45 mins",
      "status": "Returned",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Arun",
    },
    {
      "name": "Santhosh Mani",
      "id": "EMP003",
      "breakIn": "02:00 PM",
      "breakOut": "02:45 PM",
      "duration": "45 mins",
      "status": "Returned",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Santhosh",
    },
  ];

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
      body: Column(
        children: [
          _buildBreakSummary(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _breakData.length,
              itemBuilder: (context, index) => _breakCard(_breakData[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakSummary() {
    int currentlyOnBreak = _breakData.where((b) => b['status'] == 'Currently on Break').length;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryCard("Currently on Break", "$currentlyOnBreak", Colors.orange),
          _summaryCard("Total Returns", "${_breakData.length - currentlyOnBreak}", Colors.green),
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

  Widget _breakCard(Map<String, dynamic> data) {
    bool onBreak = data['status'] == 'Currently on Break';
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
                      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold),
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
                  color: (onBreak ? Colors.orange : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  data['status'],
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: onBreak ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailItem("Break In", data['breakIn'], Icons.coffee),
              _detailItem("Break Out", data['breakOut'], Icons.restaurant),
              _detailItem("Duration", data['duration'], Icons.timer),
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
