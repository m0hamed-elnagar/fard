import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../blocs/location_prayer_cubit.dart';
import '../blocs/location_prayer_state.dart';

class DataAndLocationSection extends StatefulWidget {
  final bool initiallyExpanded;
  const DataAndLocationSection({super.key, this.initiallyExpanded = false});

  @override
  State<DataAndLocationSection> createState() => _DataAndLocationSectionState();
}

class _DataAndLocationSectionState extends State<DataAndLocationSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
      builder: (context, state) {
        final cubit = context.read<LocationPrayerCubit>();
        return _buildExpandableSection(
          context,
          title: l10n.dataAndLocation,
          icon: Icons.backup_rounded,
          accentColor: Colors.teal,
          isExpanded: _isExpanded,
          onToggle: () => setState(() => _isExpanded = !_isExpanded),
          children: [
            if (state.latitude == null || state.longitude == null)
              _buildWarningCard(
                context,
                '',
                l10n.locationWarning,
                Icons.location_off_rounded,
                isSmall: true,
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.currentLocation),
              subtitle: Text(
                state.cityName ?? l10n.locationNotSet,
                style: TextStyle(
                  color: context.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  cubit.refreshLocation();
                },
                icon: const Icon(Icons.my_location, size: 18),
                label: Text(l10n.refreshLocation),
              ),
            ),
            const Divider(height: 1),
            _buildDropdownItem(
              context,
              l10n.madhab,
              state.madhab,
              [
                DropdownMenuItem(value: 'shafi', child: Text(l10n.shafiMadhab)),
                DropdownMenuItem(value: 'hanafi', child: Text(l10n.hanafiMadhab)),
              ],
              (val) => cubit.updateMadhab(val!),
            ),
            const Divider(height: 1),
            _buildDropdownItem(
              context,
              l10n.calculationMethod,
              state.calculationMethod,
              [
                DropdownMenuItem(
                    value: 'muslim_league',
                    child: Text(l10n.muslimWorldLeague)),
                DropdownMenuItem(
                    value: 'egyptian', child: Text(l10n.egyptianGeneralAuthority)),
                DropdownMenuItem(
                    value: 'karachi',
                    child: Text(l10n.universityOfIslamicSciencesKarachi)),
                DropdownMenuItem(
                    value: 'umm_al_qura',
                    child: Text(l10n.ummAlQuraUniversityMakkah)),
                DropdownMenuItem(
                    value: 'north_america', child: Text(l10n.isnaNorthAmerica)),
                DropdownMenuItem(
                    value: 'moonsighting_committee',
                    child: Text(l10n.moonsightingCommittee)),
                DropdownMenuItem(value: 'dubai', child: Text(l10n.dubai)),
                DropdownMenuItem(value: 'qatar', child: Text(l10n.qatar)),
                DropdownMenuItem(value: 'kuwait', child: Text(l10n.kuwait)),
                DropdownMenuItem(value: 'singapore', child: Text(l10n.singapore)),
                DropdownMenuItem(value: 'turkey', child: Text(l10n.turkey)),
                DropdownMenuItem(
                    value: 'tehran', child: Text(l10n.instituteOfGeophysicsTehran)),
              ],
              (val) => cubit.updateCalculationMethod(val!),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.hijriAdjustment),
              subtitle: Text(l10n.hijriAdjustmentDesc,
                  style: TextStyle(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.surfaceContainerHighestColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<int>(
                  value: state.hijriAdjustment,
                  items: List.generate(
                      5,
                      (i) => DropdownMenuItem(
                          value: i - 2, child: Text((i - 2).toString()))),
                  onChanged: (val) => cubit.updateHijriAdjustment(val!),
                  underline: const SizedBox(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final effectiveAccentColor = accentColor ?? context.primaryColor;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: effectiveAccentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: effectiveAccentColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.amiri(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: context.onSurfaceColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                ),
              ],
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem<T>(
    BuildContext context,
    String title,
    T value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.surfaceContainerHighestColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              items: items,
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon, {
    bool isSmall = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.errorColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment:
            isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.errorColor, size: isSmall ? 20 : 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.errorColor,
                    ),
                  ),
                Text(desc, style: TextStyle(fontSize: isSmall ? 12 : 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
