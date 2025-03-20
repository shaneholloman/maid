part of 'package:maid/main.dart';

abstract class ArtificialIntelligenceController extends ChangeNotifier {
  static Map<String, String> getTypes(BuildContext context) {
    Map<String, String> types = {};

    if (!kIsWeb) {
      types['llama_cpp'] = AppLocalizations.of(context)!.llamaCpp;
    }

    types['ollama'] = AppLocalizations.of(context)!.ollama;
    types['open_ai'] = AppLocalizations.of(context)!.openAI;
    types['mistral'] = AppLocalizations.of(context)!.mistral;
    types['anthropic'] = AppLocalizations.of(context)!.anthropic;
    types['google_gemini'] = AppLocalizations.of(context)!.googleGemini;

    return types;
  }

  bool _busy = false;

  bool get busy => _busy;

  set busy(bool newBusy) {
    _busy = newBusy;
    save();
    notifyListeners();
  }

  String? _model;

  String? get model => _model;

  set model(String? newModel) {
    _model = newModel;
    save();
    notifyListeners();
  }

  Map<String, dynamic> _overrides;

  Map<String, dynamic> get overrides => _overrides;

  set overrides(Map<String, dynamic> newOverrides) {
    _overrides = newOverrides;
    save();
    notifyListeners();
  }

  String get type;
  bool get canPrompt;
  String get hash => jsonEncode(toMap()).hash;

  ArtificialIntelligenceController({
    String? model, 
    Map<String, dynamic>? overrides
  }) : _model = model , _overrides = overrides ?? {};

  Map<String, dynamic> toMap() => {
    'model': _model,
    'overrides': _overrides,
  };

  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _overrides = map['overrides'] ?? {};
    save();
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('ai_type', type);

    final contextString = jsonEncode(toMap());

    await prefs.setString(type, contextString);
  }

  static Future<ArtificialIntelligenceController> load([String? type]) async {
    final prefs = await SharedPreferences.getInstance();

    type ??= prefs.getString('ai_type') ?? (kIsWeb ? 'ollama' : 'llama_cpp');

    final contextString = prefs.getString(type);

    final contextMap = jsonDecode(contextString ?? '{}');

    switch (type) {
      case 'llama_cpp':
        return LlamaCppController()
          ..fromMap(contextMap);
      case 'ollama':
        return OllamaController()
          ..fromMap(contextMap);
      case 'open_ai':
        return OpenAIController()
          ..fromMap(contextMap);
      case 'mistral':
        return MistralController()
          ..fromMap(contextMap);
      case 'anthropic':
        return AnthropicController()
          ..fromMap(contextMap);
      case 'google_gemini':
        return GoogleGeminiController()
          ..fromMap(contextMap);
      default:
        return LlamaCppController();
    }
  }

  Stream<String> prompt(List<ChatMessage> messages);

  void stop();

  void clear() async {
    _model = null;
    _overrides = {};
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(type);
    await prefs.remove('ai_type');
  }

  String getTypeLocale(BuildContext context);

  void notify() => notifyListeners();
}

abstract class RemoteArtificialIntelligenceController extends ArtificialIntelligenceController {
  static List<String> get types => [
    'ollama',
    'open_ai',
    'mistral',
    'anthropic',
    'google_gemini',
  ];

  String? _baseUrl;

  String? get baseUrl => _baseUrl;

  set baseUrl(String? newBaseUrl) {
    _baseUrl = newBaseUrl;
    save();
    notifyListeners();
  }

  String? _apiKey;

  String? get apiKey => _apiKey;

  set apiKey(String? newApiKey) {
    _apiKey = newApiKey;
    save();
    notifyListeners();
  }

  bool _customModel;

  bool get customModel => _customModel;

  set customModel(bool newCustomModel) {
    _customModel = newCustomModel;
    save();
    notifyListeners();
  }

  String get connectionHash => (_baseUrl ?? '').hash + (_apiKey ?? '').hash;

