class AiBackendConfig {
  const AiBackendConfig({
    required this.providerName,
    required this.model,
    required this.transcriptionModel,
    required this.proxyUrl,
  });

  factory AiBackendConfig.fromEnvironment() {
    const proxyUrl = String.fromEnvironment('QIVO_AI_PROXY_URL');
    const model = String.fromEnvironment(
      'QIVO_AI_MODEL',
      defaultValue: 'openai/gpt-oss-20b',
    );
    const transcriptionModel = String.fromEnvironment(
      'QIVO_STT_MODEL',
      defaultValue: 'whisper-large-v3-turbo',
    );

    return const AiBackendConfig(
      providerName: 'Groq free-start',
      model: model,
      transcriptionModel: transcriptionModel,
      proxyUrl: proxyUrl,
    );
  }

  final String providerName;
  final String model;
  final String transcriptionModel;
  final String proxyUrl;

  bool get isConfigured => proxyUrl.trim().isNotEmpty;

  String get connectionLabel =>
      isConfigured ? '$providerName proxy connected' : 'Mock offline mode';

  String get strategyLabel =>
      '$providerName: $model, $transcriptionModel, mock fallback';
}
