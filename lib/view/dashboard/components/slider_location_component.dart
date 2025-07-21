import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
class CustomSliderWithLocation extends StatefulWidget {
  final List<String> imageUrls;
  final String? currentLocation;
  final VoidCallback? onLocationTap;

  const CustomSliderWithLocation({
    required this.imageUrls,
    this.currentLocation,
    this.onLocationTap,
  });

  @override
  _CustomSliderWithLocationState createState() => _CustomSliderWithLocationState();
}

class _CustomSliderWithLocationState extends State<CustomSliderWithLocation> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.length >= 2) {
      _startAutoSlide();
    }
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < widget.imageUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildSlider() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final errorBackground = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;
    
    return SizedBox(
      height: 250,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          // Image slider
          widget.imageUrls.isNotEmpty
              ? PageView(
                  controller: _pageController,
                  children: widget.imageUrls.map((url) {
                    return Container(
                      // margin: EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: errorBackground,
                            child: Icon(Icons.error, color: Theme.of(context).iconTheme.color),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              : Container(color: errorBackground),
        ],
      ),
    );
  }

  Widget _buildLocationBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = Theme.of(context).primaryColor;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: iconColor),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.currentLocation ?? 'All services available',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).iconTheme?.color,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.chevron_right, color: iconColor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final indicatorInactiveColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildSlider(),
        
        // Indicators positioned above the location bar
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: widget.imageUrls.length > 1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imageUrls.length, (index) {
                    return Container(
                      width: _currentPage == index ? 18 : 6,
                      height: 6,
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: _currentPage == index 
                            ? Theme.of(context).primaryColor 
                            : indicatorInactiveColor,
                      ),
                    );
                  }),
                )
              : SizedBox.shrink(),
        ),
        
        // Location bar
        Positioned(
          bottom: -24,
          left: 16,
          right: 16,
          child: GestureDetector(
            onTap: widget.onLocationTap,
            child: _buildLocationBar(),
          ),
        ),
      ],
    );
  }
}