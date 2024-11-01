import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui_widgets/src/theme/popup_button2_theme.dart';

const Duration _kMacosPopupMenuDuration = Duration(milliseconds: 300);
const Offset _kPopupRouteOffset = Offset(0.0, 5.0);
const double _kMenuItemHeight = 20.0;
const double _kMinInteractiveDimension = 24.0;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 4.0);
const Radius _kSideRadius = Radius.circular(6.0);
const BorderRadius _kBorderRadius = BorderRadius.all(_kSideRadius);
const double _kPopupButtonHeight = 21.0;
const EdgeInsets _kIconPadding = EdgeInsets.only(left: 2.0);
const double _kIconSize = 16.0;
const double _kMenuItemPaddingInner = 4.0;

/// A builder to customize popup buttons.
///
/// Used by [MacosPopupButton2.selectedItemBuilder].
typedef MacosPopupButton2Builder = List<Widget> Function(BuildContext context);

// The widget that is the button wrapping the menu items.
class _MacosPopupMenuItemButton2<T> extends StatefulWidget {
  const _MacosPopupMenuItemButton2({
    super.key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    required this.itemIndex,
  });

  final _MacosPopupRoute2<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final int itemIndex;

  @override
  _MacosPopupMenuItemButton2State<T> createState() =>
      _MacosPopupMenuItemButton2State<T>();
}

