import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/prayer_times_card.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/prayer_tracking_card.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/werd_progress_card.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DashboardCarousel extends StatefulWidget {
  final PrayerTimes? prayerTimes;
  final DateTime selectedDate;
  final String? cityName;
  final Map<Salaah, MissedCounter> qadaStatus;
  final VoidCallback onAddQadaPressed;
  final VoidCallback onEditQadaPressed;
  final VoidCallback onSetWerdGoalPressed;
  final PageController? pageController;
  final bool isQadaEnabled;

  const DashboardCarousel({
    super.key,
    required this.prayerTimes,
    required this.selectedDate,
    this.cityName,
    required this.qadaStatus,
    required this.onAddQadaPressed,
    required this.onEditQadaPressed,
    required this.onSetWerdGoalPressed,
    this.pageController,
    this.isQadaEnabled = true,
  });

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController =
        widget.pageController ?? PageController(viewportFraction: 0.9);
    _currentPage = _pageController.hasClients
        ? _pageController.page?.round() ?? 0
        : 0;
  }

  @override
  void dispose() {
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

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

    final pages = <Widget>[
      PrayerTimesCard(
        prayerTimes: widget.prayerTimes,
        selectedDate: widget.selectedDate,
        cityName: widget.cityName,
      ),
      if (widget.isQadaEnabled)
        PrayerTrackingCard(
          qadaStatus: widget.qadaStatus,
          onAddPressed: widget.onAddQadaPressed,
          onEditPressed: widget.onEditQadaPressed,
        ),
      WerdProgressCard(onSetGoalPressed: widget.onSetWerdGoalPressed),
    ];

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
            children: List.generate(pages.length, (index) {
              return _buildPageItem(pages[index], index);
            }),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pages.length, (index) {
            final isSelected = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isSelected ? 24 : 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.secondaryColor
                    : context.outlineColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.secondaryColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
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
