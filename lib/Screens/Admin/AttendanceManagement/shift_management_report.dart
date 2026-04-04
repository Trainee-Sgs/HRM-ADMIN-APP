import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  final List<Map<String, dynamic>> _shifts = [
    {
      "name": "General Shift",
      "timing": "09:00 AM - 06:00 PM",
      "count": 84,
      "color": Colors.blue,
    },
    {
      "name": "Night Shift",
      "timing": "09:00 PM - 06:00 AM",
      "count": 22,
      "color": Colors.indigo,
    },
    {
      "name": "Evening Shift",
      "timing": "02:00 PM - 10:00 PM",
      "count": 18,
      "color": Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _employeeShifts = [
    {"name": "Kavi Priyan", "shift": "General Shift", "id": "EMP001", "dept": "Development"},
    {"name": "Arun Kumar", "shift": "General Shift", "id": "EMP002", "dept": "HR"},
    {"name": "Deepak Raj", "shift": "Night Shift", "id": "EMP004", "dept": "Marketing"},
    {"name": "Santhosh Mani", "shift": "Evening Shift", "id": "EMP003", "dept": "Creative"},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: Text(
            "Shift Management",
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
              Tab(text: "Shift Types"),
              Tab(text: "Assigned Shifts"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildShiftTypes(),
            _buildAssignedShifts(),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftTypes() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _shifts.length,
      itemBuilder: (context, index) {
        final shift = _shifts[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(20.w),
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
            border: Border(left: BorderSide(color: shift['color'], width: 6.w)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift['name'],
                      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      shift['timing'],
                      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    shift['count'].toString(),
                    style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: shift['color']),
                  ),
                  Text("Staffs", style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignedShifts() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _employeeShifts.length,
      itemBuilder: (context, index) {
        final emp = _employeeShifts[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF26A69A).withOpacity(0.1),
              child: Text(emp['name'][0], style: const TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold)),
            ),
            title: Text(emp['name'], style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            subtitle: Text("${emp['id']} | ${emp['dept']}", style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                emp['shift'],
                style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.blueGrey),
              ),
            ),
          ),
        );
      },
    );
  }
}