class _MacosPopupMenuItemButton2State<T>
    extends State<_MacosPopupMenuItemButton2<T>> {
  bool _isHovered = false;

  void _handleFocusChange(bool focused) {
    if (focused) {
      final _MenuLimits2 menuLimits = widget.route.getMenuLimits(
        widget.buttonRect,
        widget.constraints.maxHeight,
        widget.itemIndex,
      );
      widget.route.scrollController!.animateTo(
        menuLimits.scrollOffset,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
      );
      setState(() => _isHovered = true);
    } else {
      setState(() => _isHovered = false);
    }
  }

  void _handleOnTap() {
    final MacosPopupMenuItem2<T> popupMenuItem =
        widget.route.items[widget.itemIndex].item!;

    popupMenuItem.onTap?.call();

    Navigator.pop(
      context,
      _MacosPopupRouteResult2<T>(popupMenuItem.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MacosTheme.brightnessOf(context);
    final MacosPopupMenuItem2<T> popupMenuItem =
        widget.route.items[widget.itemIndex].item!;

    Widget child = Container(
      padding: widget.padding,
      height: widget.route.itemHeight,
      child: widget.route.items[widget.itemIndex],
    );

    child = MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: popupMenuItem.enabled
          ? (_) {
              setState(() => _isHovered = true);
            }
          : null,
      onExit: popupMenuItem.enabled
          ? (_) {
              setState(() => _isHovered = false);
            }
          : null,
      child: GestureDetector(
        onTap: popupMenuItem.enabled ? _handleOnTap : null,
        child: Focus(
          canRequestFocus: popupMenuItem.enabled,
          onKeyEvent: popupMenuItem.enabled
              ? (FocusNode node, KeyEvent event) {
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    _handleOnTap();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                }
              : null,
          onFocusChange: popupMenuItem.enabled ? _handleFocusChange : null,
          autofocus: popupMenuItem.enabled &&
              widget.itemIndex == widget.route.selectedIndex,
          child: Container(
            decoration: BoxDecoration(
              color: _isHovered
                  ? MacosPopupButtonTheme.of(context).highlightColor
                  : Colors.transparent,
              borderRadius: _kBorderRadius,
            ),
            child: Row(
              children: [
                (widget.itemIndex == widget.route.selectedIndex)
                    ? Padding(
                        padding: _kIconPadding,
                        child: MacosIcon(
                          CupertinoIcons.checkmark_alt,
                          size: _kIconSize,
                          color: _isHovered
                              ? MacosColors.white
                              : brightness.resolve(
                                  MacosColors.black,
                                  MacosColors.white,
                                ),
                        ),
                      )
                    : SizedBox(width: _kIconPadding.horizontal + _kIconSize),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 13.0,
                    color: _isHovered
                        ? MacosColors.white
                        : popupMenuItem.enabled
                            ? brightness.resolve(
                                MacosColors.black,
                                MacosColors.white,
                              )
                            : MacosColors.disabledControlTextColor
                                .resolveFrom(context),
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return child;
  }
}

class _MacosPopupMenu2<T> extends StatefulWidget {
  const _MacosPopupMenu2({
    super.key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    this.popupColor,
    required this.caretColor,
    required this.hasTopItemsNotShown,
    required this.hasBottomItemsNotShown,
  });

  final _MacosPopupRoute2<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final Color? popupColor;
  final Color caretColor;
  final bool hasTopItemsNotShown;
  final bool hasBottomItemsNotShown;

  @override
  _MacosPopupMenu2State<T> createState() => _MacosPopupMenu2State<T>();
}

class _MacosPopupMenu2State<T> extends State<_MacosPopupMenu2<T>> {
  late CurvedAnimation _fadeOpacity;
  late bool _showBottomCaret;
  late bool _showTopCaret;

  @override
  void initState() {
    super.initState();
    // We need to hold these animations as state because of their curve
    // direction. When the route's animation reverses, if we were to recreate
    // the CurvedAnimation objects in build, we'd lose
    // CurvedAnimation._curveDirection.
    _fadeOpacity = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.0, 0.25),
      reverseCurve: const Interval(0.75, 1.0),
    );
    _showBottomCaret = widget.hasBottomItemsNotShown;
    _showTopCaret = widget.hasTopItemsNotShown;
  }

  @override
  Widget build(BuildContext context) {
    final _MacosPopupRoute2<T> route = widget.route;
    final List<Widget> children = <Widget>[
      for (int itemIndex = 0; itemIndex < route.items.length; ++itemIndex)
        _MacosPopupMenuItemButton2<T>(
          route: widget.route,
          padding: widget.padding,
          buttonRect: widget.buttonRect,
          constraints: widget.constraints,
          itemIndex: itemIndex,
        ),
    ];
    final brightness = MacosTheme.brightnessOf(context);
    final popupColor = MacosDynamicColor.maybeResolve(
      widget.popupColor ?? MacosPopupButtonTheme2.of(context).popupColor,
      context,
    );
    final caretColor =
        brightness.resolve(CupertinoColors.black, CupertinoColors.white);

    final itemsList = ListView.builder(
      controller: widget.route.scrollController,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
      padding: const EdgeInsets.all(4.0),
      shrinkWrap: true,
    );

    return FadeTransition(
      opacity: _fadeOpacity,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
            physics: const ClampingScrollPhysics(),
            platform: TargetPlatform.macOS,
          ),
          child: PrimaryScrollController(
            controller: widget.route.scrollController!,
            child: NotificationListener(
              onNotification: (t) {
                if (t is ScrollUpdateNotification) {
                  setState(() {
                    _showTopCaret =
                        widget.route.scrollController!.position.extentBefore >
                            widget.buttonRect.height;
                    _showBottomCaret =
                        widget.route.scrollController!.position.extentAfter >
                            widget.buttonRect.height;
                  });
                }
                return true;
              },
              child: MacosOverlayFilter(
                color: popupColor?.withOpacity(0.25),
                borderRadius: _kBorderRadius,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _showTopCaret
                        ? Container(
                            width: widget.buttonRect.width,
                            height: widget.buttonRect.height,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: _kSideRadius,
                                topRight: _kSideRadius,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.chevron_up,
                              color: caretColor,
                              size: 12.0,
                            ),
                          )
                        : const SizedBox.shrink(),
                    // Wrap the items list with an Expanded widget for to
                    // avoid height overflow when having a lot of items.
                    _showTopCaret || _showBottomCaret
                        ? Expanded(
                            child: itemsList,
                          )
                        : itemsList,
                    _showBottomCaret
                        ? Container(
                            width: widget.buttonRect.width,
                            height: widget.buttonRect.height,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: _kSideRadius,
                                bottomRight: _kSideRadius,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.chevron_down,
                              color: caretColor,
                              size: 12.0,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MacosPopupMenuRouteLayout2<T> extends SingleChildLayoutDelegate {
  _MacosPopupMenuRouteLayout2({
    required this.buttonRect,
    required this.route,
    required this.textDirection,
  });

  final Rect buttonRect;
  final _MacosPopupRoute2<T> route;
  final TextDirection? textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The maximum height of a simple menu should be one or more rows less than
    // the view height. This ensures a tappable area outside of the simple menu
    // with which to dismiss the menu.
    double maxHeight =
        math.max(0.0, constraints.maxHeight - 2 * _kMenuItemHeight);
    if (route.menuMaxHeight != null && route.menuMaxHeight! <= maxHeight) {
      maxHeight = route.menuMaxHeight!;
    }
    // The width of a menu should be at most the view width. This ensures that
    // the menu does not extend past the left and right edges of the screen.
    final double width = math.min(constraints.maxWidth, buttonRect.width);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final _MenuLimits2 menuLimits =
        route.getMenuLimits(buttonRect, size.height, route.selectedIndex);

    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect) == buttonRect) {
        // If the button was entirely on-screen, then verify
        // that the menu is also on-screen.
        // If the button was a bit off-screen, then, oh well.
        assert(menuLimits.top >= 0.0);
        assert(menuLimits.top + menuLimits.height <= size.height);
      }
      return true;
    }());
    assert(textDirection != null);
    final double left;
    switch (textDirection!) {
      case TextDirection.rtl:
        left = buttonRect.right.clamp(0.0, size.width) - childSize.width;
        break;
      case TextDirection.ltr:
        left = buttonRect.left.clamp(0.0, size.width - childSize.width);
        break;
    }

    return Offset(left, menuLimits.top);
  }

  @override
  bool shouldRelayout(_MacosPopupMenuRouteLayout2<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        textDirection != oldDelegate.textDirection;
  }
}

// We box the return value so that the return value can be null. Otherwise,
// canceling the route (which returns null) would get confused with actually
// returning a real null value.
@immutable
class _MacosPopupRouteResult2<T> {
  const _MacosPopupRouteResult2(this.result);

  final T? result;

  @override
  bool operator ==(Object other) {
    return other is _MacosPopupRouteResult2<T> && other.result == result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _MenuLimits2 {
  const _MenuLimits2(
    this.top,
    this.bottom,
    this.height,
    this.scrollOffset,
    this.hasTopItemsNotShown,
    this.hasBottomItemsNotShown,
  );
  final double top;
  final double bottom;
  final double height;
  final double scrollOffset;
  final bool hasTopItemsNotShown;
  final bool hasBottomItemsNotShown;
}

class _MacosPopupRoute2<T> extends PopupRoute<_MacosPopupRouteResult2<T>> {
  _MacosPopupRoute2({
    required this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    required this.capturedThemes,
    required this.style,
    required this.caretColor,
    this.barrierLabel,
    this.itemHeight,
    this.popupColor,
    this.menuMaxHeight,
  }) : itemHeights = List<double>.filled(
          items.length,
          itemHeight ?? _kMinInteractiveDimension,
        );

  final ValueNotifier<double> itemWidth = ValueNotifier<double>(0.0);
  final List<_MenuItem2<T>> items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final CapturedThemes capturedThemes;
  final TextStyle style;
  final double? itemHeight;
  final Color? popupColor;
  final Color caretColor;
  final double? menuMaxHeight;

  final List<double> itemHeights;
  ScrollController? scrollController;

  @override
  Duration get transitionDuration => _kMacosPopupMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _MacosPopupRoutePage<T>(
          route: this,
          constraints: constraints,
          items: items,
          padding: padding,
          buttonRect: buttonRect,
          selectedIndex: selectedIndex,
          capturedThemes: capturedThemes,
          itemWidth: itemWidth,
          style: style,
          popupColor: popupColor,
          caretColor: caretColor,
        );
      },
    );
  }

  void _dismiss() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }

  double getItemOffset(int index) {
    double offset = 8.0;
    if (items.isNotEmpty && index > 0) {
      assert(items.length == itemHeights.length);
      offset += itemHeights
          .sublist(0, index)
          .reduce((double total, double height) => total + height);
    }
    return offset;
  }

  // Returns the vertical extent of the menu and the initial scrollOffset
  // for the ListView that contains the menu items. The vertical center of the
  // selected item is aligned with the button's vertical center, as far as
  // that's possible given availableHeight.
  _MenuLimits2 getMenuLimits(
    Rect buttonRect,
    double availableHeight,
    int index,
  ) {
    double computedMaxHeight = availableHeight - 2.0 * _kMenuItemHeight;
    if (menuMaxHeight != null) {
      computedMaxHeight = math.min(computedMaxHeight, menuMaxHeight!);
    }
    final double buttonTop = buttonRect.top;
    final double buttonBottom = math.min(buttonRect.bottom, availableHeight);
    final double selectedItemOffset = getItemOffset(index);

    // If the button is placed on the bottom or top of the screen, its top or
    // bottom may be less than [_kMenuItemHeight] from the edge of the screen.
    // In this case, we want to change the menu limits to align with the top
    // or bottom edge of the button.
    final double topLimit = math.min(_kMenuItemHeight, buttonTop);
    final double bottomLimit =
        math.max(availableHeight - _kMenuItemHeight, buttonBottom);

    double menuTop = (buttonTop - selectedItemOffset) -
        (itemHeights[selectedIndex] - buttonRect.height) / 2.0;
    double preferredMenuHeight = 8.0;
    if (items.isNotEmpty) {
      preferredMenuHeight +=
          itemHeights.reduce((double total, double height) => total + height);
    }

    // If there are too many elements in the menu, we need to shrink it down
    // so it is at most the computedMaxHeight.
    final double menuHeight = math.min(computedMaxHeight, preferredMenuHeight);
    double menuBottom = menuTop + menuHeight;

    // If the computed top or bottom of the menu are outside of the range
    // specified, we need to bring them into range. If the item height is larger
    // than the button height and the button is at the very bottom or top of the
    // screen, the menu will be aligned with the bottom or top of the button
    // respectively.
    if (menuTop < topLimit) {
      menuTop = math.min(buttonTop, topLimit);
      menuBottom = menuTop + menuHeight;
    }

    if (menuBottom > bottomLimit) {
      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    if (menuBottom - itemHeights[selectedIndex] / 2.0 <
        buttonBottom - buttonRect.height / 2.0) {
      menuBottom = buttonBottom -
          buttonRect.height / 2.0 +
          itemHeights[selectedIndex] / 2.0;
      menuTop = menuBottom - menuHeight;
    }

    double scrollOffset = 0;
    // If all of the menu items will not fit within availableHeight then
    // compute the scroll offset that will line the selected menu item up
    // with the select item. This is only done when the menu is first
    // shown - subsequently we leave the scroll offset where the user left
    // it. This scroll offset is only accurate for fixed height menu items
    // (the default).
    if (preferredMenuHeight > computedMaxHeight) {
      // The offset should be zero if the selected item is in view at the beginning
      // of the menu. Otherwise, the scroll offset should center the item if possible.
      scrollOffset = math.max(0.0, selectedItemOffset - (buttonTop - menuTop));
      // If the selected item's scroll offset is greater than the maximum scroll offset,
      // set it instead to the maximum allowed scroll offset.
      scrollOffset = math.min(scrollOffset, preferredMenuHeight - menuHeight);
    }
    bool hasTopItemsNotShown = preferredMenuHeight > computedMaxHeight &&
        scrollOffset > buttonRect.height / 2.0;
    bool hasBottomItemsNotShown = preferredMenuHeight > computedMaxHeight &&
        scrollOffset < buttonRect.height / 2.0;

    assert((menuBottom - menuTop - menuHeight).abs() < precisionErrorTolerance);
    return _MenuLimits2(
      menuTop,
      menuBottom,
      menuHeight,
      scrollOffset,
      hasTopItemsNotShown,
      hasBottomItemsNotShown,
    );
  }
}

// ignore: must_be_immutable
class _MacosPopupRoutePage<T> extends StatefulWidget {
  _MacosPopupRoutePage({
    super.key,
    required this.route,
    required this.constraints,
    this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    required this.capturedThemes,
    this.style,
    required this.popupColor,
    required this.caretColor,
    required this.itemWidth,
  });

  final ValueNotifier<double> itemWidth;
  final _MacosPopupRoute2<T> route;
  final BoxConstraints constraints;
  final List<_MenuItem2<T>>? items;
  final EdgeInsetsGeometry padding;
  Rect buttonRect;
  final int selectedIndex;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final Color? popupColor;
  final Color caretColor;

  @override
  State<_MacosPopupRoutePage<T>> createState() =>
      _MacosPopupRoutePageState<T>();
}

class _MacosPopupRoutePageState<T> extends State<_MacosPopupRoutePage<T>> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    return ValueListenableBuilder(
      valueListenable: widget.itemWidth,
      builder: (BuildContext context, double value, Widget? child) {
        if (widget.buttonRect.width < value) {
          widget.buttonRect = Rect.fromLTRB(
            widget.buttonRect.right - value,
            widget.buttonRect.top,
            widget.buttonRect.right,
            widget.buttonRect.bottom,
          );
        }

        // Computing the initialScrollOffset now, before the items have been laid
        // out. This only works if the item heights are effectively fixed, i.e. either
        // MacosPopupButton.itemHeight is specified or MacosPopupButton.itemHeight is null
        // and all of the items' intrinsic heights are less than _kMinInteractiveDimension.
        // Otherwise the initialScrollOffset is just a rough approximation based on
        // treating the items as if their heights were all equal to _kMinInteractiveDimension.
        final _MenuLimits2 menuLimits = widget.route.getMenuLimits(
            widget.buttonRect,
            widget.constraints.maxHeight,
            widget.selectedIndex);
        widget.route.scrollController ??=
            ScrollController(initialScrollOffset: menuLimits.scrollOffset);

        final TextDirection? textDirection = Directionality.maybeOf(context);
        final Widget menu = _MacosPopupMenu2<T>(
          route: widget.route,
          padding: widget.padding.resolve(textDirection),
          buttonRect: widget.buttonRect,
          constraints: widget.constraints,
          popupColor: widget.popupColor,
          caretColor: widget.caretColor,
          hasBottomItemsNotShown: menuLimits.hasBottomItemsNotShown,
          hasTopItemsNotShown: menuLimits.hasTopItemsNotShown,
        );

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: Builder(
            builder: (BuildContext context) {
              return CustomSingleChildLayout(
                delegate: _MacosPopupMenuRouteLayout2<T>(
                  buttonRect: widget.buttonRect,
                  route: widget.route,
                  textDirection: textDirection,
                ),
                child: widget.capturedThemes.wrap(menu),
              );
            },
          ),
        );
      },
    );
  }
}

// This widget enables _MacosPopupRoute to look up the sizes of
// each menu item. These sizes are used to compute the offset of the selected
// item so that _MacosPopupRoutePage can align the vertical center of the
// selected item lines up with the vertical center of the popup button,
// as closely as possible.
class _MenuItem2<T> extends SingleChildRenderObjectWidget {
  const _MenuItem2({
    super.key,
    required this.onLayout,
    required this.item,
  }) : super(child: item);

  final ValueChanged<Size> onLayout;
  final MacosPopupMenuItem2<T>? item;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMenuItem2(onLayout);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMenuItem2 renderObject,
  ) {
    renderObject.onLayout = onLayout;
  }
}

