import 'dart:io';
import 'dart:math';
import 'package:adhan/adhan.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCalibrationOnboarding();
    });
  }

  void _checkCalibrationOnboarding() {
    if (Platform.isWindows) return;

    final prefs = getIt<SharedPreferences>();
    final hasSeen = prefs.getBool('has_seen_qibla_calibration_onboarding') ?? false;

    if (!hasSeen) {
      final l10n = AppLocalizations.of(context)!;
      _showCalibrationDialog(context, l10n);
      prefs.setBool('has_seen_qibla_calibration_onboarding', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (Platform.isWindows) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.qibla,
            style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.compass_calibration_rounded,
                size: 64,
                color: context.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.compassNotSupported,
                style: GoogleFonts.amiri(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.useMobileForQibla,
                style: TextStyle(color: context.onSurfaceVariantColor),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.qibla,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: l10n.qiblaCalibrationTitle,
            onPressed: () => _showCalibrationDialog(context, l10n),
          ),
        ],
      ),
      body: BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
        builder: (context, state) {
          if (state.latitude == null || state.longitude == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: 64,
                    color: context.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.locationNotSet,
                    style: GoogleFonts.amiri(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<LocationPrayerCubit>().refreshLocation(),
                    child: Text(l10n.refreshLocation),
                  ),
                ],
              ),
            );
          }

          final coordinates = Coordinates(state.latitude!, state.longitude!);
          final qiblaDirection = Qibla(coordinates).direction;

          return StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    l10n.errorReadingCompass(snapshot.error.toString()),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              double? direction = snapshot.data?.heading;

              if (direction == null) {
                return Center(child: Text(l10n.deviceNoSensors));
              }

              // Calculate the angle to rotate the compass needle
              // direction is the heading of the device (0 is North)
              // qiblaDirection is the angle of Qibla from North (clockwise)
              final qiblaAngle = qiblaDirection - direction;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass Background
                        Transform.rotate(
                          angle: (direction * (pi / 180) * -1),
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.outlineColor,
                                width: 2,
                              ),
                              color: context.surfaceContainerColor,
                            ),
                            child: Stack(
                              children: [
                                for (int i = 0; i < 360; i += 30)
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment(
                                        0.8 * cos((i - 90) * pi / 180),
                                        0.8 * sin((i - 90) * pi / 180),
                                      ),
                                      child: Text(
                                        _getDirectionLabel(i),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: i == 0
                                              ? context.errorColor
                                              : context.onSurfaceVariantColor,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Qibla Needle
                        Transform.rotate(
                          angle: (qiblaAngle * (pi / 180)),
                          child: Column(
                            children: [
                              Icon(
                                Icons.keyboard_double_arrow_up_rounded,
                                size: 60,
                                color: context.secondaryColor,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                        // Kaaba Icon at the center
                        Icon(
                          Icons.mosque,
                          size: 40,
                          color: context.primaryContainerColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      l10n.qiblaDirectionWithVal(
                        qiblaDirection.toStringAsFixed(1),
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.rotatePhoneForQibla,
                          style: TextStyle(color: context.onSurfaceVariantColor),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showCalibrationDialog(context, l10n),
                          child: Icon(
                            Icons.help_outline_rounded,
                            size: 18,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCalibrationDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.compass_calibration_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              l10n.qiblaCalibrationTitle,
              style: GoogleFonts.amiri(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.qiblaCalibrationDesc,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.qiblaCalibrationTipTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sensors_off_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.qiblaCalibrationTip1,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.screen_rotation_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.qiblaCalibrationTip2,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              MaterialLocalizations.of(context).closeButtonLabel,
            ),
          ),
        ],
      ),
    );
  }

  String _getDirectionLabel(int angle) {
    switch (angle) {
      case 0:
        return 'N';
      case 90:
        return 'E';
      case 180:
        return 'S';
      case 270:
        return 'W';
      default:
        return '';
    }
  }
}
