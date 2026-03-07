import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/prayer_times_card.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/prayer_tracking_card.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/werd_progress_card.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DashboardCarousel extends StatefulWidget {
  final PrayerTimes? prayerTimes;
  final DateTime selectedDate;
  final String? cityName;
  final Map<Salaah, MissedCounter> qadaStatus;
  final VoidCallback onAddQadaPressed;
  final VoidCallback onEditQadaPressed;
  final VoidCallback onSetWerdGoalPressed;

  const DashboardCarousel({
    super.key,
    required this.prayerTimes,
    required this.selectedDate,
    this.cityName,
    required this.qadaStatus,
    required this.onAddQadaPressed,
    required this.onEditQadaPressed,
    required this.onSetWerdGoalPressed,
  });

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate a responsive height for the cards
    double cardHeight;
    if (screenHeight < 600) {
      cardHeight = 250;
    } else if (screenHeight < 800) {
      // For average phones, use a portion of the screen height but cap it
      cardHeight = (screenHeight * 0.38).clamp(260.0, 300.0);
    } else {
      cardHeight = 310;
    }

    // On tablets or landscape, we might want to adjust viewportFraction
    final double viewportFraction = screenWidth > 600 ? 0.7 : 0.9;
    if (_pageController.viewportFraction != viewportFraction) {
       // We can't easily change viewportFraction on existing controller without recreation
       // but for now let's keep it simple or just use the initial one.
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: cardHeight,
          child: PageView(
            controller: _pageController,
            clipBehavior: Clip.none,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildPageItem(
                PrayerTimesCard(
                  prayerTimes: widget.prayerTimes,
                  selectedDate: widget.selectedDate,
                  cityName: widget.cityName,
                ),
                0,
              ),
              _buildPageItem(
                PrayerTrackingCard(
                  qadaStatus: widget.qadaStatus,
                  onAddPressed: widget.onAddQadaPressed,
                  onEditPressed: widget.onEditQadaPressed,
                ),
                1,
              ),
              _buildPageItem(
                WerdProgressCard(
                  onSetGoalPressed: widget.onSetWerdGoalPressed,
                ),
                2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isSelected = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isSelected ? 24 : 6,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.accent 
                    : AppTheme.cardBorder.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPageItem(Widget child, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page! - index);
          value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
        } else {
          // Handle initial state before first frame/layout
          if (_currentPage != index) {
             value = 0.9;
          }
        }
        
        return Center(
          child: Transform.scale(
            scale: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
