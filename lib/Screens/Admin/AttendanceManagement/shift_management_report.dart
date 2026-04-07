import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Models/attendance_api.dart';

class ShiftManagementScreen extends StatefulWidget {
  const ShiftManagementScreen({super.key});

  @override
  State<ShiftManagementScreen> createState() => _ShiftManagementScreenState();
}

class _ShiftManagementScreenState extends State<ShiftManagementScreen> {
  List<ShiftTypeData> _shiftTypes = [];
  List<ShiftAllocationData> _shiftAllocations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShiftsAndAllocations();
  }

  Future<void> _fetchShiftsAndAllocations() async {
    setState(() => _isLoading = true);
    try {
      final typesResponse = await AttendanceApi.fetchShiftTypes();
      final allocationsResponse = await AttendanceApi.fetchShiftAllocations();
      if (mounted) {
        setState(() {
          _shiftTypes = typesResponse.data;
          _shiftAllocations = allocationsResponse.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching records: $e")),
        );
      }
    }
  }

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_shiftTypes.isEmpty) {
      return const Center(child: Text("No shift types found"));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _shiftTypes.length,
      itemBuilder: (context, index) {
        final shift = _shiftTypes[index];
        final List<Color> colors = [Colors.blue, Colors.indigo, Colors.orange, Colors.teal, Colors.purple];
        final Color cardColor = colors[index % colors.length];

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
            border: Border(left: BorderSide(color: cardColor, width: 6.w)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.shiftName.isNotEmpty ? shift.shiftName : "Unnamed Shift",
                      style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${shift.startTime} - ${shift.endTime}",
                      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
                    ),
                    if (shift.breakDuration.isNotEmpty)
                      Text(
                        "Break: ${shift.breakDuration}",
                        style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.teal),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    shift.shiftCode,
                    style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: cardColor),
                  ),
                  Text("Code", style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignedShifts() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_shiftAllocations.isEmpty) {
      return const Center(child: Text("No assigned shifts found"));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _shiftAllocations.length,
      itemBuilder: (context, index) {
        final emp = _shiftAllocations[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF26A69A).withOpacity(0.1),
              child: Text(
                emp.employeeName.isNotEmpty ? emp.employeeName[0] : "?",
                style: const TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              emp.employeeName.isNotEmpty ? emp.employeeName : "Unknown Employee",
              style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${emp.employeeCode} | ${emp.department}",
                  style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
                ),
                Text(
                  "Date: ${emp.allocateDate}",
                  style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.teal),
                ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                emp.shiftType.isNotEmpty ? emp.shiftType : "Not Set",
                style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.blueGrey),
              ),
            ),
          ),
        );
      },
    );
  }
}
