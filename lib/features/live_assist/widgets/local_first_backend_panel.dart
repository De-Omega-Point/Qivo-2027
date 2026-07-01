import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/state/qivo_providers.dart';
import '../../../core/theme/qivo_colours.dart';
import '../../shell/qivo_components.dart';

class LocalFirstBackendPanel extends ConsumerStatefulWidget {
  const LocalFirstBackendPanel({super.key});

  @override
  ConsumerState<LocalFirstBackendPanel> createState() =>
      _LocalFirstBackendPanelState();
}

class _LocalFirstBackendPanelState
    extends ConsumerState<LocalFirstBackendPanel> {
  late final TextEditingController _proxyUrl;
  var _checking = false;
  String? _result;
  bool? _connected;

  @override
  void initState() {
    super.initState();
    _proxyUrl = TextEditingController(
      text: ref.read(settingsProvider).localAiProxyUrl,
    );
  }

  @override
  void dispose() {
    _proxyUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final backend = ref.watch(aiBackendConfigProvider);
    final settingsController = ref.read(settingsProvider.notifier);
    final enabled = settings.localAiEnabled;
    final statusColor = enabled ? QivoColours.warningAmber : QivoColours.aqua;

    return QivoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'App AI mode',
            subtitle: enabled
                ? 'Local-first is on for this app session.'
                : 'Qivo is using mock mode until local AI is enabled.',
            action: Switch.adaptive(
              value: enabled,
              activeColor: QivoColours.aqua,
              onChanged: (value) {
                settingsController.updateLocalAiEnabled(value);
                setState(() {
                  _result = null;
                  _connected = null;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              QivoStatusBadge(
                label: enabled ? 'Local AI' : 'Mock safe mode',
                color: statusColor,
                icon: enabled
                    ? Icons.computer_rounded
                    : Icons.shield_outlined,
              ),
              QivoStatusBadge(
                label: backend.model,
                color: QivoColours.violet,
                icon: Icons.auto_awesome_rounded,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _proxyUrl,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Local proxy',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            onSubmitted: settingsController.updateLocalAiProxyUrl,
            onChanged: settingsController.updateLocalAiProxyUrl,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: _checking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering_rounded),
                label: Text(_checking ? 'Testing' : 'Test proxy'),
                onPressed: enabled && !_checking ? _testProxy : null,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.computer_rounded),
                label: const Text('Use localhost'),
                onPressed: () {
                  _proxyUrl.text = 'http://localhost:8787';
                  settingsController
                    ..updateLocalAiProxyUrl(_proxyUrl.text)
                    ..updateLocalAiEnabled(true);
                  setState(() {
                    _result = 'Localhost selected. Start the local proxy, then test.';
                    _connected = null;
                  });
                },
              ),
            ],
          ),
          if (_result != null) ...[
            const SizedBox(height: 12),
            _ConnectionMessage(
              text: _result!,
              connected: _connected,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _testProxy() async {
    final backend = ref.read(aiBackendConfigProvider);
    final url = backend.proxyUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _result = 'Add a local proxy URL first.';
        _connected = false;
      });
      return;
    }

    setState(() {
      _checking = true;
      _result = null;
      _connected = null;
    });

    try {
      final healthUrl = _healthUrl(url);
      final response = await http
          .get(healthUrl)
          .timeout(const Duration(milliseconds: 1800));
      final ok = response.statusCode >= 200 && response.statusCode < 300;
      setState(() {
        _connected = ok;
        _result = ok
            ? 'Local backend is reachable. Live Assist will use it for AI suggestions.'
            : 'Proxy replied with HTTP ${response.statusCode}. Check the local server.';
      });
    } on TimeoutException {
      setState(() {
        _connected = false;
        _result = 'Timed out. Start the backend proxy on this device.';
      });
    } on Object {
      setState(() {
        _connected = false;
        _result = 'Could not reach the local proxy. Check the URL and CORS.';
      });
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  Uri _healthUrl(String proxyUrl) {
    final trimmed = proxyUrl.endsWith('/')
        ? proxyUrl.substring(0, proxyUrl.length - 1)
        : proxyUrl;
    if (trimmed.endsWith('/health')) return Uri.parse(trimmed);
    return Uri.parse('$trimmed/health');
  }
}

class _ConnectionMessage extends StatelessWidget {
  const _ConnectionMessage({
    required this.text,
    required this.connected,
  });

  final String text;
  final bool? connected;

  @override
  Widget build(BuildContext context) {
    final color = connected == true
        ? QivoColours.liveGreen
        : connected == false
            ? QivoColours.warningAmber
            : QivoColours.aqua;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            connected == true
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
