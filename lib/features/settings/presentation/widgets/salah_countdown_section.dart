import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../blocs/adhan_cubit.dart';
import '../blocs/adhan_state.dart';

class SalahCountdownSection extends StatelessWidget {
  const SalahCountdownSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AdhanCubit, AdhanState>(
      builder: (context, state) {
        final cubit = context.read<AdhanCubit>();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.surfaceContainerColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.outlineColor.withValues(alpha: 0.15),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.hourglass_bottom_rounded,
                        color: context.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.salahCountdown,
                        style: GoogleFonts.amiri(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: context.onSurfaceColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.showSalahCountdownNotification,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: context.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.showSalahCountdownNotificationDesc,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.onSurfaceColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomToggle(
                      value: state.showSalahCountdownNotification,
                      onChanged: (val) {
                        cubit.toggleShowSalahCountdownNotification(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
