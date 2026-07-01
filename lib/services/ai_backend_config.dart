class AiBackendConfig {
  const AiBackendConfig({
    required this.providerName,
    required this.model,
    required this.transcriptionModel,
    required this.proxyUrl,
    required this.source,
  });

  factory AiBackendConfig.fromEnvironment({
    bool localFirstEnabled = false,
    String? localProxyUrl,
    String? localModel,
    String? localSttModel,
  }) {
    const proxyUrl = String.fromEnvironment('QIVO_AI_PROXY_URL');
    const model = String.fromEnvironment(
      'QIVO_AI_MODEL',
      defaultValue: 'openai/gpt-oss-20b',
    );
    const transcriptionModel = String.fromEnvironment(
      'QIVO_STT_MODEL',
      defaultValue: 'whisper-large-v3-turbo',
    );
    final runtimeProxyUrl = Uri.base.queryParameters['qivoAiProxy'];
    final runtimeModel = Uri.base.queryParameters['qivoAiModel'];
    final runtimeSttModel = Uri.base.queryParameters['qivoSttModel'];
    final hasRuntimeProxy =
        runtimeProxyUrl != null && runtimeProxyUrl.trim().isNotEmpty;
    final hasLocalProxy =
        localProxyUrl != null && localProxyUrl.trim().isNotEmpty;
    final useLocalProxy = localFirstEnabled && hasLocalProxy;
    final selectedProxyUrl = useLocalProxy
        ? localProxyUrl!.trim()
        : hasRuntimeProxy
            ? runtimeProxyUrl!.trim()
            : proxyUrl;
    final selectedModel = useLocalProxy && localModel?.trim().isNotEmpty == true
        ? localModel!.trim()
        : runtimeModel?.trim().isNotEmpty == true
            ? runtimeModel!.trim()
            : model;
    final selectedSttModel =
        useLocalProxy && localSttModel?.trim().isNotEmpty == true
            ? localSttModel!.trim()
            : runtimeSttModel?.trim().isNotEmpty == true
                ? runtimeSttModel!.trim()
                : transcriptionModel;
    final source = useLocalProxy
        ? 'Local-first app setting'
        : hasRuntimeProxy
            ? 'URL runtime override'
            : 'Build settings';

    return AiBackendConfig(
      providerName: 'Groq free-start',
      model: selectedModel,
      transcriptionModel: selectedSttModel,
      proxyUrl: selectedProxyUrl,
      source: source,
    );
  }

  final String providerName;
  final String model;
  final String transcriptionModel;
  final String proxyUrl;
  final String source;

  bool get isConfigured => proxyUrl.trim().isNotEmpty;
  bool get isLocalOverride =>
      source == 'Local-first app setting' || source == 'URL runtime override';

  String get connectionLabel =>
      isConfigured ? '$providerName proxy selected' : 'Mock offline mode';

  String get strategyLabel =>
      '$providerName: $model, $transcriptionModel, $source, mock fallback';
}
