import 'dart:math';
import 'package:adhan/adhan.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.qibla,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          if (settings.latitude == null || settings.longitude == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_rounded, size: 64, color: AppTheme.missed),
                  const SizedBox(height: 16),
                  Text(
                    l10n.locationNotSet,
                    style: GoogleFonts.amiri(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<SettingsCubit>().refreshLocation(),
                    child: Text(l10n.refreshLocation),
                  ),
                ],
              ),
            );
          }

          final coordinates = Coordinates(settings.latitude!, settings.longitude!);
          final qiblaDirection = Qibla(coordinates).direction;

          return StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error reading compass: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              double? direction = snapshot.data?.heading;

              if (direction == null) {
                return const Center(child: Text('Device does not have sensors!'));
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
                              border: Border.all(color: AppTheme.cardBorder, width: 2),
                              color: AppTheme.surface,
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
                                          color: i == 0 ? Colors.red : AppTheme.textSecondary,
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
                              const Icon(
                                Icons.keyboard_double_arrow_up_rounded,
                                size: 60,
                                color: AppTheme.accent,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                        // Kaaba Icon at the center
                        const Icon(Icons.mosque, size: 40, color: AppTheme.primaryLight),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(
                      l10n.localeName == 'ar'
                          ? 'اتجاه القبلة: ${qiblaDirection.toStringAsFixed(1)}°'
                          : 'Qibla Direction: ${qiblaDirection.toStringAsFixed(1)}°',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.localeName == 'ar'
                          ? 'قم بتدوير الهاتف حتى يشير السهم للأعلى'
                          : 'Rotate phone until the arrow points up',
                      style: TextStyle(color: AppTheme.textSecondary),
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

  String _getDirectionLabel(int angle) {
    switch (angle) {
      case 0: return 'N';
      case 90: return 'E';
      case 180: return 'S';
      case 270: return 'W';
      default: return '';
    }
  }
}
