import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui_widgets/src/tabs/segmented_control2.dart';
import 'package:macos_ui_widgets/src/tabs/tab2.dart';

const _kTabViewRadius = BorderRadius.all(
  Radius.circular(6.0),
);

/// {@template macosTabView}
/// A multipage interface that displays one page at a time.
///
/// <image alt='' src='https://docs-assets.developer.apple.com/published/db00e4fdc8/tabview_2x_bf87676c-ac06-41f4-a430-0b95b43cd278.png' width='400' height='400' />
///
/// A tab view contains a row of navigational items, [tabs], that move the
/// user through the provided views ([children]). The user selects the desired
/// page by clicking the appropriate tab.
///
/// The tab controller's [MacosTabController.length] must equal the length of
/// the [children] list and the length of the [tabs] list.
/// {@endtemplate}
class MacosTabView2 extends StatefulWidget {
  /// {@macro macosTabView}
  const MacosTabView2({
    super.key,
    required this.controller,
    required this.tabs,
    required this.children,
    this.constraints,
    this.outerDecoration,
    this.innerDecoration,
    this.innerPadding = const EdgeInsets.only(top: 36.0),
    this.outerPadding =
        const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0, bottom: 12.0),
    this.onTabChanged,
  }) : assert(controller.length == children.length &&
            controller.length == tabs.length);

  /// This widget's selection state.
  final MacosTabController controller;

  /// A list of navigational items, typically a length of two or more.
  final List<MacosTab2> tabs;

  /// The views to navigate between.
  ///
  /// There must be one widget per tab.
  final List<Widget> children;

  /// The padding of the tab view widget.
  ///
  /// Defaults to `EdgeInsets.all(12.0)`.
  final EdgeInsetsGeometry outerPadding;

  /// The padding of the inner content.
  final EdgeInsetsGeometry innerPadding;

  /// The constraints of the tab view widget.
  final BoxConstraints? constraints;

  /// The decoration of the outer container.
  final BoxDecoration? outerDecoration;

  /// The decoration of the inner container.
  final BoxDecoration? innerDecoration;

  /// A callback that is called when the selected tab changes.
  final ValueChanged<int>? onTabChanged;

  @override
  State<MacosTabView2> createState() => _MacosTabView2State();
}

class _MacosTabView2State extends State<MacosTabView2> {
  late List<Widget> _childrenWithKey;
  int? _currentIndex;

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _currentIndex = widget.controller.index;
  }

  @override
  void didUpdateWidget(MacosTabView2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
      _currentIndex = widget.controller.index;
    }
    if (widget.children != oldWidget.children) {
      _updateChildren();
    }
  }

  void _updateTabController() {
    widget.controller.addListener(_handleTabControllerTick);
  }

  void _handleTabControllerTick() {
    if (widget.controller.index != _currentIndex) {
      _currentIndex = widget.controller.index;
    }
    setState(() {
      // Rebuild the children after an index change
      // has completed.
    });
  }

  void _updateChildren() {
    _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabControllerTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (widget.controller.length != widget.children.length) {
        throw FlutterError(
          "Controller's length property (${widget.controller.length}) does not match the "
          "number of tabs (${widget.children.length}) present in TabBar's tabs property.",
        );
      }
      return true;
    }());

    final brightness = MacosTheme.brightnessOf(context);

    final outerBorderColor = brightness.resolve(
      const Color(0xFFE1E2E4),
      const Color(0xFF3E4045),
    );

    final decoration = widget.outerDecoration ??
        BoxDecoration(
          border: Border.all(
            color: outerBorderColor,
            width: 1.0,
          ),
          borderRadius: _kTabViewRadius,
        );

    return Container(
      constraints: widget.constraints,
      decoration: decoration,
      child: Padding(
        padding: widget.outerPadding,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              LayoutBuilder(builder: (context, constrains) {
                return ConstrainedBox(
                  constraints:
                      BoxConstraints.tightForFinite(width: constrains.maxWidth),
                  child: MacosSegmentedControl2(
                    onTabChanged: widget.onTabChanged,
                    controller: widget.controller,
                    tabs: widget.tabs,
                  ),
                );
              }),
              Padding(
                padding: widget.innerPadding,
                child: DecoratedBox(
                  decoration: widget.innerDecoration ??
                      BoxDecoration(
                        color: brightness.resolve(
                          const Color(0x77e8eaee),
                          const Color(0x772B2E33),
                        ),
                        border: Border.all(
                          color: outerBorderColor,
                          width: 1.0,
                        ),
                        borderRadius: _kTabViewRadius,
                      ),
                  child: IndexedStack(
                    sizing: StackFit.loose,
                    index: _currentIndex,
                    children: _childrenWithKey,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
