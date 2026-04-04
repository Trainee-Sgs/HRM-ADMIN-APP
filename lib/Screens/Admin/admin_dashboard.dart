import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/bottom_nav_bar.dart';
import '../../Widgets/drawer_screen.dart';
import 'AttendanceManagement/attendance_management.dart';
import 'Onboarding/onboarding_management.dart';
import 'PerformanceManagement/performance_management.dart';
import 'TrainingDevelopment/training_management.dart';
import 'HealthSafety/health_safety_management.dart';
import 'Chat/chat_groups.dart';

import 'RecuritmentScreens/recruitment.dart';
import 'LeaveManagement/admin_leave_management.dart';
import 'PermissionManagement/admin_permission_management.dart';
import 'ExpenseManagement/admin_expense_management.dart';
import 'PayrollManagement/admin_payroll_management.dart';
import 'ComplaintManagement/admin_complaint_management.dart';
import 'EmployeeManagement/admin_employee_details.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

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
      AttendanceManagementScreen(),
      const AdminPayrollManagementScreen(),
      const ChatGroupScreen(),
    ];
  }

  final List<Map<String, dynamic>> hubItems = [
    {
      "title": "Employee",
      "icon": Icons.badge_outlined,
      "color": const Color(0xFFF1F8E9), // Light Green
      "isDark": false,
      "target": const AdminEmployeeFeatureScreen(),
    },
    {
      "title": "Attendance",
      "icon": Icons.calendar_month_outlined,
      "color": const Color(0xFFE0F2F1), // Light Mint
      "isDark": false,
      "target": AttendanceManagementScreen(),
    },
    {
      "title": "Leave",
      "icon": Icons.event_note_outlined,
      "color": const Color(0xFFFFF3E0), // Light Orange
      "isDark": false,
      "target": const AdminLeaveManagementScreen(),
    },
    {
      "title": "Recruitment",
      "icon": Icons.person_search_outlined,
      "color": const Color(0xFFE1F5FE), // Light Blue
      "isDark": false,
      "target": const RecruitmentScreen(),
    },
    {
      "title": "Onboarding",
      "icon": Icons.how_to_reg_outlined,
      "color": const Color(0xFFF3E5F5), // Light Purple
      "isDark": false,
      "target": const OnboardingManagementScreen(),
    },
    {
      "title": "Complaints",
      "icon": Icons.gavel_outlined,
      "color": const Color(0xFFFFEBEE), // Light Red
      "isDark": false,
      "target": const AdminComplaintManagementScreen(),
    },
    {
      "title": "Payroll",
      "icon": Icons.payments_outlined,
      "color": const Color(0xFFE8EAF6), // Light Indigo
      "isDark": false,
      "target": const AdminPayrollManagementScreen(),
    },
    {
      "title": "Permissions",
      "icon": Icons.admin_panel_settings_outlined,
      "color": const Color(0xFFF0F4C3), // Light Lime
      "isDark": false,
      "target": const AdminPermissionManagementScreen(),
    },
    {
      "title": "Expense",
      "icon": Icons.account_balance_wallet_outlined,
      "color": const Color(0xFFEFEBE9), // Light Brown
      "isDark": false,
      "target": const AdminExpenseManagementScreen(),
    },
    {
      "title": "Performance",
      "icon": Icons.speed_outlined,
      "color": const Color(0xFFE0F7FA), // Light Cyan
      "isDark": false,
      "target": const PerformanceManagementScreen(),
    },
    {
      "title": "Training",
      "icon": Icons.school_outlined,
      "color": const Color(0xFFFFF9C4), // Light Yellow
      "isDark": false,
      "target": const TrainingManagementScreen(),
    },
    {
      "title": "Health & Safety",
      "icon": Icons.health_and_safety_outlined,
      "color": const Color(0xFFFCE4EC), // Light Rose
      "isDark": false,
      "target": const HealthSafetyManagementScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      drawer: const AdminDrawer(),
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

          Text(
            "Management Hub",
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),

          /// HUB GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 2.3, // Square to Rectangle
            ),
            itemCount: hubItems.length,
            itemBuilder: (context, index) {
              return _buildHubItem(hubItems[index]);
            },
          ),
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
    return AppBar(
      backgroundColor: const Color(0xFF26A69A),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.sort, color: Colors.white),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Text(
        "Welcome Harish",
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.campaign_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildHubItem(Map<String, dynamic> item, {bool isCentered = false}) {
    bool isDark = item['isDark'] ?? true;
    return GestureDetector(
      onTap: () {
        if (item['target'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item['target']),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: item['color'],
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: isCentered
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'],
                  color: isDark ? Colors.white : Colors.black87,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              isCentered
                  ? Text(
                      item['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    )
                  : Expanded(
                      child: Text(
                        item['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF26A69A), // Application Theme Teal
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
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
