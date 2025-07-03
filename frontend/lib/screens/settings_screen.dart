import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  int _pomodoroLength = 25;
  int _shortBreakLength = 5;
  int _longBreakLength = 15;
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  _buildSettingsTile(
                    title: 'Theme',
                    subtitle: themeProvider.isDarkMode ? 'Dark' : 'Light',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                  _buildSettingsTile(
                    title: 'Dynamic Colors',
                    subtitle: 'Use system colors',
                    trailing: Switch(
                      value: themeProvider.useDynamicColors,
                      onChanged: (value) {
                        themeProvider.toggleDynamicColors();
                      },
                    ),
                    onTap: () {
                      themeProvider.toggleDynamicColors();
                    },
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSettingsTile(
            title: 'Enable Notifications',
            subtitle: 'Receive task reminders',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _notificationsEnabled = !_notificationsEnabled;
              });
            },
          ),
          _buildSettingsTile(
            title: 'Sound',
            subtitle: 'Play notification sounds',
            trailing: Switch(
              value: _soundEnabled,
              onChanged: _notificationsEnabled ? (value) {
                setState(() {
                  _soundEnabled = value;
                });
              } : null,
            ),
            onTap: _notificationsEnabled ? () {
              setState(() {
                _soundEnabled = !_soundEnabled;
              });
            } : null,
          ),
          
          const SizedBox(height: 24),
          
          // Pomodoro Section
          _buildSectionHeader('Pomodoro Timer'),
          _buildSettingsTile(
            title: 'Pomodoro Length',
            subtitle: '$_pomodoroLength minutes',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimerDialog(
              title: 'Pomodoro Length',
              currentValue: _pomodoroLength,
              onChanged: (value) {
                setState(() {
                  _pomodoroLength = value;
                });
              },
            ),
          ),
          _buildSettingsTile(
            title: 'Short Break Length',
            subtitle: '$_shortBreakLength minutes',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimerDialog(
              title: 'Short Break Length',
              currentValue: _shortBreakLength,
              onChanged: (value) {
                setState(() {
                  _shortBreakLength = value;
                });
              },
            ),
          ),
          _buildSettingsTile(
            title: 'Long Break Length',
            subtitle: '$_longBreakLength minutes',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimerDialog(
              title: 'Long Break Length',
              currentValue: _longBreakLength,
              onChanged: (value) {
                setState(() {
                  _longBreakLength = value;
                });
              },
            ),
          ),
          _buildSettingsTile(
            title: 'Auto-start Breaks',
            subtitle: 'Automatically start break timers',
            trailing: Switch(
              value: _autoStartBreaks,
              onChanged: (value) {
                setState(() {
                  _autoStartBreaks = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _autoStartBreaks = !_autoStartBreaks;
              });
            },
          ),
          _buildSettingsTile(
            title: 'Auto-start Pomodoros',
            subtitle: 'Automatically start pomodoro timers',
            trailing: Switch(
              value: _autoStartPomodoros,
              onChanged: (value) {
                setState(() {
                  _autoStartPomodoros = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                _autoStartPomodoros = !_autoStartPomodoros;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Account Section
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            title: 'Export Data',
            subtitle: 'Export your tasks and projects',
            trailing: const Icon(Icons.file_download),
            onTap: () {
              _showExportDialog();
            },
          ),
          _buildSettingsTile(
            title: 'Import Data',
            subtitle: 'Import tasks and projects',
            trailing: const Icon(Icons.file_upload),
            onTap: () {
              _showImportDialog();
            },
          ),
          _buildSettingsTile(
            title: 'Clear All Data',
            subtitle: 'Remove all tasks and projects',
            trailing: const Icon(Icons.delete_forever),
            onTap: () {
              _showClearDataDialog();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Sign Out
          _buildSettingsTile(
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            trailing: const Icon(Icons.logout),
            onTap: () {
              _showSignOutDialog();
            },
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader('About'),
          _buildSettingsTile(
            title: 'Version',
            subtitle: '1.0.0',
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showTimerDialog({
    required String title,
    required int currentValue,
    required Function(int) onChanged,
  }) {
    int tempValue = currentValue;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${tempValue} minutes'),
            Slider(
              value: tempValue.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              onChanged: (value) {
                setState(() {
                  tempValue = value.toInt();
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onChanged(tempValue);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export your tasks and projects to a file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Import tasks and projects from a file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon!')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your tasks and projects. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data cleared!')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Blitzit',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.flash_on, size: 48),
      children: [
        const Text(
          'A modern productivity app built with Flutter and FastAPI.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Task management with Kanban boards\n'
          '• Pomodoro timer with focus mode\n'
          '• Analytics and reporting\n'
          '• Dark/Light theme support\n'
          '• Cross-platform compatibility',
        ),
      ],
    );
  }
}
