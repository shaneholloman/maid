import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_preferences.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/session.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:maid/ui/shared/dropdowns/app_layout_dropdown.dart';
import 'package:maid/ui/shared/dropdowns/theme_mode_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsPanel extends StatelessWidget {
  const AppSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                Expanded(
                  child: Text(
                    "Theme Mode",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16
                    )
                  ),
                ),
                const ThemeModeDropdown()
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                Expanded(
                  child: Text(
                    "Application Layout",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16
                    )
                  ),
                ),
                const AppLayoutDropdown()
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.clear();
                AppPreferences.of(context).reset();
                User.of(context).reset();
                Session.of(context).reset();
                Character.of(context).reset();
                Logger.clear();
              });
            },
            child: const Text("Clear Cache"),
          ),
        ]
      ),
    );
  }
}