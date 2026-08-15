import 'dart:io';

/// 检测当前设备是否正在使用代理/VPN 服务。
///
/// 返回检测到的服务列表（可能为空）。
/// 检测策略：
/// - **代理**：读取 HTTP_PROXY / HTTPS_PROXY / ALL_PROXY 环境变量
/// - **Tailscale**：检查 Tailscale 进程是否在运行
/// - **WireGuard**：检查 wireguard / wg 进程
/// - **Clash**：检查 clash / mihomo 进程
/// - **通用 VPN**：检查 tun0 / utun 网络接口（仅 Linux/macOS）
Future<List<String>> detectProxyOrVpn() async {
  final detected = <String>[];

  // ── 1. 代理环境变量 ────────────────────────────────────────────
  final proxyEnv = Platform.environment['HTTP_PROXY'] ??
      Platform.environment['HTTPS_PROXY'] ??
      Platform.environment['ALL_PROXY'] ??
      Platform.environment['http_proxy'] ??
      Platform.environment['https_proxy'] ??
      Platform.environment['all_proxy'];
  if (proxyEnv != null && proxyEnv.isNotEmpty) {
    detected.add('Proxy');
  }

  // ── 2. Tailscale ──────────────────────────────────────────────
  if (await _isProcessRunning(_tailscaleProcessNames)) {
    detected.add('Tailscale');
  }

  // ── 3. WireGuard ──────────────────────────────────────────────
  if (await _isProcessRunning(_wireguardProcessNames)) {
    detected.add('WireGuard');
  }

  // ── 4. Clash / Mihomo ─────────────────────────────────────────
  if (await _isProcessRunning(_clashProcessNames)) {
    detected.add('Clash');
  }

  // ── 5. 通用 VPN 接口（Linux/macOS） ────────────────────────────
  if (Platform.isLinux || Platform.isMacOS) {
    if (await _hasVpnInterface()) {
      detected.add('VPN');
    }
  }

  return detected;
}

ProcessResult _timeoutResult() => ProcessResult(-1, 0, '', '');

/// 检查进程是否正在运行
Future<bool> _isProcessRunning(List<String> names) async {
  try {
    final result = await Process.run('tasklist', []).timeout(
      const Duration(seconds: 5),
      onTimeout: _timeoutResult,
    );
    if (result.exitCode != 0) return false;
    final output = (result.stdout as String).toLowerCase();
    return names.any(output.contains);
  } catch (_) {
    return false;
  }
}

/// 检查是否存在 VPN 网络接口
Future<bool> _hasVpnInterface() async {
  try {
    final result = await Process.run('ip', ['link', 'show']).timeout(
      const Duration(seconds: 5),
      onTimeout: _timeoutResult,
    );
    if (result.exitCode != 0) return false;
    final output = (result.stdout as String).toLowerCase();
    return output.contains('tun') || output.contains('utun');
  } catch (_) {
    return false;
  }
}

// ── 进程名列表（小写，用于 tasklist 匹配）─────────────────────────

const _tailscaleProcessNames = [
  'tailscale',
  'tailscaled',
  'tailscale-ipn',
];

const _wireguardProcessNames = [
  'wireguard',
  'wg',
  'wireguard-service',
];

const _clashProcessNames = [
  'clash',
  'clash-meta',
  'mihomo',
];
