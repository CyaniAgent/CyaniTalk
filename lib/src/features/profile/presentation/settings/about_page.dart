import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appName = 'CyaniTalk';
  String _version = '';
  List<dynamic> _contributors = [];
  bool _isLoadingContributors = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _fetchContributors();
    _playSound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/AboutPageEntrance.wav'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appName = "CyaniTalk";
      _version = '${info.version}+${info.buildNumber}';
    });
  }

  Future<void> _fetchContributors() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.github.com/repos/CyaniAgent/CyaniTalk/contributors',
      );
      if (mounted) {
        setState(() {
          _contributors = response.data;
          _isLoadingContributors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingContributors = false;
        });
      }
      debugPrint('Error fetching contributors: $e');
    }
  }

  Future<void> _launchGitHub() async {
    final url = Uri.parse('https://github.com/CyaniAgent/CyaniTalk');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch GitHub URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About CyaniTalk')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logo
            Image.asset(
              'assets/icons/logo/desktop/logo-desktop-transparent.png',
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 100),
            ),
            const SizedBox(height: 16),
            // App Name
            Text(
              _appName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Version
            Text(
              'Version $_version',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            // GitHub Button
            FilledButton.icon(
              onPressed: _launchGitHub,
              icon: const Icon(Icons.code),
              label: const Text('GitHub'),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            // Contributors Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contributors',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Contributors List
            if (_isLoadingContributors)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_contributors.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No contributors found (or API limit reached).'),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _contributors.length,
                  itemBuilder: (context, index) {
                    final contributor = _contributors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              contributor['avatar_url'],
                            ),
                            radius: 30,
                            onBackgroundImageError: (_, __) {},
                            child: const Icon(
                              Icons.person,
                              color: Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contributor['login'],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 32),
            // Copyright
            Text(
              '© 2026 CyaniAgent. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
