import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui_widgets/src/tabs/tab2.dart';
import 'package:macos_ui_widgets/src/tabs/tab_view2.dart';

/// {@template macosSegmentedControl}
/// Displays one or more navigational tabs in a single horizontal group.
///
/// Used by [MacosTabView2] to navigate between the different tabs of the tab bar.
///
/// [MacosSegmentedControl2] can be considered somewhat analogous to Flutter's
/// material `TabBar` in that it requires a list of [tabs]. Unlike `TabBar`,
/// however, [MacosSegmentedControl2] explicitly requires a [controller].
///
/// See also:
/// * [MacosTab2], which is a navigational item in a [MacosSegmentedControl2].
/// * [MacosTabView2], which is a multi-page navigational view.
/// {@endtemplate}
class MacosSegmentedControl2 extends StatefulWidget {
  /// {@macro macosSegmentedControl}
  ///
  /// [tabs] and [controller] must not be null. [tabs] must contain at least one
  /// tab.
  const MacosSegmentedControl2({
    super.key,
    required this.tabs,
    required this.controller,
    this.onTabChanged,
  }) : assert(tabs.length > 0);

  /// The navigational items of this [MacosSegmentedControl2].
  final List<MacosTab2> tabs;

  /// A callback that is called when the selected tab changes.
  final ValueChanged<int>? onTabChanged;

  /// The [MacosTabController] that manages the [tabs] in this
  /// [MacosSegmentedControl2].
  final MacosTabController controller;

  @override
  State<MacosSegmentedControl2> createState() => _MacosSegmentedControl2State();
}

class _MacosSegmentedControl2State extends State<MacosSegmentedControl2> {
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
                bool showDivider = true;
                if (last ||
                    widget.controller.index == index ||
                    widget.controller.index == index + 1) {
                  showDivider = false;
                }

                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          final newIndex = widget.tabs.indexOf(t);
                          widget.controller.index = newIndex;
                          widget.onTabChanged?.call(newIndex);
                        });
                      },
                      // child: Text(t.label),
                      child: SizedBox(
                        width: tabSize - (last ? 0 : 2),
                        child: t.copyWith(
                          active:
                              widget.controller.index == widget.tabs.indexOf(t),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: showDivider
                          ? brightness.resolve(
                              const Color(0xFFC9C9C9),
                              const Color(0xFF26222C),
                            )
                          : Colors.transparent,
                      width: last ? 0 : 2.0,
                      thickness: 1.0,
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
