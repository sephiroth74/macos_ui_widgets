import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// Overrides the default style of its [MacosPopupButton2] descendants.
///
/// See also:
///
///  * [MacosPopupButtonThemeData2], which is used to configure this theme.
class MacosPopupButtonTheme2 extends InheritedTheme {
  /// Creates a [MacosPopupButtonTheme2].
  ///
  /// The [data] parameter must not be null.
  const MacosPopupButtonTheme2({
    super.key,
    required this.data,
    required super.child,
  });

  /// The configuration of this theme.
  final MacosPopupButtonThemeData2 data;

  /// The closest instance of this class that encloses the given context.
  ///
  /// If there is no enclosing [MacosPopupButtonTheme2] widget, then
  /// [MacosThemeData.MacosPopupButtonTheme] is used.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// MacosPopupButtonTheme2 theme = MacosPopupButtonTheme2.of(context);
  /// ```
  static MacosPopupButtonThemeData2 of(BuildContext context) {
    final MacosPopupButtonTheme2? buttonTheme =
        context.dependOnInheritedWidgetOfExactType<MacosPopupButtonTheme2>();
    if (null != buttonTheme?.data) {
      return buttonTheme!.data;
    } else {
      final theme = MacosTheme.of(context);
      return MacosPopupButtonThemeData2.fromMacosTheme(theme: theme);
    }
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MacosPopupButtonTheme2(data: data, child: child);
  }

  @override
  bool updateShouldNotify(MacosPopupButtonTheme2 oldWidget) =>
      data != oldWidget.data;
}

/// A style that overrides the default appearance of
/// [MacosPopupButton2]s when it is used with [MacosPopupButtonTheme2] or with the
/// overall [MacosTheme]'s [MacosThemeData.MacosPopupButtonTheme].
///
/// See also:
///
///  * [MacosPopupButtonTheme2], the theme which is configured with this class.
///  * [MacosThemeData.MacosPopupButtonTheme], which can be used to override the default
///    style for [MacosPopupButton2]s below the overall [MacosTheme].
class MacosPopupButtonThemeData2 with Diagnosticable {
  /// Creates a [MacosPopupButtonThemeData2].
  MacosPopupButtonThemeData2({
    Brightness? brightness,
    this.popupColor,
    this.textColor,
    Color? backgroundColor,
    Color? caretColor,
    Color? caretBackgroundColor,
    Color? caretBorderColor,
    Color? backgroundColorHover,
    List<Color>? borderColors,
    Color? backgroundColorDisabled,
  }) {
    brightness ??= Brightness.light;

    this.backgroundColor = backgroundColor ?? Colors.transparent;

    this.caretColor = caretColor ??
        (brightness == Brightness.light ? Colors.black : Colors.white);

    this.caretBackgroundColor = caretBackgroundColor ??
        brightness.resolve(const Color(0xffdbdcdb), const Color(0xff414242));

    this.caretBorderColor = caretBorderColor ??
        brightness.resolve(const Color(0xffd5d7d6), Colors.transparent);

    this.backgroundColorHover = backgroundColorHover ??
        brightness.resolve(CupertinoColors.white, const Color(0xff606162));

    this.borderColors = borderColors ??
        [
          brightness.resolve(const Color(0xffd8d9d9), const Color(0xff282829)),
          brightness.resolve(const Color(0xFFafb1b1), const Color(0xff232525))
        ];

    this.backgroundColorDisabled = backgroundColorDisabled ??
        brightness.resolve(
          const Color(0xfff2f3f5),
          const Color(0xff3f4046),
        );
  }

  factory MacosPopupButtonThemeData2.fromMacosTheme(
      {required MacosThemeData theme}) {
    return MacosPopupButtonThemeData2(
      brightness: theme.brightness,
      popupColor: theme.popupButtonTheme.popupColor,
      textColor: theme.typography.body.color,
    );
  }

  late final Color backgroundColorDisabled;
  late final List<Color> borderColors;
  late final Color backgroundColorHover;
  late final Color caretColor;
  late final Color caretBackgroundColor;
  late final Color caretBorderColor;
  late final Color backgroundColor;
  final Color? popupColor;
  final Color? textColor;

