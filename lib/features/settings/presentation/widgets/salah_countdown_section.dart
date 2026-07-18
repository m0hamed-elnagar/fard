import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/expandable_section_card.dart';
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
        return ExpandableSectionCard(
          title: l10n.salahCountdown,
          icon: Icons.hourglass_bottom_rounded,
          accentColor: context.primaryColor,
          initiallyExpanded: true,
          children: [
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
        );
      },
    );
  }
}
