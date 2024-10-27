import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui_widgets/tabs/expanded_tab.dart';
import 'package:macos_ui_widgets/tabs/expanded_tab_view.dart';

/// {@template macosSegmentedControl}
/// Displays one or more navigational tabs in a single horizontal group.
///
/// Used by [MacosExpandedTabView] to navigate between the different tabs of the tab bar.
///
/// [MacosExpandedSegmentedControl] can be considered somewhat analogous to Flutter's
/// material `TabBar` in that it requires a list of [tabs]. Unlike `TabBar`,
/// however, [MacosExpandedSegmentedControl] explicitly requires a [controller].
///
/// See also:
/// * [MacosExpandedTab], which is a navigational item in a [MacosExpandedSegmentedControl].
/// * [MacosExpandedTabView], which is a multi-page navigational view.
/// {@endtemplate}
class MacosExpandedSegmentedControl extends StatefulWidget {
  /// {@macro macosSegmentedControl}
  ///
  /// [tabs] and [controller] must not be null. [tabs] must contain at least one
  /// tab.
  const MacosExpandedSegmentedControl({
    super.key,
    required this.tabs,
    required this.controller,
  }) : assert(tabs.length > 0);

  /// The navigational items of this [MacosExpandedSegmentedControl].
  final List<MacosExpandedTab> tabs;

  /// The [MacosTabController] that manages the [tabs] in this
  /// [MacosExpandedSegmentedControl].
  final MacosTabController controller;

  @override
  State<MacosExpandedSegmentedControl> createState() => _MacosExpandedSegmentedControlState();
}

class _MacosExpandedSegmentedControlState extends State<MacosExpandedSegmentedControl> {
  @override
  Widget build(BuildContext context) {
    final brightness = MacosTheme.brightnessOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: brightness.resolve(
            const Color(0xFFcdcfd2),
            const Color(0xFF47494f),
          ),
          width: 1,
        ),
        // Background color
        color: brightness.resolve(
          const Color(0xFFE2E3E6),
          const Color(0xFF353433),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(7.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(.5),
        child: LayoutBuilder(builder: (context, constraints) {
          final tabSize = constraints.maxWidth / widget.tabs.length;
          return IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: widget.tabs.mapIndexed((index, t) {
                final last = index == widget.tabs.length - 1;
                bool showDividerColor = true;
                if ((widget.controller.index - 1 == index) || (widget.controller.index + 1 == index + 1) || last) {
                  showDividerColor = false;
                }

                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.controller.index = widget.tabs.indexOf(t);
                        });
                      },
                      // child: Text(t.label),
                      child: SizedBox(
                        width: tabSize - (last ? 0 : 2),
                        child: t.copyWith(
                          active: widget.controller.index == widget.tabs.indexOf(t),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: !last && showDividerColor
                          ? brightness.resolve(
                              const Color(0xFFC9C9C9),
                              const Color(0xFF26222C),
                            )
                          : Colors.transparent,
                      width: last ? 0 : 2.0,
                      indent: 5.0,
                      endIndent: 5.0,
                    ),
                  ],
                );
              }).toList(growable: false),
            ),
          );
        }),
      ),
    );
  }
}
