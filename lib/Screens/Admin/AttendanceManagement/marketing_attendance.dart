import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketingAttendanceScreen extends StatefulWidget {
  const MarketingAttendanceScreen({super.key});

  @override
  State<MarketingAttendanceScreen> createState() => _MarketingAttendanceScreenState();
}

class _MarketingAttendanceScreenState extends State<MarketingAttendanceScreen> {
  final List<Map<String, dynamic>> _marketingLogs = [
    {
      "name": "Kavi Priyan",
      "id": "MKT001",
      "checkIn": "09:15 AM",
      "status": "In-Field",
      "location": "T. Nagar, Chennai",
      "visits": 4,
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Kavi",
    },
    {
      "name": "Santhosh Mani",
      "id": "MKT003",
      "checkIn": "09:45 AM",
      "status": "In-Field",
      "location": "Velachery, Chennai",
      "visits": 2,
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Santhosh",
    },
    {
       "name": "Arun Kumar",
       "id": "MKT002",
       "checkIn": "09:00 AM",
       "checkOut": "05:30 PM",
       "status": "Returned",
       "location": "Adyar, Chennai",
       "visits": 8,
       "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Arun",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Marketing Attendance",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildLiveStatusHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _marketingLogs.length,
              itemBuilder: (context, index) => _marketingReportCard(_marketingLogs[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusHeader() {
    int active = _marketingLogs.where((l) => l['status'] == 'In-Field').length;
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat("Active In-Field", "$active", Colors.blue),
          _stat("Total Visits", "14", Colors.teal),
          _stat("Returned", "1", Colors.green),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _marketingReportCard(Map<String, dynamic> log) {
    bool inField = log['status'] == 'In-Field';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(log['photo']),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['name'],
                      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "ID: ${log['id']}",
                      style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (inField ? Colors.blue : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  log['status'],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info(Icons.login, "Check In", log['checkIn']),
              _info(Icons.location_on, "Last Location", log['location']),
              _info(Icons.storefront, "Visits", "${log['visits']}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade400),
          SizedBox(height: 4.h),
          Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey), textAlign: TextAlign.center),
          Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
