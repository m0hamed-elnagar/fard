import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class SalaahTile extends StatefulWidget {
  final Salaah salaah;
  final int qadaCount;
  final int completedQadaCount;
  final bool isMissedToday;
  final bool isCompletedToday;
  final bool isUpcoming;
  final DateTime? time;
  final bool isQadaEnabled;
  final bool isReminderEnabled;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onToggleMissed;
  final VoidCallback onToggleReminder;
  final VoidCallback? onLimitExceeded;

  const SalaahTile({
    super.key,
    required this.salaah,
    required this.qadaCount,
    required this.completedQadaCount,
    required this.isMissedToday,
    required this.isCompletedToday,
    required this.isUpcoming,
    required this.time,
    required this.isQadaEnabled,
    required this.isReminderEnabled,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleMissed,
    required this.onToggleReminder,
    this.onLimitExceeded,
  });

  @override
  State<SalaahTile> createState() => _SalaahTileState();
}

class _SalaahTileState extends State<SalaahTile> {
  int _removedInSession = 0;

  IconData _getSalaahIcon(Salaah salaah) {
    switch (salaah) {
      case Salaah.fajr:
        return Icons.wb_twilight_rounded;
      case Salaah.dhuhr:
        return Icons.wb_sunny_rounded;
      case Salaah.asr:
        return Icons.wb_sunny_outlined;
      case Salaah.maghrib:
        return Icons.nightlight_round;
      case Salaah.isha:
        return Icons.bedtime_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timeFormat = DateFormat.jm(
      Localizations.localeOf(context).languageCode,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 360;
        final bool isVeryNarrow = constraints.maxWidth < 320;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isUpcoming
                  ? [context.surfaceContainerColor, context.surfaceContainerColor]
                  : widget.isCompletedToday
                  ? [
                      context.primaryLight.withValues(alpha: 0.15),
                      context.primaryLight.withValues(alpha: 0.05),
                    ]
                  : [
                      context.missedColor.withValues(alpha: 0.15),
                      context.missedColor.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: widget.isUpcoming
                  ? context.outlineColor.withValues(alpha: 0.5)
                  : widget.isCompletedToday
                  ? context.primaryLight.withValues(alpha: 0.4)
                  : context.missedColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: !widget.isUpcoming
                    ? (widget.isCompletedToday
                              ? context.primaryLight
                              : context.missedColor)
                          .withValues(alpha: 0.1)
                    : context.surfaceContainerColor,
                blurRadius: !widget.isUpcoming ? 10 : 0,
                offset: !widget.isUpcoming ? const Offset(0, 4) : Offset.zero,
              ),
            ],
          ),
          child: Material(
            color: context.surfaceContainerColor,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              onTap: widget.isUpcoming
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      if (widget.isCompletedToday && _removedInSession > 0) {
                        setState(() {
                          _removedInSession--;
                        });
                      }
                      widget.onToggleMissed();
                    },
              child: Opacity(
                opacity: widget.isUpcoming ? 0.6 : 1.0,
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 10.0 : 14.0),
                  child: Row(
                    children: [
                      // Today Missed Status
                      _StatusIndicator(
                        icon: _getSalaahIcon(widget.salaah),
                        isMissed:
                            !widget.isUpcoming && !widget.isCompletedToday,
                        isCompleted: widget.isCompletedToday,
                        isUpcoming: widget.isUpcoming,
                        size: isNarrow ? 40.0 : 48.0,
                        onTap: widget.isUpcoming
                            ? () {}
                            : () {
                                HapticFeedback.mediumImpact();
                                if (widget.isCompletedToday &&
                                    _removedInSession > 0) {
                                  setState(() {
                                    _removedInSession--;
                                  });
                                }
                                widget.onToggleMissed();
                              },
                      ),
                      SizedBox(width: isNarrow ? 10.0 : 16.0),

                      // Stacked Counter Buttons
                      if (widget.isQadaEnabled && !isVeryNarrow)
                        Container(
                          decoration: BoxDecoration(
                            color: context.surfaceLightColor,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: context.outlineColor),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CounterButton(
                                icon: Icons.add_rounded,
                                size: isNarrow ? 20 : 24,
                                padding: isNarrow ? 6 : 10,
                                onPressed: widget.isUpcoming
                                    ? null
                                    : () {
                                        HapticFeedback.lightImpact();
                                        if (_removedInSession > 0 ||
                                            widget.completedQadaCount > 0) {
                                          widget.onAdd();
                                          if (_removedInSession > 0) {
                                            setState(() {
                                              _removedInSession--;
                                            });
                                          }
                                        } else {
                                          widget.onLimitExceeded?.call();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.arrow_upward_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      l10n.useAddQadaToNewPrayers,
                                                      style: GoogleFonts.outfit(
                                                        color: context.onSurfaceColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: context.secondaryColor,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(16),
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                color:
                                    (_removedInSession > 0 &&
                                        !widget.isUpcoming)
                                    ? context.primaryLight
                                    : context.neutralColor.withValues(alpha: 0.5),
                              ),
                              Container(
                                width: 16,
                                height: 1,
                                color: context.outlineColor,
                              ),
                              _CounterButton(
                                icon: Icons.remove_rounded,
                                size: isNarrow ? 20 : 24,
                                padding: isNarrow ? 6 : 10,
                                onPressed:
                                    (widget.qadaCount > 0 && !widget.isUpcoming)
                                    ? () {
                                        HapticFeedback.lightImpact();
                                        widget.onRemove();
                                        setState(() {
                                          _removedInSession++;
                                        });
                                      }
                                    : null,
                                color: context.missedColor,
                              ),
                            ],
                          ),
                        ),

                      if (widget.isQadaEnabled && !isVeryNarrow)
                        SizedBox(width: isNarrow ? 10.0 : 16.0),

                      // Salaah Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.salaah.localizedName(l10n),
                                  style: GoogleFonts.amiri(
                                    color: context.onSurfaceColor,
                                    fontSize: isNarrow ? 18.0 : 22.0,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: widget.onToggleReminder,
                                  visualDensity: VisualDensity.compact,
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    widget.isReminderEnabled
                                        ? Icons.notifications_active_rounded
                                        : Icons.notifications_none_rounded,
                                    color:
                                        widget.isReminderEnabled
                                            ? context.secondaryColor
                                            : context.neutralColor.withValues(
                                              alpha: 0.5,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.time != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: isNarrow ? 12 : 14,
                                      color: context.secondaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeFormat.format(widget.time!),
                                      style: GoogleFonts.outfit(
                                        color: context.secondaryColor,
                                        fontSize: isNarrow ? 11.0 : 13.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Qada Count Display
                      if (widget.isQadaEnabled)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.completedQadaCount > 0 && !isVeryNarrow)
                              Container(
                                margin: const EdgeInsets.only(right: 6.0),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: context.primaryLight.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: context.primaryLight.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${widget.completedQadaCount}',
                                      style: GoogleFonts.outfit(
                                        color: context.primaryLight,
                                        fontSize: isNarrow ? 14.0 : 18.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      l10n.done,
                                      style: GoogleFonts.outfit(
                                        color: context.primaryLight.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: isNarrow ? 7.0 : 9.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isNarrow ? 10.0 : 16.0,
                                vertical: isNarrow ? 6.0 : 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: widget.qadaCount > 0
                                    ? context.secondaryColor.withValues(alpha: 0.1)
                                    : context.surfaceContainerColor,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: widget.qadaCount > 0
                                      ? context.secondaryColor.withValues(alpha: 0.3)
                                      : context.outlineColor,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${widget.qadaCount}',
                                    style: GoogleFonts.outfit(
                                      color: widget.qadaCount > 0
                                          ? context.secondaryColor
                                          : context.onSurfaceVariantColor,
                                      fontSize: isNarrow ? 18.0 : 24.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    isNarrow
                                        ? 'rem.'
                                        : l10n.remaining.toLowerCase(),
                                    style: GoogleFonts.outfit(
                                      color: widget.qadaCount > 0
                                          ? context.secondaryColor.withValues(
                                              alpha: 0.7,
                                            )
                                          : context.neutralColor,
                                      fontSize: isNarrow ? 7.0 : 10.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
  }
}

class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final bool isMissed;
  final bool isCompleted;
  final bool isUpcoming;
  final double size;
  final VoidCallback onTap;

  const _StatusIndicator({
    required this.icon,
    required this.isMissed,
    this.isCompleted = false,
    this.isUpcoming = false,
    this.size = 48.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isUpcoming
              ? context.surfaceContainerColor
              : isCompleted
              ? context.primaryLight
              : isMissed
              ? context.missedColor
              : context.surfaceLightColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isUpcoming
                ? context.neutralColor.withValues(alpha: 0.3)
                : isCompleted
                ? context.primaryLight
                : isMissed
                ? context.missedColor
                : context.neutralColor.withValues(alpha: 0.5),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: ((isMissed || isCompleted) && !isUpcoming)
                  ? (isCompleted ? context.primaryLight : context.missedColor)
                        .withValues(alpha: 0.3)
                  : context.surfaceContainerColor,
              blurRadius: ((isMissed || isCompleted) && !isUpcoming) ? 10 : 0,
              spreadRadius: ((isMissed || isCompleted) && !isUpcoming) ? 1 : 0,
            ),
          ],
        ),
        child: Icon(
          isUpcoming
              ? icon
              : (isCompleted ? Icons.check_rounded : Icons.close_rounded),
          color: isUpcoming
              ? context.neutralColor.withValues(alpha: 0.5)
              : context.onSurfaceColor,
          size: size * (isUpcoming ? 0.45 : 0.54),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final double padding;

  const _CounterButton({
    required this.icon,
    this.onPressed,
    required this.color,
    this.size = 24.0,
    this.padding = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding + 2,
          vertical: padding,
        ),
        child: Icon(
          icon,
          color: onPressed != null
              ? color
              : context.neutralColor.withValues(alpha: 0.5),
          size: size,
        ),
      ),
    );
  }
}
