import 'package:flutter/material.dart';

import '../../core/l10n_extensions.dart';

const appVersion = '1.2.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ExcludeSemantics(
            child: Icon(Icons.restaurant_menu, size: 72, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              l10n.appTitle,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            l10n.version(appVersion),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(l10n.aboutDescription, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.description_outlined),
            label: Text(l10n.licenses),
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: appVersion,
            ),
          ),
        ],
      ),
    );
  }
}