class _RenderMenuItem2 extends RenderProxyBox {
  _RenderMenuItem2(this.onLayout, [RenderBox? child]) : super(child);

  ValueChanged<Size> onLayout;

  @override
  void performLayout() {
    super.performLayout();
    onLayout(size);
  }
}

// The container widget for a menu item created by a [MacosPopupButton]. It
// provides the default configuration for [MacosPopupMenuItem]s, as well as a
// [MacosPopupButton]'s hint and disabledHint widgets.
class _MacosPopupMenuItemContainer2 extends StatelessWidget {
  /// Creates an item for a popup menu.
  ///
  /// The [child] argument is required.
  const _MacosPopupMenuItemContainer2({
    super.key,
    this.alignment = AlignmentDirectional.centerStart,
    required this.child,
  });

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  /// Defines how the item is positioned within the container.
  ///
  /// This property must not be null. It defaults to [AlignmentDirectional.centerStart].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _kMenuItemHeight),
      alignment: alignment,
      child: child,
    );
  }
}

/// An item in a menu created by a [MacosPopupButton2].
///
/// The type `T` is the type of the value the entry represents. All the entries
/// in a given menu must represent values with consistent types.
class MacosPopupMenuItem2<T> extends _MacosPopupMenuItemContainer2 {
  /// Creates an item for a macOS-style popup menu.
  ///
  /// The [child] argument is required.
  const MacosPopupMenuItem2({
    super.key,
    this.onTap,
    this.value,
    this.enabled = true,
    super.alignment,
    required super.child,
  });

