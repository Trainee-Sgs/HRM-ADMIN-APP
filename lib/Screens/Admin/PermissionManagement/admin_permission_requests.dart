import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPermissionRequestsScreen extends StatefulWidget {
  const AdminPermissionRequestsScreen({super.key});

  @override
  State<AdminPermissionRequestsScreen> createState() => _AdminPermissionRequestsScreenState();
}

class _AdminPermissionRequestsScreenState extends State<AdminPermissionRequestsScreen> {
  final List<Map<String, dynamic>> _permissionRequests = [
    {
      "id": "1",
      "name": "Kavi Priyan",
      "time": "10:00 AM - 11:30 AM (1.5h)",
      "reason": "Bank related work",
      "appliedDate": "04-04-2026",
      "status": "Pending",
    },
    {
      "id": "2",
      "name": "Santhosh Mani",
      "time": "02:00 PM - 03:00 PM (1h)",
      "reason": "Personal work",
      "appliedDate": "03-04-2026",
      "status": "Pending",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Permission Requests",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: _permissionRequests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(_permissionRequests[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Total", "${_permissionRequests.length}", Colors.blue),
          _summaryItem("Pending", "${_permissionRequests.where((p) => p['status'] == 'Pending').length}", Colors.orange),
          _summaryItem("Today", "1", Colors.green),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final TextEditingController rejectReasonController = TextEditingController();

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
              CircleAvatar(
                backgroundColor: const Color(0xFFE0F7FA),
                child: Text(request['name'][0], style: const TextStyle(color: Color(0xFF00ACC1), fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request['name'], style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                    Text("Permission Request", style: GoogleFonts.poppins(fontSize: 12.sp, color: const Color(0xFF00ACC1), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Text(request['appliedDate'], style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
            ],
          ),
          const Divider(height: 24),
          _rowInfo(Icons.access_time_outlined, request['time']),
          SizedBox(height: 8.h),
          _rowInfo(Icons.info_outline, request['reason']),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(context, request, rejectReasonController),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text("Reject", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showApproveDialog(context, request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text("Approve", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, Map<String, dynamic> request) {
    String selectedRole = "MD";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Approve Permission", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Approver Role:", style: GoogleFonts.poppins(fontSize: 13.sp)),
              SizedBox(height: 12.h),
              _buildRoleDropdown(selectedRole, (val) => setDialogState(() => selectedRole = val!)),
              SizedBox(height: 16.h),
              Text("Are you sure you want to approve ${request['name']}'s permission?", style: GoogleFonts.poppins(fontSize: 14.sp)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permission Approved by $selectedRole!")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Approve", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, Map<String, dynamic> request, TextEditingController controller) {
    String selectedRole = "MD";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Reject Permission", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Role to Reject:", style: GoogleFonts.poppins(fontSize: 13.sp)),
              SizedBox(height: 8.h),
              _buildRoleDropdown(selectedRole, (val) => setDialogState(() => selectedRole = val!)),
              SizedBox(height: 16.h),
              Text("Reason for Rejection:", style: GoogleFonts.poppins(fontSize: 13.sp)),
              SizedBox(height: 8.h),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type reason here...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permission Rejected by $selectedRole: ${controller.text}")));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Reject", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(String current, Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          style: GoogleFonts.poppins(color: const Color(0xFF26A69A), fontWeight: FontWeight.w600),
          items: ["MD", "HR", "TL"].map((String type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _rowInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade700))),
      ],
    );
  }
}
