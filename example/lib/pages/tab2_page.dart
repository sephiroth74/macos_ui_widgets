import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_ui_widgets/macos_ui_widgets.dart';

class TabView2Page extends StatefulWidget {
  const TabView2Page({super.key});

  @override
  State<TabView2Page> createState() => _TabViewPageState();
}

class _TabViewPageState extends State<TabView2Page> {
  final _controller = MacosTabController(
    initialIndex: 0,
    length: 4,
  );

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('TabView'),
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
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: MacosTabView2(
                onTabChanged: (value) => debugPrint('Tab changed to $value'),
                controller: _controller,
                tabs: const [
                  MacosTab2(label: 'Tab 1'),
                  MacosTab2(label: 'Tab 2'),
                  MacosTab2(label: 'Tab 3'),
                  MacosTab2(label: 'Tab 4'),
                ],
                children: const [
                  Center(child: Text('Tab 1')),
                  Center(child: Text('Tab 2')),
                  Center(child: Text('Tab 3')),
                  Center(child: Text('Tab 4')),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