  /// Called when the popup menu item is tapped.
  final VoidCallback? onTap;

  /// The value to return if the user selects this menu item.
  ///
  /// Eventually returned in a call to [MacosPopupButton2.onChanged].
  final T? value;

  /// Whether or not a user can select this menu item.
  ///
  /// Defaults to `true`.
  final bool enabled;
}

/// A macOS-style pop-up button.
///
/// A pop-up button (often referred to as a pop-up menu) is a type of button
/// that, when clicked, displays a menu containing a list of mutually exclusive
/// choices.
/// A pop-up button includes a double-arrow indicator that alludes to the
/// direction in which the menu will appear (only vertical is currently
/// supported).
///
/// The type `T` is the type of the [value] that each popup item represents.
/// All the entries in a given menu must represent values with consistent types.
/// Typically, an enum is used. Each [MacosPopupMenuItem2] in [items] must be
/// specialized with that same type argument.
///
/// The [onChanged] callback should update a state variable that defines the
/// popup's value. It should also call [State.setState] to rebuild the
/// popup with the new value.
///
/// If the [onChanged] callback is null or the list of [items] is null
/// then the popup button will be disabled, i.e. its arrow will be
/// displayed in grey and it will not respond to input. A disabled button
/// will display the [disabledHint] widget if it is non-null. However, if
/// [disabledHint] is null and [hint] is non-null, the [hint] widget will
/// instead be displayed.
///
/// See also:
///
///  * [MacosPopupMenuItem2], the class used to represent the [items].
class MacosPopupButton2<T> extends StatefulWidget {
  /// Creates a macOS-style popup button.
  ///
  /// The [items] must have distinct values. If [value] isn't null then it
  /// must be equal to one of the [MacosPopupMenuItem2] values. If [items] or
  /// [onChanged] is null, the button will be disabled, the up-down caret
  /// icon will be greyed out.
  ///
  /// If [value] is null and the button is enabled, [hint] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [hint] will be displayed
  /// if it is non-null.
  ///
  /// The [autofocus] argument must not be null.
  ///
  /// The [popupColor] argument specifies the background color of the
  /// popup when it is open. If it is null, the appropriate macOS canvas color
  /// will be used.
  MacosPopupButton2(
      {super.key,
      required this.items,
      this.selectedItemBuilder,
      this.value,
      this.hint,
      this.disabledHint,
      required this.onChanged,
      this.onTap,
      this.itemHeight = _kMinInteractiveDimension,
      this.focusNode,
      this.autofocus = false,
      this.popupColor,
      this.menuMaxHeight})
      : assert(
          items == null ||
              items.isEmpty ||
              value == null ||
              items.where((MacosPopupMenuItem2<T> item) {
                    return item.value == value && item.enabled;
                  }).length ==
                  1,
          "There should be exactly one item with [MacosPopupButton]'s value: "
          '$value. \n'
          'Either zero or 2 or more [MacosPopupMenuItem]s were detected '
          'with the same value',
        ),
        assert(itemHeight >= _kMinInteractiveDimension);

