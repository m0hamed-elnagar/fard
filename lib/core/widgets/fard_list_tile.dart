import 'package:flutter/material.dart';

/// A wrapper around [ListTile] that includes a [Material] ancestor with
/// transparent color. This ensures that ink splashes and background colors
/// work correctly in Flutter 3.44+ when the tile is used inside a container
/// with its own background.
class FardListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final Color? tileColor;
  final ShapeBorder? shape;
  final VisualDensity? visualDensity;

  const FardListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.tileColor,
    this.shape,
    this.visualDensity,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        contentPadding: contentPadding,
        onTap: onTap,
        onLongPress: onLongPress,
        enabled: enabled,
        selected: selected,
        tileColor: tileColor,
        shape: shape,
        visualDensity: visualDensity,
      ),
    );
  }
}

/// A wrapper around [SwitchListTile] that includes a [Material] ancestor.
class FardSwitchListTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? secondary;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final ImageProvider? activeThumbImage;
  final ImageProvider? inactiveThumbImage;
  final Color? tileColor;
  final bool isThreeLine;
  final bool? dense;
  final bool selected;
  final ListTileControlAffinity controlAffinity;
  final ShapeBorder? shape;

  const FardSwitchListTile({
    super.key,
    this.title,
    this.subtitle,
    this.secondary,
    required this.value,
    required this.onChanged,
    this.contentPadding,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.activeThumbImage,
    this.inactiveThumbImage,
    this.tileColor,
    this.isThreeLine = false,
    this.dense,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        title: title,
        subtitle: subtitle,
        secondary: secondary,
        value: value,
        onChanged: onChanged,
        contentPadding: contentPadding,
        activeThumbColor: activeColor,
        activeTrackColor: activeTrackColor,
        inactiveThumbColor: inactiveThumbColor,
        inactiveTrackColor: inactiveTrackColor,
        activeThumbImage: activeThumbImage,
        inactiveThumbImage: inactiveThumbImage,
        tileColor: tileColor,
        isThreeLine: isThreeLine,
        dense: dense,
        selected: selected,
        controlAffinity: controlAffinity,
        shape: shape,
      ),
    );
  }
}
