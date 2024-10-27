import 'dart:math';

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

const _kTabBorderRadius = BorderRadius.all(
  Radius.circular(6.0),
);

/// {@template macosTab}
/// A macOS-style navigational button used to move between the views of a
/// [MacosExpandedTabView].
/// {@endtemplate}
class MacosExpandedTab extends StatelessWidget {
  /// {@macro macosTab}
  const MacosExpandedTab({
    super.key,
    required this.label,
    this.active = false,
    this.labelStyle,
  });

  /// The display label for this tab.
  final String label;

  // The style of the label.
  final TextStyle? labelStyle;

  /// Whether this [MacosExpandedTab] is currently selected. Handled internally by
  /// [MacosExpandedSegmentedControl]'s build function.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final brightness = MacosTheme.brightnessOf(context);

    final gradientBoxDecoration = BoxDecoration(
      gradient: active
          ? LinearGradient(colors: [
              brightness.resolve(
                const Color(0xFFc5c6ca),
                const Color(0xFF86878c),
              ),
              brightness.resolve(
                const Color(0xFFa7a8ab),
                const Color(0xff6a6c71),
              ),
            ], transform: const GradientRotation(45 * pi / 180))
          : null,
      border: Border.all(color: Colors.transparent, width: 0.75),
      borderRadius: _kTabBorderRadius,
      boxShadow: active
          ? [
              const BoxShadow(
                color: Color(0x884F5155),
                offset: Offset(0, 0.25),
                spreadRadius: 0.025,
                blurRadius: 0.025,
              ),
            ]
          : null,
    );

    return DecoratedBox(
      decoration: gradientBoxDecoration,
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: active
            ? BoxDecoration(
                color: brightness.resolve(
                  MacosColors.white,
                  const Color(0xFF646669),
                ),
                border: Border.all(
                  color: Colors.transparent,
                  width: 0.0,
                ),
                borderRadius: _kTabBorderRadius,
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Center(
              child: Text(
            label,
            style: labelStyle ?? const TextStyle(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ),
      ),
    );
  }

  /// Copies this [MacosExpandedTab] into another.
  MacosExpandedTab copyWith({
    String? label,
    bool? active,
    TextStyle? labelStyle,
    bool? last,
  }) {
    return MacosExpandedTab(
      label: label ?? this.label,
      active: active ?? this.active,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }
}
