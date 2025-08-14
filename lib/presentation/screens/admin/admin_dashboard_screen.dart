import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:spinza/presentation/bloc/auth/auth_bloc.dart';
import 'package:spinza/presentation/bloc/auth/auth_event.dart';
import 'package:spinza/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:spinza/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:spinza/presentation/bloc/dashboard/dashboard_state.dart';
import 'package:spinza/presentation/screens/admin/admin_client_summary_screen.dart';
import 'package:spinza/presentation/screens/admin/admin_product_list_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

import '../../widgets/custom_loading_indicator.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {

  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the screen loads
    context.read<DashboardBloc>().add(FetchDashboardData());

    // Initialize animations
    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_rotateController);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
              Color(0xFF4FC3F7),
              Color(0xFF29B6F6),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated wave background
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Enhanced floating bubbles with different sizes and movements
            ...List.generate(12, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 20 + (index * 35) +
                          math.sin(_waveAnimation.value + index) * 30,
                      top: 80 + (index * 60) +
                          math.cos(_waveAnimation.value + index * 0.7) * 40,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: index % 3 == 0 ? _pulseAnimation.value * 0.5 : 1.0,
                            child: Container(
                              width: 10 + (index * 2),
                              height: 10 + (index * 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06 + (index * 0.01)),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ),

            // Rotating geometric shapes in background
            ...List.generate(4, (index) =>
                AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: 50 + (index * 100),
                      top: 200 + (index * 150),
                      child: Transform.rotate(
                        angle: _rotateAnimation.value + (index * math.pi / 2),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: index % 2 == 0 ? BoxShape.rectangle : BoxShape.circle,
                            color: Colors.white.withOpacity(0.03),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Glass-morphism AppBar as Sliver
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Container(
                              margin: EdgeInsets.all(16),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Title section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Admin Dashboard',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        Text(
                                          'Business Analytics & Control',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Logout button with animation
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value * 0.1 + 0.9,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
                                            icon: Icon(
                                              Iconsax.logout,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Dashboard content container as Sliver
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BlocBuilder<DashboardBloc, DashboardState>(
                            builder: (context, state) {
                              if (state is DashboardLoading) {
                                return _buildShimmerContent();
                              }

                              if (state is DashboardError) {
                                return _buildErrorState(state.message);
                              }

                              if (state is DashboardLoaded) {
                                return _buildDashboardContent(state);
                              }

                              return _buildInitialState();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(DashboardLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(FetchDashboardData());
        await Future.delayed(Duration(milliseconds: 500));
      },
      color: Colors.white,
      backgroundColor: Color(0xFF1E3C72),
      child: ListView(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        children: [
          _buildLiveStatsSection(state),
          SizedBox(height: 24),
          _buildNavigationSection(context),
          SizedBox(height: 24),
          _buildMonthlySummariesHeader(),
          SizedBox(height: 16),
          _buildPastSummariesSection(state),
        ],
      ),
    );
  }

  Widget _buildLiveStatsSection(DashboardLoaded state) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value * 0.1 + 0.9,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Iconsax.chart_2,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Stats (This Month)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Real-time business metrics',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Revenue', 'PKR ${state.revenueThisMonth.toStringAsFixed(2)}', Iconsax.money_3, 0)),
                    SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Orders', state.ordersThisMonth.toString(), Iconsax.box, 1)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 1200 + (index * 200)),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value * 0.5),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  context,
                  icon: Iconsax.setting_3,
                  label: 'Manage Products',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminProductListScreen())
                  ),
                  index: 0,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDashboardCard(
                  context,
                  icon: Iconsax.receipt_search,
                  label: 'View All Orders',
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminClientSummaryScreen())
                  ),
                  index: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 1400 + (index * 200)),
      curve: Curves.elasticOut,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value * (index % 2 == 0 ? 1 : -1)),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value * 0.1 + 0.9,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMonthlySummariesHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Iconsax.calendar_2,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Monthly Summaries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastSummariesSection(DashboardLoaded state) {
    if (state.monthlySummaries.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: List.generate(state.monthlySummaries.length, (index) {
        final summaryDoc = state.monthlySummaries[index];
        final summaryData = summaryDoc.data() as Map<String, dynamic>;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 1000 + (index * 150)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Iconsax.chart_1,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summaryData['monthName'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Total Orders: ${summaryData['totalOrders']}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PKR ${summaryData['totalRevenue'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Stats section shimmer
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Navigation section shimmer
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Iconsax.calendar_2,
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'No monthly summaries yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Summaries will appear as months complete',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value * 0.1 + 0.9,
                  child: Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Iconsax.warning_2,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Text(
              'Connection Issue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.read<DashboardBloc>().add(FetchDashboardData()),
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Iconsax.refresh_circle,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Text(
              'Pull down to refresh dashboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Get the latest business analytics',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wave painter class (same as other screens)
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();

    for (int i = 0; i < 3; i++) {
      path.reset();

      final waveHeight = 40.0 + (i * 15);
      final frequency = 0.015 + (i * 0.008);
      final phase = animationValue + (i * math.pi / 4);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height - 150 - (i * 80) +
            math.sin((x * frequency) + phase) * waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}