  /// Copies this [MacosPopupButtonThemeData2] into another.
  MacosPopupButtonThemeData2 copyWith({
    Color? backgroundColor,
    Color? popupColor,
    Color? textColor,
    Color? caretColor,
    Color? caretBackgroundColor,
    Color? caretBorderColor,
    Color? backgroundColorHover,
    List<Color>? borderColors,
    Color? backgroundColorDisabled,
  }) {
    return MacosPopupButtonThemeData2(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      popupColor: popupColor ?? this.popupColor,
      textColor: textColor ?? this.textColor,
      caretColor: caretColor ?? this.caretColor,
      caretBackgroundColor: caretBackgroundColor ?? this.caretBackgroundColor,
      caretBorderColor: caretBorderColor ?? this.caretBorderColor,
      backgroundColorHover: backgroundColorHover ?? this.backgroundColorHover,
      borderColors: borderColors ?? this.borderColors,
      backgroundColorDisabled:
          backgroundColorDisabled ?? this.backgroundColorDisabled,
    );
  }

  /// Linearly interpolates between two [MacosPopupButtonThemeData2].
  ///
  /// All the properties must be non-null.
  static MacosPopupButtonThemeData2 lerp(
    MacosPopupButtonThemeData2 a,
    MacosPopupButtonThemeData2 b,
    double t,
  ) {
    return MacosPopupButtonThemeData2(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      popupColor: Color.lerp(a.popupColor, b.popupColor, t),
      textColor: Color.lerp(a.textColor, b.textColor, t),
      caretColor: Color.lerp(a.caretColor, b.caretColor, t),
      caretBackgroundColor:
          Color.lerp(a.caretBackgroundColor, b.caretBackgroundColor, t),
      caretBorderColor: Color.lerp(a.caretBorderColor, b.caretBorderColor, t),
      backgroundColorHover:
          Color.lerp(a.backgroundColorHover, b.backgroundColorHover, t),
      backgroundColorDisabled:
          Color.lerp(a.backgroundColorDisabled, b.backgroundColorDisabled, t),
      borderColors: List.generate(
        a.borderColors.length,
        (index) => Color.lerp(a.borderColors[index], b.borderColors[index], t)!,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacosPopupButtonThemeData2 &&
          runtimeType == other.runtimeType &&
          backgroundColor.value == other.backgroundColor.value &&
          popupColor?.value == other.popupColor?.value &&
          textColor?.value == other.textColor?.value &&
          caretColor.value == other.caretColor.value &&
          caretBackgroundColor.value == other.caretBackgroundColor.value &&
          caretBorderColor.value == other.caretBorderColor.value &&
          backgroundColorHover.value == other.backgroundColorHover.value &&
          backgroundColorDisabled.value ==
              other.backgroundColorDisabled.value &&
          listEquals(borderColors, other.borderColors);

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      popupColor.hashCode ^
      textColor.hashCode ^
      caretColor.hashCode ^
      caretBackgroundColor.hashCode ^
      caretBorderColor.hashCode ^
      backgroundColorHover.hashCode ^
      backgroundColorDisabled.hashCode ^
      borderColors.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('popupColor', popupColor));
    properties.add(ColorProperty('textColor', textColor));
    properties.add(ColorProperty('caretColor', caretColor));
    properties.add(ColorProperty('caretBackgroundColor', caretBackgroundColor));
    properties.add(ColorProperty('caretBorderColor', caretBorderColor));
    properties.add(ColorProperty('backgroundColorHover', backgroundColorHover));
    properties
        .add(ColorProperty('backgroundColorDisabled', backgroundColorDisabled));
    properties.add(IterableProperty<Color>('borderColors', borderColors));
  }

  /// Merges this [MacosPopupButtonThemeData2] with another.
  MacosPopupButtonThemeData2 merge(MacosPopupButtonThemeData2? other) {
    if (other == null) return this;
    return copyWith(
      backgroundColor: other.backgroundColor,
      popupColor: other.popupColor,
      textColor: other.textColor,
      caretColor: other.caretColor,
      caretBackgroundColor: other.caretBackgroundColor,
      caretBorderColor: other.caretBorderColor,
      backgroundColorHover: other.backgroundColorHover,
      borderColors: other.borderColors,
      backgroundColorDisabled: other.backgroundColorDisabled,
    );
  }
}
