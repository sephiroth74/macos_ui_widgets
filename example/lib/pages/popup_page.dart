import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui_widgets/macos_ui_widgets.dart';

class PopupButton2Page extends StatefulWidget {
  const PopupButton2Page({super.key});

  @override
  State<PopupButton2Page> createState() => _PopupButton2PageState();
}

class _PopupButton2PageState extends State<PopupButton2Page> {
  int? popupButtonValue1 = 1;
  String? popupButtonValue2;
  int? popupButtonValue3;

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text(
          'MacosPopupButton2',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: MacosTooltip(
          message: 'Toggle Sidebar',
          useMousePosition: false,
          child: MacosIconButton(
            icon: MacosIcon(
              CupertinoIcons.sidebar_left,
              color: MacosTheme.brightnessOf(context).resolve(
                const Color.fromRGBO(0, 0, 0, 0.5),
                const Color.fromRGBO(255, 255, 255, 0.5),
              ),
              size: 20.0,
            ),
            boxConstraints: const BoxConstraints(
              minHeight: 20,
              minWidth: 20,
              maxWidth: 48,
              maxHeight: 38,
            ),
            onPressed: () => MacosWindowScope.of(context).toggleSidebar(),
          ),
        ),
      ),
      children: [
        ContentArea(
          builder: (context, _) {
            final theme = MacosTheme.of(context);
            final containerDecoration = BoxDecoration(
              border: Border.all(
                color: theme.dividerColor,
                width: 0.5,
              ),
              color: MacosColors.systemGrayColor
                  .resolveFrom(context)
                  .withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.0),
            );
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: containerDecoration,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(flex: 0, child: Text('Appearance')),
                          const Spacer(),
                          Builder(
                            builder: (context) {
                              return MacosPopupButton2<int>(
                                  autofocus: false,
                                  disabledHint:
                                      const Text('Select a color (disabled)'),
                                  hint: const Text('Select a color'),
                                  value: popupButtonValue1,
                                  items: [
                                    [Colors.blue.shade100, 'Blue', 0],
                                    [Colors.purple.shade100, 'Purple', 1],
                                    [Colors.pink.shade100, 'Pink', 2],
                                    [Colors.red.shade100, 'Red', 3],
                                    [Colors.orange.shade100, 'Orange', 4],
                                    [Colors.yellow.shade100, 'Yellow', 5],
                                    [Colors.green.shade100, 'Green', 6],
                                    [Colors.grey.shade100, 'Graphite', 7],
                                  ].map((element) {
                                    return MacosPopupMenuItem2(
                                        enabled: element[2] != 0,
                                        value: element[2] as int,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                  color: element[0] as Color,
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xffcecece),
                                                    width: 0.5,
                                                  )),
                                            ),
                                            const SizedBox(width: 6),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.0),
                                              child: Text(element[1] as String),
                                            ),
                                          ],
                                        ));
                                  }).toList(),
                                  onChanged: (value) {
                                    debugPrint('selected value: $value');
                                    setState(
                                        () => popupButtonValue1 = value as int);
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: containerDecoration,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                              flex: 0, child: Text('Sidebar icon size')),
                          const Spacer(),
                          Builder(
                            builder: (context) {
                              return MacosPopupButton2<String>(
                                  autofocus: false,
                                  disabledHint: const Text('Size'),
                                  hint: const Text('Pick a size'),
                                  value: popupButtonValue2,
                                  items: const [
                                    MacosPopupMenuItem2(
                                        value: 'large', child: Text('Large')),
                                    MacosPopupMenuItem2(
                                        value: 'medium', child: Text('Medium')),
                                    MacosPopupMenuItem2(
                                        value: 'small', child: Text('Small')),
                                  ],
                                  onChanged: (value) {
                                    debugPrint('selected value: $value');
                                    setState(() =>
                                        popupButtonValue2 = value as String);
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: containerDecoration,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(flex: 0, child: Text('Refresh rate')),
                          const Spacer(),
                          Builder(
                            builder: (context) {
                              return MacosPopupButton2<int>(
                                  autofocus: false,
                                  value: null,
                                  hint: const Text('Refresh rate'),
                                  items: const [
                                    MacosPopupMenuItem2(
                                        value: 60, child: Text('60 Hertz')),
                                    MacosPopupMenuItem2(
                                        value: 50, child: Text('50 Hertz')),
                                    MacosPopupMenuItem2(
                                        value: 30, child: Text('30 Hertz')),
                                    MacosPopupMenuItem2(
                                        value: 25, child: Text('25 Hertz')),
                                    MacosPopupMenuItem2(
                                        value: 24, child: Text('24 Hertz')),
                                  ],
                                  onChanged: null);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
