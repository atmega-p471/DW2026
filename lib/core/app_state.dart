import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_engine.dart';
import 'models.dart';

const _saveKey = 'moneyflow_save_v1';

class ShopItem {
  const ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.type,
  });

  final String id;
  final String title;
  final String description;
  final int cost;
  final String type;
}

const shopItems = <ShopItem>[
  ShopItem(
    id: 'hair_neon',
    title: 'Неоновая прическа',
    description: 'Яркий стиль для аватара.',
    cost: 120,
    type: 'Косметика',
  ),
  ShopItem(
    id: 'hoodie_budget',
    title: 'Худи Budget Hero',
    description: 'Кастомный образ персонажа.',
    cost: 180,
    type: 'Косметика',
  ),
  ShopItem(
    id: 'stickers_fin',
    title: 'Стикерпак "ФинСоветы"',
    description: 'Набор игровых стикеров.',
    cost: 90,
    type: 'Стикеры',
  ),
  ShopItem(
    id: 'wallpaper_soft',
    title: 'Обои "Мягкий рост"',
    description: 'Минималистичные цифровые обои.',
    cost: 70,
    type: 'Обои',
  ),
  ShopItem(
    id: 'promo_books',
    title: 'Промокод на книги',
    description: 'Партнерская скидка 10% (демо).',
    cost: 250,
    type: 'Промокод',
  ),
];

const glossaryData = <String, String>{
  'Бюджет': 'План доходов и расходов на выбранный период.',
  'Переплата': 'Сумма сверх основного долга, которую платят банку.',
  'Подушка безопасности':
      'Резерв на непредвиденные ситуации, обычно на 3-6 месяцев расходов.',
  'Кредит': 'Деньги банка, которые нужно вернуть с процентами.',
  'Инфляция': 'Рост цен, из-за которого со временем деньги покупают меньше.',
  'Диверсификация':
      'Распределение денег по разным активам для снижения рисков.',
  'Амортизация': 'Постепенный износ и потеря стоимости вещей со временем.',
  'Отложенный риск':
      'Проблема, которую откладывают сейчас, но потом она стоит дороже.',
};

class MoneyFlowState extends ChangeNotifier {
  MoneyFlowState({GameEngine? engine}) : _engine = engine ?? GameEngine();

  final GameEngine _engine;
  SharedPreferences? _prefs;
  GameRun? run;
  bool isLoaded = false;
  int? selectedEventIndex;
  WeeklyQuiz? activeQuiz;

  bool get hasGame => run != null;
  bool get isFinished => run?.ending != null;

  Future<void> bootstrap() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_saveKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      run = GameRun.fromJson(decoded);
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> startNewGame({
    required Avatar avatar,
    required Difficulty difficulty,
    required Goal goal,
  }) async {
    run = _engine.newGame(avatar: avatar, goal: goal, difficulty: difficulty);
    selectedEventIndex = null;
    activeQuiz = null;
    await save();
    notifyListeners();
  }

  Future<void> save() async {
    final current = run;
    if (_prefs == null || current == null) {
      return;
    }
    await _prefs!.setString(_saveKey, jsonEncode(current.toJson()));
  }

  Future<void> reset() async {
    run = null;
    selectedEventIndex = null;
    activeQuiz = null;
    await _prefs?.remove(_saveKey);
    notifyListeners();
  }

  void updatePlan(MonthPlan plan) {
    final current = run;
    if (current == null) return;
    _engine.applyPlan(current, plan);
    notifyListeners();
    save();
  }

  void chooseEventByIndex(int index) {
    selectedEventIndex = index;
    notifyListeners();
  }

  Future<void> applyEventChoice(LifeEventChoice choice) async {
    final current = run;
    if (current == null) return;
    _engine.applyLifeEventChoice(current, choice);
    notifyListeners();
    await save();
  }

  void prepareWeeklyQuiz() {
    if (activeQuiz != null) return;
    final pool = financeQuizPool();
    if (pool.isEmpty) return;
    final idx = DateTime.now().millisecond % pool.length;
    activeQuiz = pool[idx];
    notifyListeners();
  }

  Future<bool> answerQuiz(int selectedIndex) async {
    final current = run;
    final quiz = activeQuiz;
    if (current == null || quiz == null) return false;
    final isCorrect = selectedIndex == quiz.correctIndex;
    _engine.applyQuizResult(current, isCorrect);
    activeQuiz = null;
    notifyListeners();
    await save();
    return isCorrect;
  }

  Future<MonthlyReport?> closeCurrentMonth() async {
    final current = run;
    if (current == null) return null;
    final report = _engine.closeMonth(current);
    notifyListeners();
    await save();
    return report;
  }

  Future<void> proceedNextMonth() async {
    final current = run;
    if (current == null || current.ending != null) return;
    _engine.nextMonth(current);
    selectedEventIndex = null;
    notifyListeners();
    await save();
  }

  Future<int> invest(int amount, int profile) async {
    final current = run;
    if (current == null) return 0;
    final delta = _engine.simulateInvestment(current, amount, profile);
    notifyListeners();
    await save();
    return delta;
  }

  Future<void> buyItem(ShopItem item) async {
    final current = run;
    if (current == null) return;
    _engine.buyShopItem(current, item.id, item.cost);
    notifyListeners();
    await save();
  }
}
