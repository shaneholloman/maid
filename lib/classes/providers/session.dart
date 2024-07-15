import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maid/classes/chat_node_tree.dart';
import 'package:maid/classes/providers/large_language_models/google_gemini_model.dart';
import 'package:maid/classes/providers/large_language_model.dart';
import 'package:maid/classes/providers/large_language_models/llama_cpp_model.dart';
import 'package:maid/classes/providers/large_language_models/mistral_ai_model.dart';
import 'package:maid/classes/providers/large_language_models/ollama_model.dart';
import 'package:maid/classes/providers/large_language_models/open_ai_model.dart';
import 'package:maid/enumerators/chat_role.dart';
import 'package:maid/enumerators/large_language_model_type.dart';
import 'package:maid/classes/providers/character.dart';
import 'package:maid/classes/providers/user.dart';
import 'package:maid/classes/static/logger.dart';
import 'package:maid/classes/chat_node.dart';
import 'package:maid/classes/static/utilities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  static List<Session> sessions = [];

  LargeLanguageModel model = LlamaCppModel();
  ChatNodeTree chat = ChatNodeTree();
  Key _key = UniqueKey();

  Key get key => _key;
  
  String _name = "";

  String get name {
    if (_name.isEmpty) {
      return "New Chat $index";
    }

    return _name;
  }

  int get index => sessions.indexOf(this);

  set busy(bool value) {
    notifyListeners();
  }

  set name(String name) {
    _name = name;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  static Session of(BuildContext context) => Provider.of<Session>(context, listen: false);

  Session() {
    newSession();
  }

  Session.fromMap(VoidCallback? listener, Map<String, dynamic> inputJson) {
    if (listener != null) {
      addListener(listener);
    }

    fromMap(inputJson);
  }

  void reset() {
    newSession();
    notifyListeners();
  }

  static Future<Session> get last async {
    final prefs = await SharedPreferences.getInstance();

    String? sessionsString = prefs.getString("sessions");

    if (sessionsString != null) {
      sessions = (json.decode(sessionsString) as List).map((e) => Session.fromMap(null, e)).toList();
    }
    else if (sessions.isEmpty) {
      sessions.add(Session());
    }

    return sessions.first;
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final sessionsMaps = sessions.map((e) => e.toMap()).toList();

    await prefs.setString("sessions", json.encode(sessionsMaps));
  }

  void newSession() {
    _key = UniqueKey();
    chat = ChatNodeTree();
    model = LlamaCppModel(listener: notify);
    notifyListeners();
  }

  void from(Session session) {
    _key = session.key;
    _name = session.name;
    chat = session.chat;
    model = session.model;
    notifyListeners();
  }

  void fromMap(Map<String, dynamic> inputJson) {
    if (inputJson.isEmpty) {
      newSession();
      return;
    }

    _key = UniqueKey();

    _name = inputJson['name'] ?? "New Chat";

    chat.root = ChatNode.fromMap(inputJson['chat'] ?? {});

    final type = LargeLanguageModelType.values[inputJson['llm_type'] ?? LargeLanguageModelType.ollama.index];

    switch (type) {
      case LargeLanguageModelType.llamacpp:
        switchLlamaCpp();
        break;
      case LargeLanguageModelType.openAI:
        switchOpenAI();
        break;
      case LargeLanguageModelType.ollama:
        switchOllama();
        break;
      case LargeLanguageModelType.mistralAI:
        switchMistralAI();
        break;
      default:
        switchLlamaCpp();
        break;
    }
    
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'chat': chat.root.toMap(),
      'llm_type': model.type.index,
      'model': model.toMap(),
    };
  }

  void prompt(BuildContext context) async {
    final user = User.of(context);
    final character = Character.of(context);

    final description = Utilities.formatPlaceholders(character.description, user.name, character.name);
    final personality = Utilities.formatPlaceholders(character.personality, user.name, character.name);
    final scenario = Utilities.formatPlaceholders(character.scenario, user.name, character.name);
    final system = Utilities.formatPlaceholders(character.system, user.name, character.name);

    final preprompt = 'Description: $description\nPersonality: $personality\nScenario: $scenario\nSystem: $system';

    List<ChatNode> messages = [];

    messages.add(ChatNode(role: ChatRole.system, content: preprompt));
    messages.addAll(chat.getChat());

    Logger.log("Prompting with ${model.type.name}");

    final stringStream = model.prompt(messages);

    await for (var message in stringStream) {
      chat.tail.content += message;
      notifyListeners();
    }

    chat.tail.finalised = true;

    if (chat.root.children.isNotEmpty && 
        chat.root.children.first.content.isNotEmpty && 
        _name.isEmpty
    ) {
      _name = chat.root.children.first.content;
    }

    save();
    notifyListeners();
  }

  void regenerate(String hash, BuildContext context) {
    var parent = chat.parentOf(hash);
    if (parent == null) {
      return;
    } 
    parent.currentChild = null;
    chat.add(role: ChatRole.assistant);
    
    prompt(context);
    notifyListeners();
  }

  void edit(String hash, String message, BuildContext context) {
    var parent = chat.parentOf(hash);
    if (parent != null) {
      parent.currentChild = null;
    }
    chat.add(role: ChatRole.user, content: message);
    chat.add(role: ChatRole.assistant);

    prompt(context);
    notifyListeners();
  }

  void stop() {
    (model as LlamaCppModel).stop();
    Logger.log('Local generation stopped');
    notifyListeners();
  }

  /// -------------------------------------- Model Switching --------------------------------------

  void switchLlamaCpp() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastLlamaCpp = json.decode(prefs.getString("llama_cpp_model") ?? "{}");
    Logger.log(lastLlamaCpp.toString());
    
    if (lastLlamaCpp.isNotEmpty) {
      model = LlamaCppModel.fromMap(notify, lastLlamaCpp);
    } 
    else {
      model = LlamaCppModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchOpenAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOpenAI = json.decode(prefs.getString("open_ai_model") ?? "{}");
    Logger.log(lastOpenAI.toString());
    
    if (lastOpenAI.isNotEmpty) {
      model = OpenAiModel.fromMap(notify, lastOpenAI);
    } 
    else {
      model = OpenAiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchOllama() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastOllama = json.decode(prefs.getString("ollama_model") ?? "{}");
    Logger.log(lastOllama.toString());
    
    if (lastOllama.isNotEmpty) {
      model = OllamaModel.fromMap(notify, lastOllama);
    } 
    else {
      model = OllamaModel(listener: notify);
      model.resetUri();
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchMistralAI() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastMistralAI = json.decode(prefs.getString("mistral_ai_model") ?? "{}");
    Logger.log(lastMistralAI.toString());
    
    if (lastMistralAI.isNotEmpty) {
      model = MistralAiModel.fromMap(notify, lastMistralAI);
    } 
    else {
      model = MistralAiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }

  void switchGemini() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> lastGemini = json.decode(prefs.getString("google_gemini_model") ?? "{}");
    Logger.log(lastGemini.toString());
    
    if (lastGemini.isNotEmpty) {
      model = GoogleGeminiModel.fromMap(notify, lastGemini);
    } 
    else {
      model = GoogleGeminiModel(listener: notify);
    }

    prefs.setInt("llm_type", model.type.index);
    notifyListeners();
  }
}
