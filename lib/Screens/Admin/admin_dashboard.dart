import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/bottom_nav_bar.dart';
import '../../Widgets/drawer_screen.dart';
import 'AttendanceManagement/attendance_screen.dart';
import 'Chat/chat_groups.dart';
import 'PayrollManagement/admin_payroll_management.dart';

class AdminDashboard extends StatefulWidget {
  final VoidCallback? onBackToHrm;
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const AdminDashboard({super.key, this.onBackToHrm, this.isEmbedded = false, this.scaffoldKey});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  /// BODIES FOR NAVIGATION
  late final List<Widget> _bodies;

  @override
  void initState() {
    super.initState();
    _bodies = [
      _buildHomeBody(),
      const AttendanceScreen(),
      const AdminPayrollManagementScreen(),
      const ChatGroupScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveKey = widget.scaffoldKey ?? _scaffoldKey;
    return Scaffold(
      key: effectiveKey,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: !widget.isEmbedded,
      appBar: (widget.isEmbedded || _currentIndex != 0) ? null : _buildAppBar(),
      drawer: AdminDrawer(onBackToHrm: widget.onBackToHrm),
      body: IndexedStack(index: _currentIndex, children: _bodies),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// QUICK STATS GRID
          Row(
            children: [
              _buildQuickStatCard(
                "Total Employees",
                "128",
                Icons.people_outline,
                Colors.blue,
              ),
              SizedBox(width: 12.w),
              _buildQuickStatCard(
                "Present Today",
                "116",
                Icons.check_circle_outline,
                Colors.green,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildQuickStatCard(
                "Pending Leaves",
                "08",
                Icons.calendar_today_outlined,
                Colors.orange,
              ),
              SizedBox(width: 12.w),
              _buildQuickStatCard(
                "Task Overdue",
                "04",
                Icons.warning_amber_outlined,
                Colors.red,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          SizedBox(height: 24.h),

          /// RECENT ACTIVITY BANNER
          _buildAnnouncementBanner(),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color, // Solid color
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final effectiveKey = widget.scaffoldKey ?? _scaffoldKey;
    return AppBar(
      backgroundColor: const Color(0xFF26A69A),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: widget.onBackToHrm ?? () => Navigator.pop(context),
      ),
      title: Text(
        "Welcome Harish",
        style: GoogleFonts.outfit(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.campaign_outlined, color: Colors.white),
          onPressed: () {},
        ),
        GestureDetector(
          onTap: () {
            effectiveKey.currentState?.openDrawer();
          },
          child: const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAnnouncementBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.white, size: 30),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Admin Alerts",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Review new leave and expense requests.",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
