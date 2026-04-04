import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MobileAttendanceScreen extends StatefulWidget {
  const MobileAttendanceScreen({super.key});

  @override
  State<MobileAttendanceScreen> createState() => _MobileAttendanceScreenState();
}

class _MobileAttendanceScreenState extends State<MobileAttendanceScreen> {
  final List<Map<String, dynamic>> _mobileLogs = [
    {
      "name": "Kavi Priyan",
      "id": "EMP001",
      "checkIn": "09:05 AM",
      "checkOut": "--:--",
      "location": "Chennai, TN",
      "device": "Android (Pixel 7)",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Kavi",
      "selfie": "https://api.dicebear.com/7.x/avataaars/png?seed=Kavi",
    },
    {
      "name": "Arun Kumar",
      "id": "EMP002",
      "checkIn": "08:55 AM",
      "checkOut": "06:05 PM",
      "location": "Coimbatore, TN",
      "device": "iOS (iPhone 14)",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Arun",
      "selfie": "https://api.dicebear.com/7.x/avataaars/png?seed=Arun",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Mobile Attendance Log",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _mobileLogs.length,
        itemBuilder: (context, index) => _mobileLogCard(_mobileLogs[index]),
      ),
    );
  }

  Widget _mobileLogCard(Map<String, dynamic> log) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(log['selfie'], width: 60.w, height: 60.w, fit: BoxFit.cover),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['name'],
                      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12.sp, color: Colors.blueGrey),
                        SizedBox(width: 4.w),
                        Text(log['location'], style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.smartphone, size: 12.sp, color: Colors.blueGrey),
                        SizedBox(width: 4.w),
                        Text(log['device'], style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _timeCol("Check In", log['checkIn'], Colors.green),
              SizedBox(width: 25.w),
              _timeCol("Check Out", log['checkOut'], Colors.red),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: Colors.blueGrey,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text("Map", style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text("Reject", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text("Approve", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeCol(String label, String time, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey)),
        Text(time, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
