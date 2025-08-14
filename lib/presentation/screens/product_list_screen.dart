import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spinza/presentation/bloc/product/product_bloc.dart';
import 'package:spinza/presentation/bloc/product/product_event.dart';
import 'package:spinza/presentation/bloc/product/product_state.dart';
import 'package:spinza/presentation/widgets/grid_product_card.dart';
import 'dart:math' as math;

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late Animation<double> _waveAnimation;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProducts());

    _waveController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_waveController);

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
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

            // Floating bubbles
            ...List.generate(8, (index) =>
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Positioned(
                      left: 30 + (index * 50) +
                          math.sin(_waveAnimation.value + index) * 25,
                      top: 80 + (index * 80) +
                          math.cos(_waveAnimation.value + index) * 30,
                      child: Container(
                        width: 15 + (index * 3),
                        height: 15 + (index * 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
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
                child: Column(
                  children: [
                    // Glass-morphism AppBar
                    Container(
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
                                  'Spinza Products',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  'Premium Water Collection',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Products content
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
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
                          child: BlocBuilder<ProductBloc, ProductState>(
                            builder: (context, state) {
                              if (state is ProductLoading || state is ProductInitial) {
                                return _buildShimmerGrid();
                              }

                              if (state is ProductLoaded) {
                                if (state.products.isEmpty) {
                                  return _buildEmptyState();
                                }

                                return RefreshIndicator(
                                  onRefresh: () async {
                                    context.read<ProductBloc>().add(FetchProducts());
                                    await Future.delayed(Duration(milliseconds: 500));
                                  },
                                  color: Colors.white,
                                  backgroundColor: Color(0xFF1E3C72),
                                  child: CustomScrollView(
                                    controller: _scrollController,
                                    slivers: [
                                      // Product count header
                                      SliverToBoxAdapter(
                                        child: Container(
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
                                                    '${state.products.length} Products',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Fresh & Pure',
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
                                                    Icon(
                                                      Icons.water_drop,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Premium',
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
                                      ),

                                      // Product Grid
                                      SliverPadding(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        sliver: SliverGrid(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16.0,
                                            mainAxisSpacing: 16.0,
                                            childAspectRatio: 0.75,
                                          ),
                                          delegate: SliverChildBuilderDelegate(
                                                (context, index) {
                                              return TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0, end: 1),
                                                duration: Duration(milliseconds: 600 + (index * 100)),
                                                curve: Curves.easeOutBack,
                                                builder: (context, value, child) {
                                                  return Transform.scale(
                                                    scale: value,
                                                    child: Container(
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
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: GridProductCard(
                                                            product: state.products[index]
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            childCount: state.products.length,
                                          ),
                                        ),
                                      ),

                                      // Bottom spacing
                                      SliverToBoxAdapter(
                                        child: SizedBox(height: 100),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (state is ProductError) {
                                return _buildErrorState(state.message);
                              }

                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Container(
                            height: 14,
                            margin: EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Container(
                            height: 10,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
              Icons.water_drop_outlined,
              size: 60,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Water Bottles Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for fresh deliveries!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
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
              onPressed: () => context.read<ProductBloc>().add(FetchProducts()),
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Refresh',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
              Icons.error_outline,
              size: 60,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Connection Issue',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
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
              onPressed: () => context.read<ProductBloc>().add(FetchProducts()),
              icon: Icon(Icons.refresh, color: Colors.white),
              label: Text(
                'Try Again',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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