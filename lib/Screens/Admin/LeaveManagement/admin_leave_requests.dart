import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Models/leave_api.dart';

class AdminLeaveRequestsScreen extends StatefulWidget {
  const AdminLeaveRequestsScreen({super.key});

  @override
  State<AdminLeaveRequestsScreen> createState() =>
      _AdminLeaveRequestsScreenState();
}

class _AdminLeaveRequestsScreenState extends State<AdminLeaveRequestsScreen> {
  List<LeaveRequestData>? _allRequests;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await LeaveApi.fetchLeaveRequests();
      setState(() {
        // Filter to only show PENDING requests in this screen
        _allRequests = response.data.where((r) {
          final s = r.status?.toLowerCase();
          return s == 'pending' || s == null || s.isEmpty;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching leave requests: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Leave Requests",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading && _allRequests == null
          ? const Center(child: CircularProgressIndicator())
          : _allRequests == null || _allRequests!.isEmpty
          ? const Center(child: Text("No leave requests found."))
          : Column(
              children: [
                _buildSummaryBar(_allRequests!),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _allRequests!.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(_allRequests![index], index);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryBar(List<LeaveRequestData> requests) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Total", "${requests.length}", Colors.blue),
          _summaryItem(
            "Pending",
            "${requests.where((r) => r.status?.toLowerCase() == 'pending').length}",
            Colors.orange,
          ),
          _summaryItem("Recent", "${requests.isEmpty ? 0 : 1}", Colors.green),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
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

  Widget _buildRequestCard(LeaveRequestData request, int index) {
    final TextEditingController rejectReasonController =
        TextEditingController();

    String dateRange =
        "${_formatDate(request.leaveStartDate)} - ${_formatDate(request.leaveEndDate)}";
    if (request.totalDays != null && request.totalDays!.isNotEmpty) {
      dateRange += " (${request.totalDays} Days)";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE0F2F1),
                child: Text(
                  request.employeeName.isNotEmpty
                      ? request.employeeName[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.employeeName,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      request.leaveType,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: const Color(0xFF26A69A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    request.appliedDate ?? "N/A",
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                  if (request.status != null)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          request.status!,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        request.status!,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: _getStatusColor(request.status!),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          _rowInfo(Icons.calendar_month_outlined, dateRange),
          SizedBox(height: 8.h),
          _rowInfo(
            Icons.notes_outlined,
            request.reason ?? "No reason provided",
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(
                    context,
                    request,
                    rejectReasonController,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Reject",
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approveRequest(context, request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Approve",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accept':
      case 'approved':
        return Colors.green;
      case 'reject':
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _approveRequest(BuildContext context, LeaveRequestData request) async {
    final response = await LeaveApi.updateLeaveStatus(
      id: request.id.toString(),
      uid: request.uid.toString(),
      status: "accept",
    );

    if (response['error'] == false) {
      if (mounted) {
        setState(() {
          _allRequests?.removeWhere((r) => r.id == request.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Leave Approved for ${request.employeeName}!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        final errorMsg =
            response['debug'] ?? response['message'] ?? "Update failed";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to approve: $errorMsg"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showRejectDialog(
    BuildContext context,
    LeaveRequestData request,
    TextEditingController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Reject Request",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reason for Rejection:",
              style: GoogleFonts.poppins(fontSize: 13.sp),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Type reason here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await LeaveApi.updateLeaveStatus(
                id: request.id.toString(),
                uid: request.uid.toString(),
                status: "reject",
                rejectReason: controller.text.trim(),
              );

              if (mounted) {
                Navigator.pop(context);
                if (response['error'] == false) {
                  setState(() {
                    _allRequests?.removeWhere((r) => r.id == request.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Request Rejected: ${controller.text}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  final errorMsg =
                      response['debug'] ??
                      response['message'] ??
                      "Update failed";
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to reject: $errorMsg"),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _rowInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
