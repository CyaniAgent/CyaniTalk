import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '/oss_licenses.dart';

/// 开源许可证页面
///
/// 显示应用程序和所有依赖项的开源许可证信息
class LicensesPage extends ConsumerStatefulWidget {
  const LicensesPage({super.key});

  @override
  ConsumerState<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends ConsumerState<LicensesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('licenses_title'.tr())),
      body: ListView(
        children: [
          _buildAppLicenseSection(),
          const Divider(height: 32),
          _buildDependenciesSection(),
        ],
      ),
    );
  }

  Widget _buildAppLicenseSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'licenses_app_title'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            thisPackage.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version: ${thisPackage.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showLicenseDetails(thisPackage),
            icon: const Icon(Icons.description),
            label: Text('licenses_view_license'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDependenciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'licenses_dependencies_title'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...dependencies.map((package) => _buildDependencyTile(package)),
      ],
    );
  }

  Widget _buildDependencyTile(Package package) {
    return ListTile(
      title: Text(package.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (package.version != null) Text('Version: ${package.version}'),
          if (package.spdxIdentifiers.isNotEmpty)
            Text(
              '${'licenses_spdx_identifiers'.tr()}: ${package.spdxIdentifiers.first}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLicenseDetails(package),
    );
  }

  void _showLicenseDetails(Package package) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LicenseDetailPage(package: package),
      ),
    );
  }
}

/// 许可证详情页面
///
/// 显示单个包的详细许可证信息
class LicenseDetailPage extends StatelessWidget {
  final Package package;

  const LicenseDetailPage({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(package.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (package.version != null) ...[
              SelectableText(
                'Version: ${package.version}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (package.description.isNotEmpty) ...[
              SelectableText(
                package.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            if (package.homepage != null) ...[
              _buildLinkTile(
                context,
                Icons.language,
                'licenses_homepage'.tr(),
                package.homepage!,
              ),
              const SizedBox(height: 8),
            ],
            if (package.repository != null) ...[
              _buildLinkTile(
                context,
                Icons.code,
                'licenses_repository'.tr(),
                package.repository!,
              ),
              const SizedBox(height: 16),
            ],
            const Divider(),
            const SizedBox(height: 16),
            if (package.spdxIdentifiers.isNotEmpty) ...[
              Text(
                'licenses_spdx_identifiers'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: package.spdxIdentifiers
                    .map(
                      (id) => Chip(
                        label: SelectableText(id),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'licenses_license_text'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                package.license ?? 'licenses_not_available'.tr(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    IconData icon,
    String label,
    String url,
  ) {
    return InkWell(
      onTap: () {
        final uri = Uri.parse(url);
        // 立即显示对话框，不等待canLaunchUrl的结果
        showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('licenses_open_link_title'.tr()),
            content: Text(
              'licenses_open_link_description'.tr(namedArgs: {'url': url}),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(true);
                  // 在对话框关闭后检查并打开链接
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Text('ok'.tr()),
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
