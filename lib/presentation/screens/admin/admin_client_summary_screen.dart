import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_bloc.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_event.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_state.dart';
import 'package:spinza/presentation/screens/admin/client_order_history_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

import '../../widgets/custom_loading_indicator.dart';

class AdminClientSummaryScreen extends StatefulWidget {
  const AdminClientSummaryScreen({super.key});

  @override
  State<AdminClientSummaryScreen> createState() => _AdminClientSummaryScreenState();
}

class _AdminClientSummaryScreenState extends State<AdminClientSummaryScreen>
    with TickerProviderStateMixin {

  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fabController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch all orders when the screen loads
    context.read<AdminOrdersBloc>().add(FetchAllOrders());

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
      duration: Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _fabController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(begin: -10, end: 10)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_rotateController);

    _fabAnimation = Tween<double>(begin: 0.9, end: 1.1)
        .animate(CurvedAnimation(parent: _fabController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _fabController.dispose();
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

            // Enhanced floating bubbles
            ...List.generate(15, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 25 + (index * 30) +
                          math.sin(_waveAnimation.value + index) * 25,
                      top: 70 + (index * 55) +
                          math.cos(_waveAnimation.value + index * 0.8) * 35,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: index % 4 == 0 ? _pulseAnimation.value * 0.4 : 1.0,
                            child: Container(
                              width: 8 + (index * 1.5),
                              height: 8 + (index * 1.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05 + (index * 0.008)),
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

            // Rotating geometric shapes
            ...List.generate(6, (index) =>
                AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: 40 + (index * 80),
                      top: 150 + (index * 120),
                      child: Transform.rotate(
                        angle: _rotateAnimation.value + (index * math.pi / 3),
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            shape: index % 3 == 0 ? BoxShape.rectangle : BoxShape.circle,
                            color: Colors.white.withOpacity(0.02),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
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
                                  // Back button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      icon: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Title section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Client Orders',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        Text(
                                          'Customer Analytics Overview',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Clients icon
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value * 0.1 + 0.9,
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
                                            Icons.people_alt_outlined,
                                            color: Colors.white,
                                            size: 20,
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

                    // Orders content container as Sliver
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 100), // Extra bottom margin for FAB
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
                          child: BlocBuilder<AdminOrdersBloc, AdminOrdersState>(
                            builder: (context, state) {
                              if (state is AdminOrdersLoading) {
                                return _buildShimmerContent();
                              }

                              if (state is AdminOrdersError) {
                                return _buildErrorState(state.message);
                              }

                              if (state is AdminOrdersLoaded) {
                                if (state.clientSummaries.isEmpty) {
                                  return _buildEmptyState();
                                }
                                return _buildClientSummariesContent(state);
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

            // Enhanced Floating Action Button
            Positioned(
              bottom: 30,
              right: 20,
              child: AnimatedBuilder(
                animation: _fabAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fabAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        onPressed: () => context.read<AdminOrdersBloc>().add(FetchAllOrders()),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        child: AnimatedBuilder(
                          animation: _rotateAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateAnimation.value,
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 28,
                              ),
                            );
                          },
                        ),
                        tooltip: 'Refresh Orders',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSummariesContent(AdminOrdersLoaded state) {
    return Column(
      children: [
        // Client count header
        Container(
          margin: EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.clientSummaries.length} Clients',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Active Customer Base',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Client summaries list
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: state.clientSummaries.length,
          itemBuilder: (context, index) {
            final summary = state.clientSummaries[index];
            final String formattedDate =
            DateFormat('MMM d, yyyy').format(summary.lastOrderDate.toDate());

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 800 + (index * 100)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
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
                    child: ListTile(
                      contentPadding: EdgeInsets.all(20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClientOrderHistoryScreen(clientSummary: summary),
                          ),
                        );
                      },
                      leading: AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value * 0.3),
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
                                Icons.person_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                      title: Text(
                        summary.clientName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.shopping_bag_outlined, 'Total Orders: ${summary.totalOrders}'),
                            SizedBox(height: 4),
                            _buildInfoRow(Icons.account_balance_wallet_outlined, 'Total Spent: PKR ${summary.totalSpent.toStringAsFixed(2)}'),
                            SizedBox(height: 4),
                            _buildInfoRow(Icons.schedule_outlined, 'Last Order: $formattedDate'),
                          ],
                        ),
                      ),
                      trailing: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value * 0.1 + 0.9,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ),
      ],
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
            // Header shimmer
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // List shimmer
            ...List.generate(4, (index) {
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 500,
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
                      Icons.people_alt_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Text(
              'No client orders found yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Orders will appear here as clients make purchases',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 40),
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
                onPressed: () => context.read<AdminOrdersBloc>().add(FetchAllOrders()),
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Refresh',
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

  Widget _buildErrorState(String message) {
    return Container(
      height: 500,
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
                      Icons.error_outline,
                      size: 80,
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
            SizedBox(height: 40),
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
                onPressed: () => context.read<AdminOrdersBloc>().add(FetchAllOrders()),
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
      height: 400,
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
                      Icons.analytics_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Text(
              'Loading Client Data...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Please wait while we fetch client order summaries',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 40),
            CustomLoadingIndicator(),
          ],
        ),
      ),
    );
  }
}

// Custom Wave Painter for animated background
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create multiple wave layers
    for (int i = 0; i < 3; i++) {
      path.reset();
      final waveHeight = 30.0 + (i * 10);
      final waveLength = size.width / 2;
      final offset = animationValue * (i + 1) * 0.5;

      path.moveTo(0, size.height * 0.7 + (i * 50));

      for (double x = 0; x <= size.width; x += 1) {
        final y = size.height * 0.7 + (i * 50) +
            waveHeight * math.sin((x / waveLength * 2 * math.pi) + offset);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      paint.color = Colors.white.withOpacity(0.02 + (i * 0.01));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}