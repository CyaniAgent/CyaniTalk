import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/api/flarum_api.dart';
import '../../../../core/utils/logger.dart';
import '../../../flarum/application/flarum_providers.dart';

class FlarumEndpointsPage extends ConsumerStatefulWidget {
  const FlarumEndpointsPage({super.key});

  @override
  ConsumerState<FlarumEndpointsPage> createState() => _FlarumEndpointsPageState();
}

class _FlarumEndpointsPageState extends ConsumerState<FlarumEndpointsPage> {
  List<String> _endpoints = [];
  String? _currentEndpoint;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEndpoints();
  }

  Future<void> _loadEndpoints() async {
    setState(() => _isLoading = true);
    final api = FlarumApi();
    final endpoints = await api.getEndpoints();
    setState(() {
      _endpoints = endpoints;
      _currentEndpoint = api.baseUrl;
      _isLoading = false;
    });
  }

  Future<void> _addEndpoint() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auth_add_account_flarum_endpoint_title'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'https://discuss.flarum.org',
            labelText: 'URL',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('auth_cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('auth_add_endpoint'.tr()),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      String url = result;
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      
      try {
        await FlarumApi().saveEndpoint(url);
        // Switching to endpoint also means guest mode for that endpoint if no token saved
        await FlarumApi().switchEndpoint(url);
        // Invalidate flarum providers to trigger reload with new endpoint
        ref.invalidate(flarumRepositoryProvider);
        await _loadEndpoints();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('auth_flarum_endpoint_added'.tr())),
          );
        }
      } catch (e) {
        logger.error('FlarumEndpointsPage: Failed to add endpoint', e);
      }
    }
  }

  Future<void> _deleteEndpoint(String url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Endpoint'),
        content: Text('Are you sure you want to remove this endpoint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('auth_cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FlarumApi().deleteEndpoint(url);
      ref.invalidate(flarumRepositoryProvider);
      await _loadEndpoints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_flarum_endpoint_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addEndpoint,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _endpoints.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _endpoints.length,
                  itemBuilder: (context, index) {
                    final endpoint = _endpoints[index];
                    final isSelected = endpoint == _currentEndpoint;
                    
                    return ListTile(
                      leading: Icon(
                        Icons.api,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                      title: Text(endpoint),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteEndpoint(endpoint),
                      ),
                      selected: isSelected,
                      onTap: () async {
                        await FlarumApi().switchEndpoint(endpoint);
                        ref.invalidate(flarumRepositoryProvider);
                        setState(() => _currentEndpoint = endpoint);
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.api_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No endpoints added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addEndpoint,
            icon: const Icon(Icons.add),
            label: Text('auth_add_endpoint'.tr()),
          ),
        ],
      ),
    );
  }
}
