// 关于页面
//
// 该文件包含AboutPage组件，用于显示应用程序的关于信息，包括版本号、贡献者列表和GitHub链接。
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/core.dart';
import '../../../../core/services/audio_engine.dart';

/// 应用程序的关于页面组件
///
/// 显示应用程序的版本信息、贡献者列表和GitHub链接，
/// 并在页面打开时播放音效。
class AboutPage extends ConsumerStatefulWidget {
  /// 创建一个新的AboutPage实例
  ///
  /// [key] - 组件的键，用于唯一标识组件
  const AboutPage({super.key});

  /// 创建AboutPage的状态管理对象
  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

/// AboutPage的状态管理类
class _AboutPageState extends ConsumerState<AboutPage> {
  /// 应用程序名称
  String _appName = 'CyaniTalk';
  
  /// 应用程序版本号
  String _version = '';
  
  /// 贡献者列表
  List<dynamic> _contributors = [];
  
  /// 是否正在加载贡献者数据
  bool _isLoadingContributors = true;

  /// 初始化页面状态
  ///
  /// 加载应用程序信息、贡献者数据并播放页面打开音效。
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _fetchContributors();
    _playSound();
  }

  /// 释放资源
  ///
  ///  dispose音频播放器资源。
  @override
  void dispose() {
    super.dispose();
  }

  /// 播放页面打开音效
  Future<void> _playSound() async {
    try {
      logger.info('AboutPage: Playing entrance sound');
      await ref.read(audioEngineProvider).playAsset('sounds/AboutPageEntrance.mp3');
      logger.info('AboutPage: Entrance sound played successfully');
    } catch (e) {
      logger.error('AboutPage: Error playing sound: $e');
    }
  }

  /// 初始化应用程序包信息
  ///
  /// 获取应用程序的版本号和构建号。
  Future<void> _initPackageInfo() async {
    try {
      logger.info('AboutPage: Initializing package info');
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appName = "CyaniTalk";
        _version = '${info.version}+${info.buildNumber}';
      });
      logger.info('AboutPage: Package info initialized successfully: version=$_version');
    } catch (e) {
      logger.error('AboutPage: Error initializing package info: $e');
    }
  }

  /// 获取GitHub贡献者列表
  ///
  /// 从GitHub API获取项目的贡献者数据。
  Future<void> _fetchContributors() async {
    try {
      logger.info('AboutPage: Fetching GitHub contributors');
      final dio = Dio();
      final response = await dio.get(
        'https://api.github.com/repos/CyaniAgent/CyaniTalk/contributors',
      );
      if (mounted) {
        setState(() {
          _contributors = response.data;
          _isLoadingContributors = false;
        });
        logger.info('AboutPage: Successfully fetched ${_contributors.length} contributors');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingContributors = false;
        });
      }
      logger.error('AboutPage: Error fetching contributors: $e');
    }
  }

  /// 打开GitHub项目页面
  ///
  /// 在外部浏览器中打开项目的GitHub仓库页面。
  Future<void> _launchGitHub() async {
    try {
      logger.info('AboutPage: Launching GitHub project page');
      final url = Uri.parse('https://github.com/CyaniAgent/CyaniTalk');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          logger.warning('AboutPage: Failed to launch GitHub page');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('about_github_launch_error'.tr())),
          );
        }
      } else {
        logger.info('AboutPage: GitHub page launched successfully');
      }
    } catch (e) {
      logger.error('AboutPage: Error launching GitHub page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('about_github_launch_error'.tr())),
        );
      }
    }
  }

  /// 构建关于页面的UI界面
  ///
  /// [context] - 构建上下文，包含组件树的信息
  ///
  /// 返回一个包含应用程序信息、贡献者列表和GitHub链接的Scaffold组件
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('about_title'.tr())),
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
              label: Text('about_github'.tr()),
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
                  'about_contributors'.tr(),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('about_no_contributors'.tr()),
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
                            onBackgroundImageError: (_, _) {},
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
              'about_copyright'.tr(),
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
