import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_bloc.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_event.dart';
import 'package:spinza/presentation/bloc/admin_orders/admin_orders_state.dart';
import 'dart:math' as math;

class ClientOrderHistoryScreen extends StatefulWidget {
  final ClientOrderSummary clientSummary;
  const ClientOrderHistoryScreen({super.key, required this.clientSummary});

  @override
  State<ClientOrderHistoryScreen> createState() => _ClientOrderHistoryScreenState();
}

class _ClientOrderHistoryScreenState extends State<ClientOrderHistoryScreen>
    with TickerProviderStateMixin {
  late ClientOrderSummary _currentSummary;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentSummary = widget.clientSummary;

    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
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

    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _floatAnimation = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);

    _fadeController.forward();

    // Listen for updates from the AdminOrdersBloc
    // This will automatically refresh the screen when a status is changed
    context.read<AdminOrdersBloc>().stream.listen((state) {
      if (state is AdminOrdersLoaded && mounted) {
        // Find the updated summary for this specific client
        final updatedSummary = state.clientSummaries.firstWhere(
              (s) => s.clientId == widget.clientSummary.clientId,
          // orElse is a safety net in case the client has no more orders
          orElse: () => _currentSummary,
        );
        // Update the local state to rebuild the UI
        setState(() {
          _currentSummary = updatedSummary;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // This function is for the manual pull-to-refresh action
  Future<void> _refreshOrders() async {
    context.read<AdminOrdersBloc>().add(FetchAllOrders());
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

            // Floating bubbles
            ...List.generate(12, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 30 + (index * 35) +
                          math.sin(_waveAnimation.value + index) * 20,
                      top: 80 + (index * 65) +
                          math.cos(_waveAnimation.value + index * 0.7) * 30,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: index % 3 == 0 ? _pulseAnimation.value * 0.3 : 1.0,
                            child: Container(
                              width: 6 + (index * 1.2),
                              height: 6 + (index * 1.2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.04 + (index * 0.006)),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
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

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Enhanced AppBar
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value * 0.5),
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
                                        '${_currentSummary.clientName}\'s Orders',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${_currentSummary.orders.length} Order${_currentSummary.orders.length != 1 ? 's' : ''}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Order icon
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
                                          Icons.shopping_bag_outlined,
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

                    // Orders list
                    Expanded(
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
                          child: RefreshIndicator(
                            onRefresh: _refreshOrders,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            color: Color(0xFF2A5298),
                            child: _currentSummary.orders.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(16),
                              itemCount: _currentSummary.orders.length,
                              itemBuilder: (context, index) {
                                final order = _currentSummary.orders[index];
                                final orderData = order.data() as Map<String, dynamic>;

                                // --- ALL VARIABLES ARE NOW CORRECTLY DEFINED HERE ---
                                final orderStatus = orderData['status'] as String? ?? 'Pending';
                                final DateTime orderDateTime = (orderData['orderDate'] as Timestamp).toDate();
                                final String formattedDate = DateFormat('MMM d, yyyy – hh:mm a').format(orderDateTime);
                                final address = orderData['address'] as String? ?? 'N/A';
                                final deliveryDay = orderData['deliveryDay'] as String? ?? 'N/A';
                                final paymentMethod = orderData['paymentMethod'] as String? ?? 'N/A';

                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(milliseconds: 600 + (index * 100)),
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
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _showStatusUpdateDialog(context, order.id, orderStatus);
                                            },
                                            borderRadius: BorderRadius.circular(20),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          orderData['productName'] ?? 'Unknown Product',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      _buildStatusChip(orderStatus),
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(vertical: 12),
                                                    height: 1,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.white.withOpacity(0.2),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  _buildDetailRow(context, Icons.location_on_outlined, address),
                                                  _buildDetailRow(context, Icons.calendar_today_outlined, 'Delivery Day: $deliveryDay'),
                                                  _buildDetailRow(context, Icons.payment_outlined, paymentMethod),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(vertical: 12),
                                                    height: 1,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.white.withOpacity(0.2),
                                                          Colors.transparent,
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Quantity: ${orderData['quantity'] ?? 0}',
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.9),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Total: PKR ${(orderData['totalPrice'] ?? 0.0).toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            formattedDate,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.white.withOpacity(0.7),
                                                            ),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: Colors.white.withOpacity(0.15),
                                                              borderRadius: BorderRadius.circular(12),
                                                              border: Border.all(
                                                                color: Colors.white.withOpacity(0.2),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                  Icons.touch_app_outlined,
                                                                  size: 12,
                                                                  color: Colors.white.withOpacity(0.8),
                                                                ),
                                                                SizedBox(width: 4),
                                                                Text(
                                                                  'Tap to update',
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    color: Colors.white.withOpacity(0.8),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
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

  Widget _buildEmptyState() {
    return Center(
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
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 32),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'This client hasn\'t placed any orders yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, String orderId, String currentStatus) {
    final List<String> statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Canceled'];
    String selectedStatus = statuses.contains(currentStatus) ? currentStatus : 'Pending';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A5298).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF2A5298),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Update Order Status',
                    style: TextStyle(
                      color: Color(0xFF1E3C72),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF2A5298).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF2A5298).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButton<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  underline: Container(),
                  icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF2A5298)),
                  style: TextStyle(color: Color(0xFF1E3C72), fontSize: 16),
                  items: statuses.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          _getStatusIcon(value),
                          SizedBox(width: 12),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newStatus) {
                    if (newStatus != null) {
                      setState(() {
                        selectedStatus = newStatus;
                      });
                      // When status is changed, dispatch the event.
                      // The BLoC will handle re-fetching, and our listener in initState will catch the update.
                      context.read<AdminOrdersBloc>().add(UpdateOrderStatus(orderId: orderId, newStatus: newStatus));
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status.toLowerCase()) {
      case 'pending':
        iconData = Icons.schedule;
        iconColor = Colors.orange;
        break;
      case 'processing':
        iconData = Icons.settings;
        iconColor = Colors.blue;
        break;
      case 'shipped':
        iconData = Icons.local_shipping;
        iconColor = Colors.indigo;
        break;
      case 'delivered':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'canceled':
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.help;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor, size: 18);
  }

  // --- Helper widgets with enhanced styling ---
  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'processing':
        chipColor = Colors.blue;
        statusIcon = Icons.settings;
        break;
      case 'shipped':
        chipColor = Colors.indigo;
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        chipColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'canceled':
        chipColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        chipColor = Colors.orange;
        statusIcon = Icons.schedule;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: chipColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 14,
            color: chipColor,
          ),
          SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: chipColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
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
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create multiple wave layers
    for (int i = 0; i < 2; i++) {
      path.reset();
      final waveHeight = 25.0 + (i * 8);
      final waveLength = size.width / 2;
      final offset = animationValue * (i + 1) * 0.3;

      path.moveTo(0, size.height * 0.8 + (i * 40));

      for (double x = 0; x <= size.width; x += 1) {
        final y = size.height * 0.8 + (i * 40) +
            waveHeight * math.sin((x / waveLength * 2 * math.pi) + offset);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      paint.color = Colors.white.withOpacity(0.015 + (i * 0.008));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}