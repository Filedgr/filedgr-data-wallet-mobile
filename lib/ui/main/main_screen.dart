import 'package:file_dgr/ui/about/about.dart';
import 'package:file_dgr/ui/home/home.dart';
import 'package:file_dgr/ui/utils/theme_provider.dart';
import 'package:file_dgr/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The main screen that hosts the *Home* and *About* screens.
class MainScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MainScreen({super.key, required this.themeProvider});

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  MenuOption _selectedItem = MenuOption.home;
  String? _flavorName;

  /// Initializes the state and loads the current flavor name.
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        setState(() {
          if (packageInfo.packageName.endsWith('.dev')) {
            _flavorName = 'DEV';
          } else if (packageInfo.packageName.endsWith('.qa')) {
            _flavorName = 'QA';
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('FileDGR'.toUpperCase()),
          ),
          body: Builder(builder: (context) {
            if (_selectedItem == MenuOption.home) {
              return const Home();
            } else {
              return const About();
            }
          }),
          drawer: SafeArea(
            child: SizedBox(
              child: Drawer(
                child: AppDrawer(
                  selectedItem: _selectedItem,
                  selectedThemeMode: widget.themeProvider.themeMode.name,
                  onSelected: (menuOption) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedItem = menuOption;
                    });
                  },
                  onChangedTheme: (newThemeMode) {
                    if (newThemeMode == null) return;
                    widget.themeProvider.saveTheme(newThemeMode);
                  },
                ),
              ),
            ),
          ),
        ),
        if (_flavorName != null) ...[
          Banner(message: _flavorName!, location: BannerLocation.topStart),
        ],
      ],
    );
  }
}

/// The widget that displays the app drawer.
class AppDrawer extends StatelessWidget {
  final MenuOption selectedItem;
  final String selectedThemeMode;
  final Function(MenuOption) onSelected;
  final Function(String?) onChangedTheme;

  const AppDrawer({
    Key? key,
    required this.selectedItem,
    required this.selectedThemeMode,
    required this.onSelected,
    required this.onChangedTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuItem(
              MenuOption.home.title,
              isSelected: MenuOption.home == selectedItem,
              onTap: () => onSelected(MenuOption.home),
            ),
            MenuItem(
              MenuOption.about.title,
              isSelected: MenuOption.about == selectedItem,
              onTap: () => onSelected(MenuOption.about),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Theme:', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 40),
              DropdownButton<String>(
                underline: const SizedBox(),
                value: selectedThemeMode.capitalize(),
                items: ThemeMode.values
                    .map(
                      (value) => DropdownMenuItem<String>(
                    value: value.name.capitalize(),
                    child: Text(value.name.capitalize()),
                  ),
                )
                    .toList(),
                onChanged: (newThemeMode) =>
                    onChangedTheme(newThemeMode?.toLowerCase()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The widget that displays a menu option.
class MenuItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MenuItem(
    this.label, {
    Key? key,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: onTap,
      selected: isSelected,
    );
  }
}

/// An enum that lists all options that will be displayed in the menu.
enum MenuOption {
  home('Home'),
  about('About');

  const MenuOption(this.title);

  final String title;
}