  bool get canGetRemoteModels;

  List<String> _modelOptions = [];

  List<String> get modelOptions => _modelOptions;

  RemoteArtificialIntelligenceController({
    super.model, 
    super.overrides,
    String? baseUrl, 
    String? apiKey,
    bool customModel = false
  }) : _baseUrl = baseUrl, _apiKey = apiKey, _customModel = customModel;

  @override
  Map<String, dynamic> toMap() => {
    'model': _model,
    'overrides': _overrides,
    'base_url': _baseUrl,
    'api_key': _apiKey,
    'custom_model': _customModel,
  };

  @override
  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _overrides = map['overrides'] ?? {};
    _baseUrl = map['base_url'];
    _apiKey = map['api_key'];
    _customModel = map['custom_model'] ?? false;
    save();
    notifyListeners();
  }

  Future<bool> getModelOptions();

  @override
  void clear() async {
    _model = null;
    _overrides = {};
    _baseUrl = null;
    _apiKey = null;
    _customModel = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(type);
    await prefs.remove('ai_type');
  }
}

class LlamaCppController extends ArtificialIntelligenceController {
  Llama? _llama;
  String _loadedHash = '';

  bool loading = false;

  @override
  String get type => 'llama_cpp';

  @override
  bool get canPrompt => _llama != null && !busy;

  LlamaCppController({
    super.model, 
    super.overrides
  });

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_model != null);
    busy = true;

    reloadModel();
    assert(_llama != null);

    yield* _llama!.prompt(messages);
    busy = false;
  }

  void reloadModel([bool force = false]) async {
    if ((hash == _loadedHash && !force) || _model == null) return;

    _llama = Llama(
      LlamaController.fromMap({
        'model_path': _model,
        'seed': math.Random().nextInt(1000000),
        'greedy': true,
        ..._overrides
      })
    );

    _loadedHash = hash;
  }

  void pickModel() async {
    if (_model != null && PlatformExtension.isMobile) {
      await File(_model!).delete();
    }

    _model = null;
    
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Load Model File",
      type: FileType.any,
      allowMultiple: false,
      allowCompression: false,
      onFileLoading: (status) {
        loading = status == FilePickerStatus.picking;
        super.notifyListeners();
      } 
    );

    loading = false;
    super.notifyListeners();

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      throw Exception('No file selected');
    }

    _model = result.files.single.path!;

    final exists = await File(_model!).exists();
    if (!exists) {
      throw Exception('File does not exist');
    }

    notifyListeners();
  }

  void loadModelFile(String path) async {
    if (_model != null && PlatformExtension.isMobile) {
      await File(_model!).delete();
    }
    
    assert (RegExp(r'\.gguf$', caseSensitive: false).hasMatch(path));
    _model = path;
    reloadModel();
  }

  @override
  void stop() {
    _llama?.stop();
    busy = false;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    reloadModel();
    save();
  }

  @override
  void clear() {
    super.clear();
    _llama = null;
    _loadedHash = '';
    loading = false;
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.llamaCpp;
}

class OllamaController extends RemoteArtificialIntelligenceController {
  late ollama.OllamaClient _ollamaClient;

  bool? _searchLocalNetwork;

  bool? get searchLocalNetwork => _searchLocalNetwork;

  set searchLocalNetwork(bool? value) {
    _searchLocalNetwork = value;
    save();
    notifyListeners();
  }

  @override
  String get type => 'ollama';

  @override
  bool get canPrompt => _model != null && _model!.isNotEmpty && !busy;