  /// The list of items the user can select.
  ///
  /// If the [onChanged] callback is null or the list of items is null
  /// then the popup button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input.
  final List<MacosPopupMenuItem2<T>>? items;

  /// The value of the currently selected [MacosPopupMenuItem2].
  ///
  /// If [value] is null and the button is enabled, [hint] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [hint] will be displayed
  /// if it is non-null.
  final T? value;

  /// A placeholder widget that is displayed by the popup button.
  ///
  /// If [value] is null and the popup is enabled ([items] and [onChanged] are non-null),
  /// this widget is displayed as a placeholder for the popup button's value.
  ///
  /// If [value] is null and the popup is disabled and [disabledHint] is null,
  /// this widget is used as the placeholder.
  final Widget? hint;

  /// A preferred placeholder widget that is displayed when the popup is disabled.
  ///
  /// If [value] is null, the popup is disabled ([items] or [onChanged] is null),
  /// this widget is displayed as a placeholder for the popup button's value.
  final Widget? disabledHint;

  /// Called when the user selects an item.
  ///
  /// If the [onChanged] callback is null or the list of [MacosPopupButton2.items]
  /// is null then the popup button will be disabled, i.e. its up/down caret will
  /// be displayed in grey and it will not respond to input. A disabled button
  /// will display the [MacosPopupButton2.disabledHint] widget if it is non-null.
  /// If [MacosPopupButton2.disabledHint] is also null but [MacosPopupButton2.hint] is
  /// non-null, [MacosPopupButton2.hint] will instead be displayed.
  final ValueChanged<T?>? onChanged;

