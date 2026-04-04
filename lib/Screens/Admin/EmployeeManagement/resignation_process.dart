import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ResignationProcessScreen extends StatefulWidget {
  const ResignationProcessScreen({super.key});

  @override
  State<ResignationProcessScreen> createState() => _ResignationProcessScreenState();
}

class _ResignationProcessScreenState extends State<ResignationProcessScreen> {
  final List<Map<String, dynamic>> _resignationRequests = [
    {
      "name": "Kavi Priyan",
      "id": "EMP001",
      "dept": "Development",
      "resignDate": "01 Apr 2024",
      "lastDay": "01 May 2024",
      "reason": "Better opportunity in MNC",
      "status": "Pending",
      "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Kavi",
    },
    {
       "name": "Arun Kumar",
       "id": "EMP002",
       "dept": "HR",
       "resignDate": "25 Mar 2024",
       "lastDay": "25 Apr 2024",
       "reason": "Relocation to hometown",
       "status": "Approved",
       "photo": "https://api.dicebear.com/7.x/avataaars/png?seed=Arun",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Resignation Process",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _resignationRequests.length,
        itemBuilder: (context, index) => _buildResignationCard(_resignationRequests[index]),
      ),
    );
  }

  Widget _buildResignationCard(Map<String, dynamic> request) {
    bool isPending = request['status'] == 'Pending';
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 22.r, backgroundImage: NetworkImage(request['photo'])),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request['name'], style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    Text("${request['id']} | ${request['dept']}", style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (isPending ? Colors.orange : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  request['status'],
                  style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isPending ? Colors.orange : Colors.green),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info("Applied Date", request['resignDate']),
              _info("Last Working Day", request['lastDay']),
            ],
          ),
          SizedBox(height: 12.h),
          Text("Reason for Resignation:", style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(request['reason'], style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87)),
          if (isPending) ...[
            SizedBox(height: 16.h),
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
                    child: Text("Hold", style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
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
          ]
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey)),
        Text(value, style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
