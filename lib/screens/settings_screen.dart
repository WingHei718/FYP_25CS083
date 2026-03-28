import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const cardContentPadding = 15.0;
  static const Widget spaceBetweenIconAndText = SizedBox(width: 12);
  static const Widget spaceBetweenRows = SizedBox(height: 12);
  static const Widget spaceBetweenCardHeaderAndContent = SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
          // Appearance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(cardContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      spaceBetweenIconAndText,
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  spaceBetweenCardHeaderAndContent,
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Column(
                        children: [
                          _buildThemeOption(
                            context,
                            'System Default',
                            'Follow system theme settings',
                            Icons.brightness_auto,
                            ThemeMode.system,
                            themeProvider,
                          ),
                          spaceBetweenRows,
                          _buildThemeOption(
                            context,
                            'Light Mode',
                            'Always use light theme',
                            Icons.light_mode,
                            ThemeMode.light,
                            themeProvider,
                          ),
                          spaceBetweenRows,
                          _buildThemeOption(
                            context,
                            'Dark Mode',
                            'Always use dark theme',
                            Icons.dark_mode,
                            ThemeMode.dark,
                            themeProvider,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // AR Settings Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(cardContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.view_in_ar_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      spaceBetweenIconAndText,
                      Text(
                        'AR Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  spaceBetweenCardHeaderAndContent,
                  Consumer<SettingsModel>(
                    builder: (context, settingsModel, child) {
                      return Column(
                        children: [
                          _buildSettingsTile(
                            context,
                            'Hand Tracking',
                            'Enable hand tracking for 3D model movement',
                            Icons.pan_tool_outlined,
                            settingsModel.handTrackingEnabled,
                            (value) => settingsModel.setHandTrackingEnabled(value),
                          ),
                          spaceBetweenRows,
                          _buildSettingsTile(
                            context,
                            'Testing Mode',
                            'Enable testing mode',
                            Icons.visibility_outlined,
                            settingsModel.testingModeEnabled,
                            (value) => settingsModel.setTestingModeEnabled(value),
                          ),
                          spaceBetweenRows,
                          _buildDropdownTile(
                            context,
                            'Target Finger',
                            'Select a finger to place the ring on',
                            Icons.fingerprint,
                            settingsModel.targetFinger,
                            ['thumb', 'index', 'middle', 'ring', 'pinky'],
                            (value) => settingsModel.setTargetFinger(value!),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(cardContentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      spaceBetweenIconAndText,
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  spaceBetweenCardHeaderAndContent,
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.android,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          spaceBetweenIconAndText,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "App Version",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  "1.0.0",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildThemeOption(BuildContext context, String title, String subtitle, IconData icon, ThemeMode themeMode, ThemeProvider themeProvider) {
    final isSelected = themeProvider.themeMode == themeMode;
    
    return InkWell(
      onTap: () => themeProvider.setThemeMode(themeMode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            spaceBetweenIconAndText,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        spaceBetweenIconAndText,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownTile(BuildContext context, String title, String subtitle, IconData icon, String currentValue, List<String> options, ValueChanged<String?> onChanged,) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        spaceBetweenIconAndText,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        DropdownButton<String>(
          value: currentValue,
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value[0].toUpperCase() + value.substring(1)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