  /// Called when the popup button is tapped.
  ///
  /// This is distinct from [onChanged], which is called when the user
  /// selects an item from the popup.
  ///
  /// The callback will not be invoked if the popup button is disabled.
  final VoidCallback? onTap;

  /// A builder to customize the popup buttons corresponding to the
  /// [MacosPopupMenuItem2]s in [items].
  ///
  /// When a [MacosPopupMenuItem2] is selected, the widget that will be displayed
  /// from the list corresponds to the [MacosPopupMenuItem2] of the same index
  /// in [items].
  ///
  /// If this callback is null, the [MacosPopupMenuItem2] from [items]
  /// that matches [value] will be displayed.
  final MacosPopupButton2Builder? selectedItemBuilder;

  /// If null, then the menu item heights will vary according to each menu item's
  /// intrinsic height.
  ///
  /// The default value is [_kMinInteractiveDimension], which is also the minimum
  /// height for menu items.
  ///
  final double itemHeight;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The background color of the popup.
  ///
  /// If it is not provided, the the appropriate macOS canvas color
  /// will be used.
  final Color? popupColor;

  /// The maximum height of the menu.
  ///
  /// The maximum height of the menu must be at least one row shorter than
  /// the height of the app's view. This ensures that a tappable area
  /// outside of the simple menu is present so the user can dismiss the menu.
  ///
  /// If this property is set above the maximum allowable height threshold
  /// mentioned above, then the menu defaults to being padded at the top
  /// and bottom of the menu by at one menu item's height.
  final double? menuMaxHeight;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty(
      'itemHeight',
      itemHeight,
      defaultValue: kMinInteractiveDimension,
    ));
    properties.add(
      FlagProperty('hasAutofocus', value: autofocus, ifFalse: 'noAutofocus'),
    );
    properties.add(ColorProperty('popupColor', popupColor));
    properties.add(DoubleProperty('menuMaxHeight', menuMaxHeight));
  }

  @override
  State<MacosPopupButton2<T>> createState() => _MacosPopupButton2State<T>();
}