  OllamaController({
    super.model, 
    super.overrides,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_model != null);
    busy = true;

    _ollamaClient = ollama.OllamaClient(
      baseUrl: "${_baseUrl ?? 'http://localhost:11434'}/api",
      headers: {
        'Authorization': 'Bearer $_apiKey'
      }
    );

    final completionStream = _ollamaClient.generateChatCompletionStream(
      request: ollama.GenerateChatCompletionRequest(
        model: _model!, 
        messages: messages.toOllamaMessages(),
        options: ollama.RequestOptions.fromJson(_overrides),
        stream: true
      )
    );

    try {
      await for (final completion in completionStream) {
        yield completion.message.content;
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
    finally {
      busy = false;
    }
  }

  @override
  void stop() {
    _ollamaClient.endSession();
    busy = false;
  }

  @override
  void clear() {
    super.clear();
    _searchLocalNetwork = null;
  }

  Future<Uri?> checkForOllama(Uri url) async {
    try {
      final request = http.Request("GET", url);
      final headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $_apiKey'
      };

      request.headers.addAll(headers);

      final response = await request.send();
      if (response.statusCode == 200) {
        log('Found Ollama at ${url.host}');
        return url;
      }
    } catch (e) {
      if (!e.toString().contains(RegExp(r'Connection (failed|refused)'))) {
        log(e.toString());
      }
    }

    return null;
  }

  Future<bool> searchForOllama() async {
    assert(_searchLocalNetwork == true);

    // Check current URL
    if (_baseUrl != null && await checkForOllama(Uri.parse(_baseUrl!)) != null) {
      return true;
    }

    // Check localhost
    if (await checkForOllama(Uri.parse('http://localhost:11434')) != null) {
      _baseUrl = 'http://localhost:11434';
      save();
      return true;
    }

    final localIP = await NetworkInfo().getWifiIP();

    // Get the first 3 octets of the local IP
    final baseIP = ipToCSubnet(localIP ?? '');

    // Scan the local network for hosts
    final hosts = await LanScanner(debugLogging: true).quickIcmpScanAsync(baseIP);

    List<Future<Uri?>> hostFutures = [];
    for (final host in hosts) {
      final hostUri = Uri.parse('http://${host.internetAddress.address}:11434');
      hostFutures.add(checkForOllama(hostUri));
    }

    final results = await Future.wait(hostFutures);

    final validUrls = results.where((result) => result != null);

    if (validUrls.isNotEmpty) {
      _baseUrl = validUrls.first.toString();
      save();
      return true;
    }
    return false;
  }

  @override
  Future<bool> getModelOptions() async {
    try {
      if (searchLocalNetwork == true) {
        final found = await searchForOllama();
        if (!found) return false;
      }
  
      final uri = Uri.parse("${_baseUrl ?? 'http://localhost:11434'}/api/tags");
  
      final request = http.Request("GET", uri);
  
      final headers = {
        "Accept": "application/json",
        'Authorization': 'Bearer $_apiKey'
      };
  
      request.headers.addAll(headers);

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final data = json.decode(responseString);

      List<String> newOptions = [];
      if (data['models'] != null) {
        for (final option in data['models']) {
          newOptions.add(option['name']);
        }
      }

      _modelOptions = newOptions;
      return true;
    }
    catch (e) {
      if (!e.toString().contains(RegExp(r'Connection (failed|refused)'))) {
        rethrow;
      }
      return false;
    }
  }

  @override
  Map<String, dynamic> toMap() => {
    'model': _model,
    'overrides': _overrides,
    'base_url': _baseUrl,
    'api_key': _apiKey,
    'search_local_network': _searchLocalNetwork,
  };

  @override
  void fromMap(Map<String, dynamic> map) {
    _model = map['model'];
    _overrides = map['overrides'] ?? {};
    _baseUrl = map['base_url'];
    _apiKey = map['api_key'];
    _searchLocalNetwork = map['search_local_network'];
    save();
    notifyListeners();
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.ollama;
  
  @override
  bool get canGetRemoteModels => baseUrl != null || searchLocalNetwork == true;
}

class OpenAIController extends RemoteArtificialIntelligenceController {
  late open_ai.OpenAIClient _openAiClient;

  @override
  String get type => 'open_ai';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  OpenAIController({
    super.model,
    super.overrides,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_apiKey != null, 'API Key is required');
    assert(_model != null, 'Model is required');
    busy = true;

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    final completionStream = _openAiClient.createChatCompletionStream(
      request: open_ai.CreateChatCompletionRequest(
        messages: messages.toOpenAiMessages(),
        model: open_ai.ChatCompletionModel.modelId(_model!),
        stream: true,
        temperature: _overrides['temperature'],
        topP: _overrides['top_p'],
        maxTokens: _overrides['max_tokens'],
        frequencyPenalty: _overrides['frequency_penalty'],
        presencePenalty: _overrides['presence_penalty'],
      )
    );

    try {
      await for (final completion in completionStream) {
        yield completion.choices.first.delta.content ?? '';
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
    finally {
      busy = false;
    }
  }

  @override
  void stop() {
    _openAiClient.endSession();
    busy = false;
  }
  
  @override
  Future<bool> getModelOptions() async {
    assert(_apiKey != null && _apiKey!.isNotEmpty, 'API Key is required');

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.openai.com/v1';
    }

    _openAiClient = open_ai.OpenAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    final modelsResponse = await _openAiClient.listModels();

    _modelOptions = modelsResponse.data.map((model) => model.id).toList();
    return true;
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.openAI;
  
  @override
  bool get canGetRemoteModels => apiKey != null && apiKey!.isNotEmpty;
}

class MistralController extends RemoteArtificialIntelligenceController {
  late mistral.MistralAIClient _mistralClient;

  @override
  String get type => 'mistral';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  MistralController({
    super.model, 
    super.overrides,
    super.baseUrl, 
    super.apiKey
  });
  
  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_apiKey != null, 'API Key is required');
    assert(_model != null, 'Model is required');
    busy = true;

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.mistral.ai/v1';
    }

    _mistralClient = mistral.MistralAIClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    mistral.ChatCompletionModels mistralModel;

    if (_model == 'mistral-medium') {
      mistralModel = mistral.ChatCompletionModels.mistralMedium;
    } 
    else if (_model == 'mistral-small') {
      mistralModel = mistral.ChatCompletionModels.mistralSmall;
    } 
    else if (_model == 'mistral-tiny') {
      mistralModel = mistral.ChatCompletionModels.mistralTiny;
    } 
    else {
      throw Exception('Unknown Mistral model: $model');
    }

    final completionStream = _mistralClient.createChatCompletionStream(
      request: mistral.ChatCompletionRequest(
        messages: messages.toMistralMessages(),
        model: mistral.ChatCompletionModel.model(mistralModel),
        stream: true,
        temperature: _overrides['temperature'],
        topP: _overrides['top_p'],
        maxTokens: _overrides['max_tokens'],
        randomSeed: _overrides['seed'],
      )
    );

    try {
      await for (final completion in completionStream) {
        yield completion.choices.first.delta.content ?? '';
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
    finally {
      busy = false;
    }
  }
  
  @override
  void stop() {
    _mistralClient.endSession();
    busy = false;
  }

  @override
  Future<bool> getModelOptions() async {
    _modelOptions = [
      'mistral-medium',
      'mistral-small',
      'mistral-tiny',
    ];
    return true;
  }
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.mistral;
  
  @override
  bool get canGetRemoteModels => true;
}

class AnthropicController extends RemoteArtificialIntelligenceController {
  late anthropic.AnthropicClient _anthropicClient;

  @override
  String get type => 'anthropic';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && _model != null && _model!.isNotEmpty && !busy;

  AnthropicController({
    super.model, 
    super.overrides,
    super.baseUrl, 
    super.apiKey
  });

  @override
  Stream<String> prompt(List<ChatMessage> messages) async* {
    assert(_apiKey != null, 'API Key is required');
    assert(_model != null, 'Model is required');
    busy = true;

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      _baseUrl = 'https://api.anthropic.com/v1';
    }

    _anthropicClient = anthropic.AnthropicClient(
      apiKey: _apiKey!,
      baseUrl: _baseUrl,
    );

    final completionStream = _anthropicClient.createMessageStream(
      request: anthropic.CreateMessageRequest(
        model: anthropic.Model.model(anthropic.Models.values.firstWhere((model) => model.name == _model)),
        maxTokens: _overrides['max_tokens'] ?? 1024,
        messages: messages.toAnthropicMessages(),
        stopSequences: _overrides['stop_sequences'],
        temperature: _overrides['temperature'],
        topK: _overrides['top_k'],
        topP: _overrides['top_p'],
        stream: true,
      )
    );

    try {
      await for (final completion in completionStream) {
        if (completion is! anthropic.ContentBlockDeltaEvent) continue;

        yield completion.delta.text;
      }
    }
    catch (e) {
      // This is expected when the user presses stop
      if (!e.toString().contains('Connection closed')) {
        rethrow;
      }
    }
    finally {
      busy = false;
    }
  }

  @override
  void stop() {
    _anthropicClient.endSession();
    busy = false;
  }

  @override
  Future<bool> getModelOptions() async {
    _modelOptions = anthropic.Models.values.map((model) => model.name).toList();

    return true;
  }
  
  @override
  bool get canGetRemoteModels => true;
  
  @override
  String getTypeLocale(BuildContext context) => AppLocalizations.of(context)!.anthropic;
}
////

//Google gemini
class GoogleGeminiController extends RemoteArtificialIntelligenceController {
  late http.Client _httpClient;

  @override
  String get type => 'google_gemini';

  @override
  bool get canPrompt => _apiKey != null && _apiKey!.isNotEmpty && !busy;
  
  @override
  bool get canGetRemoteModels => true;

  GoogleGeminiController({
    super.model,
    super.overrides,
    super.baseUrl,
    super.apiKey,
  }) {
    _httpClient = http.Client();
  }

@override
Stream<String> prompt(List<ChatMessage> messages) async* {
  assert(apiKey != null, 'API Key is required');
  assert(model != null && model!.isNotEmpty, 'Model name is required');
  busy = true;

  final url = Uri.parse(
    '${baseUrl ?? "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent"}?key=$apiKey',
  );

  // Construct the request body, filtering out invalid or empty messages
  final requestBody = jsonEncode({
    "contents": messages
        .where((message) =>
            message.role != 'system' && // Exclude system messages
            message.content.isNotEmpty) 
        .map((message) {
      return {
        "role": message.role, 
        "parts": [
          {"text": message.content}
        ]
      };
    }).toList(),
  });

  try {
    // Send HTTP POST request
    final response = await _httpClient.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Navigate to the candidates array
      if (responseData['candidates'] != null && responseData['candidates'] is List) {
        for (final candidate in responseData['candidates']) {
          if (candidate['content'] != null &&
              candidate['content']['parts'] != null &&
              candidate['content']['parts'] is List) {
            for (final part in candidate['content']['parts']) {
              if (part['text'] != null) {

                yield part['text']; // Yield the part text for display
              } else {
                throw Exception('Part text is null or missing!');
              }
            }
          } else {
            throw Exception('Content parts are null or not a list!');
          }
        }
      } else {
        throw Exception('Candidates are null or not a list!');
      }
    } else {
      throw Exception('Google Gemini API Error: ${response.body}');
    }
  } catch (e) {
    rethrow;
  } finally {
    busy = false;
  }
}



  @override
  void stop() {

    busy = false;
  }

  @override
  Future<bool> getModelOptions() async {
    // Google Gemini model listing
    _modelOptions = ["gemini-2.0-flash","gemini-2.0-pro-exp-02-05","gemini-1.5-pro","imagen-3.0-generate-002","gemini-2.0-flash-lite","gemini-1.5-flash"];
    return true;
  }

  @override
  String getTypeLocale(BuildContext context) =>
      AppLocalizations.of(context)!.googleGemini;
}
