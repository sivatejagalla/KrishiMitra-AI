import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/utils/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final baseUrl = ref.watch(apiClientProvider);
    final api = ref.watch(dioProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Appearance & Theme',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32))),
          ),
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Enable dark mode for lower eye strain at night'),
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeProvider.notifier).setTheme(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Application Language'),
            subtitle: Text(AppConstants.languageNames[locale.languageCode] ?? locale.languageCode),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AppConstants.supportedLanguages.map((code) {
                      final name = AppConstants.languageNames[code] ?? code;
                      return RadioListTile<String>(
                        title: Text(name),
                        value: code,
                        groupValue: locale.languageCode,
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(localeProvider.notifier).setLocale(Locale(val));
                            Navigator.pop(ctx);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // API Configuration
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('API & Connection Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32))),
          ),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Backend API URL'),
            subtitle: Text(baseUrl),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () {
              final controller = TextEditingController(text: baseUrl);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Set FastAPI Server URL'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'http://10.0.2.2:8000/api/v1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        ref.read(apiClientProvider.notifier).state = controller.text.trim();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.network_check),
            title: const Text('Test Connection'),
            subtitle: const Text('Ping FastAPI backend /health endpoint'),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Testing connection to backend...')),
              );
              try {
                final res = await api.get(
                  ApiEndpoints.health,
                  parser: (d) => Map<String, dynamic>.from(d),
                );
                if (res.success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connected! Server status: ${res.data?['status'] ?? "ok"}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connection failed: ${res.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('About & Legal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32))),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App Version'),
            subtitle: Text('1.0.0+1 (Agrolith-AI)'),
          ),
          const ListTile(
            leading: Icon(Icons.agriculture),
            title: Text('Powered by Google Gemini 2.5'),
            subtitle: Text('Multilingual Advisory for Indian Farmers'),
          ),
        ],
      ),
    );
  }
}