class _MacosPopupButton2State<T> extends State<MacosPopupButton2<T>>
    with WidgetsBindingObserver {
  int? _selectedIndex;
  _MacosPopupRoute2<T>? _popupRoute;
  FocusNode? _internalNode;
  FocusNode? get focusNode => widget.focusNode ?? _internalNode;
  bool _hasPrimaryFocus = false;
  late Map<Type, Action<Intent>> _actionMap;
  late FocusHighlightMode _focusHighlightMode;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _handleTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => _handleTap(),
      ),
    };
    focusNode!.addListener(_handleFocusChanged);
    final FocusManager focusManager = WidgetsBinding.instance.focusManager;
    _focusHighlightMode = focusManager.highlightMode;
    focusManager.addHighlightModeListener(_handleFocusHighlightModeChange);
  }

  @override
  void didUpdateWidget(MacosPopupButton2<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalNode ??= _createFocusNode();
      }
      _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      focusNode!.addListener(_handleFocusChanged);
    }
    _updateSelectedIndex();
  }

  // Only used if needed to create _internalNode.
  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  void _removeMacosPopupRoute() {
    _popupRoute?._dismiss();
    _popupRoute = null;
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode!.hasPrimaryFocus) {
      setState(() => _hasPrimaryFocus = focusNode!.hasPrimaryFocus);
    }
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() => _focusHighlightMode = mode);
  }

  void _updateSelectedIndex() {
    if (widget.items == null ||
        widget.items!.isEmpty ||
        (widget.value == null &&
            widget.items!
                .where((MacosPopupMenuItem2<T> item) =>
                    item.enabled && item.value == widget.value)
                .isEmpty)) {
      _selectedIndex = null;
      return;
    }

    assert(widget.items!
            .where((MacosPopupMenuItem2<T> item) => item.value == widget.value)
            .length ==
        1);
    for (int itemIndex = 0; itemIndex < widget.items!.length; itemIndex++) {
      if (widget.items![itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  void _handleTap() {
    final TextDirection? textDirection = Directionality.maybeOf(context);
    const EdgeInsetsGeometry menuMargin = EdgeInsets.symmetric(horizontal: 6.0);
    final popupTheme = MacosPopupButtonTheme2.of(context);

    double maxWidth = 0;

    final List<_MenuItem2<T>> menuItems = <_MenuItem2<T>>[
      for (int index = 0; index < widget.items!.length; index += 1)
        _MenuItem2<T>(
          item: widget.items![index],
          onLayout: (Size size) {
            // If [_popupRoute] is null and onLayout is called, this means
            // that performLayout was called on a _MacosPopupRoute that has not
            // left the widget tree but is already on its way out.
            //
            // Since onLayout is used primarily to collect the desired heights
            // of each menu item before laying them out, not having the _MacosPopupRoute
            // collect each item's height to lay out is fine since the route is
            // already on its way out.
            if (_popupRoute == null) return;

            maxWidth = math.max(
                maxWidth,
                size.width +
                    _kMenuItemPadding.horizontal +
                    _kIconSize +
                    _kIconPadding.horizontal +
                    _kMenuItemPaddingInner +
                    12);

            _popupRoute!.itemHeights[index] = size.height;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _popupRoute!.itemWidth.value = maxWidth;
            });
          },
        ),
    ];

    final NavigatorState navigator = Navigator.of(context);
    assert(_popupRoute == null);
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;

    final Rect itemRect = itemBox.localToGlobal(
          _kPopupRouteOffset,
          ancestor: navigator.context.findRenderObject(),
        ) &
        itemBox.size;
    _popupRoute = _MacosPopupRoute2<T>(
      items: menuItems,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: _kMenuItemPadding.resolve(textDirection),
      selectedIndex: _selectedIndex ?? 0,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      style: _textStyle!,
      caretColor: popupTheme.caretColor,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      itemHeight: widget.itemHeight,
      popupColor: widget.popupColor,
      menuMaxHeight: widget.menuMaxHeight,
    );

    navigator
        .push(_popupRoute!)
        .then<void>((_MacosPopupRouteResult2<T>? newValue) {
      _removeMacosPopupRoute();
      if (!mounted || newValue == null) return;
      widget.onChanged?.call(newValue.result);
    });

    widget.onTap?.call();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeMacosPopupRoute();
    WidgetsBinding.instance.focusManager
        .removeHighlightModeListener(_handleFocusHighlightModeChange);
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    super.dispose();
  }

  TextStyle? get _textStyle => MacosTheme.of(context).typography.body;

  bool get enabled =>
      widget.items != null &&
      widget.items!.isNotEmpty &&
      widget.onChanged != null;

  bool get _showHighlight {
    switch (_focusHighlightMode) {
      case FocusHighlightMode.touch:
        return false;
      case FocusHighlightMode.traditional:
        return _hasPrimaryFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    // The width of the button and the menu are defined by the widest
    // item and the width of the hint.
    // We should explicitly type the items list to be a list of <Widget>,
    // otherwise, no explicit type adding items maybe trigger a crash/failure
    // when hint and selectedItemBuilder are provided.
    final List<Widget> items = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.from(widget.items!) : <Widget>[])
        : List<Widget>.from(widget.selectedItemBuilder!(context));

    int? hintIndex;
    if (widget.hint != null || (!enabled && widget.disabledHint != null)) {
      Widget displayedHint =
          enabled ? widget.hint! : widget.disabledHint ?? widget.hint!;
      if (widget.selectedItemBuilder == null) {
        displayedHint = _MacosPopupMenuItemContainer2(child: displayedHint);
      }

      hintIndex = items.length;

      items.add(
        ExcludeSemantics(
          child: IgnorePointer(
            child: displayedHint,
          ),
        ),
      );
    }

    // If value is null (then _selectedIndex is null) then we
    // display the hint or nothing at all.
    final Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      final selectedIndex = _selectedIndex ?? hintIndex;
      innerItemsWidget = IndexedStack(
        index: selectedIndex,
        children: items.mapIndexed((int index, Widget item) {
          return Visibility(
            visible: index == selectedIndex,
            child: SizedBox(
                height: widget.itemHeight,
                child: Padding(
                  padding: const EdgeInsets.only(right: _kMenuItemPaddingInner),
                  child: item,
                )),
          );
        }).toList(),
      );
    }
    final buttonStyles = _getButtonStyles(enabled, context);

    Widget result = DefaultTextStyle(
      style: _textStyle!.copyWith(
        color: buttonStyles.textColor,
      ),
      child: MouseRegion(
        onEnter: enabled ? (event) => setState(() => _hovered = true) : null,
        onExit: enabled ? (event) => setState(() => _hovered = false) : null,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              if (_showHighlight) ...[
                const BoxShadow(
                    color: MacosColors.keyboardFocusIndicatorColor,
                    offset: Offset(0, 0),
                    blurRadius: 0,
                    spreadRadius: 2,
                    blurStyle: BlurStyle.solid),
              ],
              if (_hovered) ...[
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 0.5),
                  blurRadius: 0.1,
                  spreadRadius: 0.1,
                ),
              ]
            ],
            color: _showHighlight || _hovered
                ? buttonStyles.backgroundColorHover
                : buttonStyles.backgroundColor,
            gradient: LinearGradient(
                colors: buttonStyles.borderColors,
                stops: const [0.4, 1.0],
                tileMode: TileMode.clamp,
                transform: const GradientRotation(math.pi / 2)),
            border: Border.all(width: 0.5, color: Colors.transparent),
            borderRadius: _kBorderRadius,
          ),
          height: _kPopupButtonHeight,
          child: Container(
            padding: const EdgeInsets.only(
                left: 10.0, right: 4.0, top: 1.0, bottom: 1.0),
            decoration: BoxDecoration(
              borderRadius: _kBorderRadius,
              color: _showHighlight || _hovered
                  ? buttonStyles.backgroundColorHover
                  : buttonStyles.backgroundColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                innerItemsWidget,
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: SizedBox(
                    height: _kPopupButtonHeight - 7,
                    width: _kPopupButtonHeight - 7,
                    child: CustomPaint(
                      painter: _UpDownCaretsPainter2(
                        color: buttonStyles.caretColor,
                        backgroundColor: _hovered
                            ? Colors.transparent
                            : buttonStyles.caretBackgroundColor,
                        borderColor: _hovered
                            ? Colors.transparent
                            : buttonStyles.caretBorderColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: Focus(
          canRequestFocus: enabled,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          child: MouseRegion(
            cursor: SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: enabled ? _handleTap : null,
              behavior: HitTestBehavior.opaque,
              child: result,
            ),
          ),
        ),
      ),
    );
  }
}

// We use this utility function to get the appropriate styling, according to the
// macOS Design Guidelines and the current MacosPopupButtonTheme.
_ButtonStyles2 _getButtonStyles(
  bool enabled,
  BuildContext context,
) {
  final theme = MacosTheme.of(context);
  final brightness = theme.brightness;
  final popupTheme = MacosPopupButtonTheme2.of(context);

  Color? textColor = popupTheme.textColor ?? theme.typography.body.color;
  Color backgroundColor = popupTheme.backgroundColor;
  Color careBorderColor = popupTheme.caretBorderColor;
  Color caretBackgroundColor = popupTheme.caretBackgroundColor;
  Color caretColor = popupTheme.caretColor;

  if (!enabled) {
    careBorderColor = Colors.transparent;
    caretBackgroundColor = MacosColors.transparent;
    textColor = caretColor = brightness.resolve(
      MacosColors.disabledControlTextColor.color,
      MacosColors.disabledControlTextColor.darkColor,
    );
    backgroundColor = popupTheme.backgroundColorDisabled;
  }
  return _ButtonStyles2(
    textColor: textColor,
    backgroundColor: backgroundColor,
    backgroundColorHover: popupTheme.backgroundColorHover,
    borderColors: popupTheme.borderColors,
    caretColor: caretColor,
    caretBackgroundColor: caretBackgroundColor,
    caretBorderColor: careBorderColor,
  );
}

class _ButtonStyles2 {
  _ButtonStyles2({
    this.textColor,
    required this.backgroundColor,
    required this.backgroundColorHover,
    required this.borderColors,
    required this.caretColor,
    required this.caretBackgroundColor,
    required this.caretBorderColor,
  });

  Color? textColor;
  Color backgroundColor;
  Color backgroundColorHover;
  List<Color> borderColors;
  Color caretColor;
  Color caretBackgroundColor;
  Color caretBorderColor;
}

class _UpDownCaretsPainter2 extends CustomPainter {
  const _UpDownCaretsPainter2({
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 3.0;
    final vPadding = size.height / 8 + 1;
    final hPadding = 2 * size.height / 8 + 1;

    final rectPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    /// Draw background
    canvas.drawRRect(
      BorderRadius.circular(radius).toRRect(Offset.zero & size),
      rectPaint,
    );

    rectPaint.style = PaintingStyle.stroke;
    rectPaint.color = borderColor;

    canvas.drawRRect(
      BorderRadius.circular(radius).toRRect(Offset.zero & size),
      rectPaint,
    );

    /// Draw carets
    final p1 = Offset(hPadding, size.height / 2 - 2.0);
    final p2 = Offset(size.width / 2, vPadding);
    final p3 = Offset(size.width / 2 + 1.0, vPadding + 1.0);
    final p4 = Offset(size.width - hPadding, size.height / 2 - 2.0);
    final p5 = Offset(hPadding, size.height / 2 + 2.0);
    final p6 = Offset(size.width / 2, size.height - vPadding);
    final p7 = Offset(size.width / 2 + 1.0, size.height - vPadding - 1.0);
    final p8 = Offset(size.width - hPadding, size.height / 2 + 2.0);
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    canvas.drawLine(p1, p2, paint);
    canvas.drawLine(p3, p4, paint);
    canvas.drawLine(p5, p6, paint);
    canvas.drawLine(p7, p8, paint);
  }

  @override
  bool shouldRepaint(_UpDownCaretsPainter2 oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_UpDownCaretsPainter2 oldDelegate) => false;
}
