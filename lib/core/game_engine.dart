import 'dart:math';

import 'models.dart';

class GameRun {
  GameRun({
    required this.avatar,
    required this.difficulty,
    required this.goal,
    required this.month,
    required this.balance,
    required this.energy,
    required this.happiness,
    required this.finCoins,
    required this.currentIncome,
    required this.currentPlan,
    required this.eventQueue,
    required this.reports,
    required this.debts,
    required this.glossary,
    required this.achievements,
    required this.shopInventory,
    required this.stats,
    required this.monthsUnpaidMandatory,
    required this.monthsDebtOverIncome,
    required this.monthsEnergyCritical,
    required this.monthlySavingsPool,
    required this.emergencyFund,
    required this.currentMonthExtraExpenses,
  });

  final Avatar avatar;
  final Difficulty difficulty;
  Goal goal;
  int month;
  int balance;
  int energy;
  int happiness;
  int finCoins;
  int currentIncome;
  MonthPlan currentPlan;
  List<LifeEvent> eventQueue;
  List<MonthlyReport> reports;
  List<Debt> debts;
  Set<String> glossary;
  Set<String> achievements;
  Set<String> shopInventory;
  GameStats stats;
  int monthsUnpaidMandatory;
  int monthsDebtOverIncome;
  int monthsEnergyCritical;
  int monthlySavingsPool;
  int emergencyFund;
  int currentMonthExtraExpenses;
  EndingType? ending;

  bool get investmentUnlocked => month >= 6;
  bool get hasDebt => debts.isNotEmpty;

  int get debtPaymentTotal =>
      debts.fold<int>(0, (sum, debt) => sum + debt.monthlyPayment);

  int get mandatoryNeed {
    final levelFactor = switch (difficulty) {
      Difficulty.easy => 0.9,
      Difficulty.normal => 1.0,
      Difficulty.hard => 1.12,
    };
    return (currentPlan.mandatoryTotal * levelFactor).round();
  }

  int get stabilityTarget => mandatoryNeed * 12;

  Map<String, dynamic> toJson() => {
    'avatar': avatar.toJson(),
    'difficulty': difficulty.name,
    'goal': goal.toJson(),
    'month': month,
    'balance': balance,
    'energy': energy,
    'happiness': happiness,
    'finCoins': finCoins,
    'currentIncome': currentIncome,
    'currentPlan': currentPlan.toJson(),
    'eventQueue': eventQueue.map(_eventToJson).toList(),
    'reports': reports.map((report) => report.toJson()).toList(),
    'debts': debts.map((debt) => debt.toJson()).toList(),
    'glossary': glossary.toList(),
    'achievements': achievements.toList(),
    'shopInventory': shopInventory.toList(),
    'stats': stats.toJson(),
    'monthsUnpaidMandatory': monthsUnpaidMandatory,
    'monthsDebtOverIncome': monthsDebtOverIncome,
    'monthsEnergyCritical': monthsEnergyCritical,
    'monthlySavingsPool': monthlySavingsPool,
    'emergencyFund': emergencyFund,
    'currentMonthExtraExpenses': currentMonthExtraExpenses,
    'ending': ending?.name,
  };

  factory GameRun.fromJson(Map<String, dynamic> json) =>
      GameRun(
          avatar: Avatar.fromJson(json['avatar'] as Map<String, dynamic>),
          difficulty: Difficulty.values.firstWhere(
            (item) => item.name == json['difficulty'],
          ),
          goal: Goal.fromJson(json['goal'] as Map<String, dynamic>),
          month: json['month'] as int,
          balance: json['balance'] as int,
          energy: json['energy'] as int,
          happiness: json['happiness'] as int,
          finCoins: json['finCoins'] as int,
          currentIncome: json['currentIncome'] as int,
          currentPlan: MonthPlan.fromJson(
            json['currentPlan'] as Map<String, dynamic>,
          ),
          eventQueue: (json['eventQueue'] as List<dynamic>)
              .map((item) => _eventFromJson(item as Map<String, dynamic>))
              .toList(),
          reports: (json['reports'] as List<dynamic>)
              .map(
                (item) => MonthlyReport.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
          debts: (json['debts'] as List<dynamic>)
              .map((item) => Debt.fromJson(item as Map<String, dynamic>))
              .toList(),
          glossary: (json['glossary'] as List<dynamic>).cast<String>().toSet(),
          achievements: (json['achievements'] as List<dynamic>)
              .cast<String>()
              .toSet(),
          shopInventory: (json['shopInventory'] as List<dynamic>)
              .cast<String>()
              .toSet(),
          stats: GameStats.fromJson(json['stats'] as Map<String, dynamic>),
          monthsUnpaidMandatory: json['monthsUnpaidMandatory'] as int,
          monthsDebtOverIncome: json['monthsDebtOverIncome'] as int,
          monthsEnergyCritical: json['monthsEnergyCritical'] as int,
          monthlySavingsPool: json['monthlySavingsPool'] as int,
          emergencyFund: json['emergencyFund'] as int,
          currentMonthExtraExpenses:
              (json['currentMonthExtraExpenses'] as int?) ?? 0,
        )
        ..ending = (json['ending'] as String?) == null
            ? null
            : EndingType.values.firstWhere(
                (item) => item.name == json['ending'],
              );
}

class GameEngine {
  GameEngine() : _random = Random();

  final Random _random;

  GameRun newGame({
    required Avatar avatar,
    required Goal goal,
    required Difficulty difficulty,
  }) {
    final income = nextIncome(avatar.profession, _random);
    final plan = MonthPlan.defaultFromIncome(income);
    return GameRun(
      avatar: avatar,
      difficulty: difficulty,
      goal: goal,
      month: 1,
      balance: income,
      energy: (70 + professionConfigs[avatar.profession]!.energyModifier).clamp(
        0,
        100,
      ),
      happiness: (65 + professionConfigs[avatar.profession]!.happinessModifier)
          .clamp(0, 100),
      finCoins: 0,
      currentIncome: income,
      currentPlan: plan,
      eventQueue: createMonthlyEvents(month: 1),
      reports: <MonthlyReport>[],
      debts: <Debt>[],
      glossary: {'Бюджет', 'Переплата', 'Подушка безопасности'},
      achievements: <String>{},
      shopInventory: <String>{},
      stats: GameStats(),
      monthsUnpaidMandatory: 0,
      monthsDebtOverIncome: 0,
      monthsEnergyCritical: 0,
      monthlySavingsPool: 0,
      emergencyFund: 0,
      currentMonthExtraExpenses: 0,
    );
  }

  List<LifeEvent> createMonthlyEvents({required int month}) {
    final base = <LifeEvent>[
      LifeEvent(
        id: 'phone_break',
        title: 'Сломался телефон',
        description: 'Связь нужна для работы и общения. Как решишь проблему?',
        choices: [
          LifeEventChoice(
            title: 'Ремонт за 3000',
            cost: 3000,
            energyChange: -2,
            happinessChange: -3,
            glossaryTerm: 'Амортизация',
          ),
          LifeEventChoice(
            title: 'Новый за 30000',
            cost: 30000,
            energyChange: 4,
            happinessChange: 8,
          ),
          LifeEventChoice(
            title: 'Кредит 30000 на 6 мес',
            cost: 0,
            energyChange: 0,
            happinessChange: 4,
            addDebt: Debt(
              name: 'Телефон в кредит',
              principalLeft: 36000,
              monthlyPayment: 6000,
              rate: 0.2,
              monthsLeft: 6,
            ),
            glossaryTerm: 'Кредит',
          ),
        ],
      ),
      LifeEvent(
        id: 'dental',
        title: 'Визит к стоматологу',
        description: 'Небольшая боль может стать большой проблемой.',
        choices: [
          LifeEventChoice(
            title: 'Лечить сейчас 5500',
            cost: 5500,
            energyChange: 2,
            happinessChange: 1,
          ),
          LifeEventChoice(
            title: 'Отложить',
            cost: 0,
            energyChange: -8,
            happinessChange: -7,
            glossaryTerm: 'Отложенный риск',
          ),
        ],
      ),
      LifeEvent(
        id: 'friend_trip',
        title: 'Друзья зовут в мини-поездку',
        description: 'Траты поднимут настроение, но уменьшат накопления.',
        choices: [
          LifeEventChoice(
            title: 'Поехать (9000)',
            cost: 9000,
            energyChange: 7,
            happinessChange: 10,
          ),
          LifeEventChoice(
            title: 'Остаться дома',
            cost: 0,
            energyChange: 1,
            happinessChange: -3,
          ),
        ],
      ),
    ];

    if (month >= 6) {
      base.add(
        LifeEvent(
          id: 'investment_offer',
          title: 'Появилась инвестиционная возможность',
          description: 'Выбери риск-профиль и узнай результат в конце месяца.',
          choices: [
            LifeEventChoice(
              title: 'Консервативно (5000)',
              cost: 5000,
              energyChange: 0,
              happinessChange: 1,
              glossaryTerm: 'Инфляция',
            ),
            LifeEventChoice(
              title: 'Сбалансированно (10000)',
              cost: 10000,
              energyChange: 0,
              happinessChange: 2,
            ),
            LifeEventChoice(
              title: 'Агрессивно (15000)',
              cost: 15000,
              energyChange: -1,
              happinessChange: 3,
            ),
          ],
        ),
      );
    }

    base.shuffle(_random);
    return base.take(2).toList();
  }

  void applyPlan(GameRun run, MonthPlan plan) {
    run.currentPlan = plan;
  }

  void applyLifeEventChoice(GameRun run, LifeEventChoice choice) {
    run.balance -= choice.cost;
    run.currentMonthExtraExpenses += choice.cost;
    run.energy = (run.energy + choice.energyChange).clamp(0, 100);
    run.happiness = (run.happiness + choice.happinessChange).clamp(0, 100);
    run.finCoins += 8;
    if (choice.addDebt case final debt?) {
      run.debts.add(debt);
      run.stats.creditsTaken += 1;
    }
    if (choice.glossaryTerm case final term?) {
      run.glossary.add(term);
    }
    _resolveCriticalState(run);
  }

  MonthlyReport closeMonth(GameRun run) {
    final notes = <String>[];
    final plan = run.currentPlan;
    final mandatoryMin = mandatoryMinimum(run.currentIncome);
    final debtBefore = run.debtPaymentTotal;
    final energyBefore = run.energy;
    final happinessBefore = run.happiness;
    final extraExpensesBefore = run.currentMonthExtraExpenses;
    var totalExpense = plan.total + debtBefore + extraExpensesBefore;

    run.balance -= plan.total;
    run.stats.totalIncome += run.currentIncome;
    run.stats.totalExpenses += plan.total;
    run.stats.mandatoryExpenses += plan.mandatoryTotal;
    run.stats.wantsExpenses += plan.wants;
    run.stats.savingsExpenses += plan.savings;

    run.monthlySavingsPool += plan.savings;
    run.emergencyFund += (plan.savings * 0.55).round();
    run.goal.savedAmount += (plan.savings * 0.45).round();

    if (plan.food < 6500) {
      run.energy = (run.energy - 12).clamp(0, 100);
      notes.add('Экономия на еде снизила энергию.');
    } else {
      run.energy = (run.energy + 4).clamp(0, 100);
    }

    if (plan.wants < 5000) {
      run.happiness = (run.happiness - 9).clamp(0, 100);
      notes.add('Почти не было трат на радость, счастье снизилось.');
    } else {
      run.happiness = (run.happiness + 6).clamp(0, 100);
    }

    if (run.happiness <= 30 && run.balance > 0) {
      final impulse = min(7000, run.balance);
      run.balance -= impulse;
      run.currentMonthExtraExpenses += impulse;
      totalExpense += impulse;
      run.stats.impulseSpendTriggers += 1;
      run.happiness = (run.happiness + 5).clamp(0, 100);
      notes.add('Импульсивная трата из-за низкого счастья: -$impulse ₽');
    }

    final moodEnergyDrain = _moodEnergyDrain(run.happiness);
    if (moodEnergyDrain > 0) {
      run.energy = (run.energy - moodEnergyDrain).clamp(0, 100);
      notes.add('Низкое счастье вымотало персонажа: -$moodEnergyDrain энергии.');
    }

    if (plan.mandatoryTotal < mandatoryMin) {
      run.monthsUnpaidMandatory += 1;
      run.stats.bankruptcyWarnings += 1;
      run.happiness = (run.happiness - 12).clamp(0, 100);
      notes.add('Обязательные платежи не покрыты полностью.');
    } else {
      run.monthsUnpaidMandatory = 0;
    }

    final debtNotes = _processDebts(run);
    notes.addAll(debtNotes);

    if (run.debtPaymentTotal > run.currentIncome) {
      run.monthsDebtOverIncome += 1;
      run.stats.debtTrapWarnings += 1;
      notes.add('Платежи по долгам выше дохода.');
    } else {
      run.monthsDebtOverIncome = 0;
    }

    if (run.energy <= 18) {
      run.monthsEnergyCritical += 1;
      notes.add('Критически низкая энергия.');
    } else {
      run.monthsEnergyCritical = 0;
    }

    if (run.balance > 0) {
      run.stats.monthsWithPositiveRemainder += 1;
    }
    if (run.debts.isEmpty) {
      run.stats.monthsNoDebt += 1;
      run.stats.monthsConsecutiveNoDebt += 1;
    } else {
      run.stats.monthsConsecutiveNoDebt = 0;
    }

    if (run.energy >= 75 && run.happiness >= 75) {
      run.stats.monthsConsecutiveHealthy += 1;
    } else {
      run.stats.monthsConsecutiveHealthy = 0;
    }

    final ratio = run.currentIncome == 0
        ? 0.0
        : (run.balance / run.currentIncome);
    if (ratio >= 0.1) {
      run.stats.monthsConsecutiveSavings10 += 1;
    } else {
      run.stats.monthsConsecutiveSavings10 = 0;
    }

    final finCoinReward = _grantMonthlyFinCoins(run);
    if (finCoinReward > 0) {
      notes.add('Получено +$finCoinReward ФинКоинов за месяц.');
    }

    _resolveCriticalState(run);
    if (run.ending == null) {
      _unlockAchievements(run);
      _checkEnding(run);
    }

    final report = MonthlyReport(
      month: run.month,
      income: run.currentIncome,
      totalExpense: totalExpense,
      balanceEnd: run.balance,
      energyDelta: run.energy - energyBefore,
      happinessDelta: run.happiness - happinessBefore,
      notes: notes,
    );
    run.currentMonthExtraExpenses = 0;
    run.reports.insert(0, report);
    return report;
  }

  int _grantMonthlyFinCoins(GameRun run) {
    var reward = 10;
    if (run.currentPlan.savings > 0) reward += 5;
    if (run.balance > 0) reward += 5;
    if (run.happiness >= 60) reward += 3;
    if (run.debts.isEmpty) reward += 2;
    run.finCoins += reward;
    return reward;
  }

  int _moodEnergyDrain(int happiness) {
    if (happiness >= 70) return 0;
    if (happiness >= 50) return 3;
    if (happiness >= 30) return 6;
    if (happiness >= 15) return 10;
    return 14;
  }

  void _resolveCriticalState(GameRun run) {
    if (run.balance < 0) {
      run.balance = 0;
      run.ending = EndingType.bankruptcy;
    }
    if (run.energy <= 0) {
      run.energy = 0;
      run.ending = EndingType.healthCollapse;
    }
  }

  List<String> _processDebts(GameRun run) {
    final notes = <String>[];
    for (final debt in List<Debt>.from(run.debts)) {
      run.balance -= debt.monthlyPayment;
      debt.principalLeft -= debt.monthlyPayment;
      debt.monthsLeft -= 1;
      if (debt.principalLeft <= 0 || debt.monthsLeft <= 0) {
        run.debts.remove(debt);
        notes.add('Долг "${debt.name}" закрыт.');
      }
    }
    return notes;
  }

  void nextMonth(GameRun run) {
    if (run.ending != null) {
      return;
    }
    run.month += 1;
    final baseIncome = nextIncome(run.avatar.profession, _random);
    final energyFactor = run.energy < 25 ? 0.9 : 1.0;
    final happinessFactor = run.happiness < 25 ? 0.93 : 1.0;
    run.currentIncome = (baseIncome * energyFactor * happinessFactor).round();
    run.balance += run.currentIncome;
    run.currentPlan = MonthPlan.defaultFromIncome(run.currentIncome);
    run.eventQueue = createMonthlyEvents(month: run.month);
    run.currentMonthExtraExpenses = 0;
  }

  void applyQuizResult(GameRun run, bool isCorrect) {
    run.stats.quizzesTaken += 1;
    if (isCorrect) {
      run.stats.quizCorrect += 1;
      run.finCoins += 20;
      run.glossary.add('Инфляция');
      run.glossary.add('Диверсификация');
    } else {
      run.finCoins += 5;
    }
  }

  int simulateInvestment(GameRun run, int amount, int profile) {
    if (amount > run.balance || amount <= 0) {
      return 0;
    }
    run.balance -= amount;
    run.stats.investmentsDone += 1;
    final multiplier = switch (profile) {
      0 => 1.0 + (_random.nextDouble() * 0.12 - 0.02),
      1 => 1.0 + (_random.nextDouble() * 0.24 - 0.08),
      _ => 1.0 + (_random.nextDouble() * 0.45 - 0.2),
    };
    final result = (amount * multiplier).round();
    run.balance += result;
    return result - amount;
  }

  int mandatoryMinimum(int income) => (income * 0.5).round();

  void buyShopItem(GameRun run, String id, int cost) {
    if (run.shopInventory.contains(id) || run.finCoins < cost) {
      return;
    }
    run.finCoins -= cost;
    run.shopInventory.add(id);
  }

  void _unlockAchievements(GameRun run) {
    if (run.goal.savedAmount >= 100000) {
      run.achievements.add('Скупой рыцарь');
    }
    if (run.currentPlan.wants > run.currentPlan.mandatoryTotal &&
        run.currentPlan.mandatoryTotal >= mandatoryMinimum(run.currentIncome)) {
      run.achievements.add('Жизнь в кайф');
    }
    if (run.stats.monthsConsecutiveSavings10 >= 5) {
      run.achievements.add('Гуру бюджета x5');
    }
    if (run.stats.creditsTaken >= 5 && run.debts.isEmpty) {
      run.achievements.add('Кредитный скиталец');
    }
  }

  void _checkEnding(GameRun run) {
    if (run.ending != null) {
      return;
    }
    if (run.balance <= 0) {
      run.ending = EndingType.bankruptcy;
      return;
    }
    if (run.energy <= 0) {
      run.ending = EndingType.healthCollapse;
      return;
    }
    if (run.monthsUnpaidMandatory >= 2) {
      run.ending = EndingType.bankruptcy;
      return;
    }
    if (run.monthsDebtOverIncome >= 3) {
      run.ending = EndingType.debtPit;
      return;
    }
    if (run.monthsEnergyCritical >= 2) {
      run.ending = EndingType.healthCollapse;
      return;
    }
    if (run.goal.savedAmount >= run.stabilityTarget &&
        run.debts.isEmpty &&
        run.balance > 0 &&
        run.energy > 0) {
      run.ending = EndingType.financialIndependence;
      return;
    }
    if (run.goal.isReached && run.balance > 0 && run.energy > 0) {
      run.ending = EndingType.majorGoal;
      return;
    }
    if (run.stats.monthsConsecutiveNoDebt >= 12 &&
        run.balance > 0 &&
        run.energy >= 95 &&
        run.happiness >= 95) {
      run.ending = EndingType.budgetGuru;
      return;
    }
    if (run.month >= 60 &&
        run.goal.savedAmount < run.currentIncome &&
        run.stats.wantsExpenses > run.stats.savingsExpenses) {
      run.ending = EndingType.hedonist;
      return;
    }
    if (run.month >= 24 &&
        run.stats.investmentsDone >= 12 &&
        run.goal.savedAmount >= run.stabilityTarget * 2) {
      run.ending = EndingType.earlyRetirement;
    }
  }
}

Map<String, dynamic> _eventToJson(LifeEvent event) => {
  'id': event.id,
  'title': event.title,
  'description': event.description,
  'choices': event.choices
      .map(
        (choice) => {
          'title': choice.title,
          'cost': choice.cost,
          'energyChange': choice.energyChange,
          'happinessChange': choice.happinessChange,
          'addDebt': choice.addDebt?.toJson(),
          'glossaryTerm': choice.glossaryTerm,
        },
      )
      .toList(),
};

LifeEvent _eventFromJson(Map<String, dynamic> json) => LifeEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map(
        (item) => LifeEventChoice(
          title: (item as Map<String, dynamic>)['title'] as String,
          cost: item['cost'] as int,
          energyChange: item['energyChange'] as int,
          happinessChange: item['happinessChange'] as int,
          addDebt: item['addDebt'] == null
              ? null
              : Debt.fromJson(item['addDebt'] as Map<String, dynamic>),
          glossaryTerm: item['glossaryTerm'] as String?,
        ),
      )
      .toList(),
);

List<WeeklyQuiz> financeQuizPool() => [
  WeeklyQuiz(
    question: 'Что такое инфляция?',
    options: const [
      'Рост цен на товары и услуги',
      'Скидка в магазине',
      'Кредит без процентов',
    ],
    correctIndex: 0,
    explanation: 'Инфляция снижает покупательную способность денег.',
  ),
  WeeklyQuiz(
    question: 'Подушка безопасности должна покрывать минимум...',
    options: const ['1 месяц', '3-6 месяцев', '12 часов'],
    correctIndex: 1,
    explanation: 'Обычно рекомендуют резерв на 3-6 месяцев расходов.',
  ),
  WeeklyQuiz(
    question: 'Что означает рефинансирование кредита?',
    options: const [
      'Взять второй кредит',
      'Изменить условия старого долга на более выгодные',
      'Не платить кредит 1 месяц',
    ],
    correctIndex: 1,
    explanation: 'Рефинансирование уменьшает переплату и/или платеж.',
  ),
];

String endingTitle(EndingType ending) => switch (ending) {
  EndingType.financialIndependence => 'Финансовая независимость',
  EndingType.majorGoal => 'Крупная цель достигнута',
  EndingType.budgetGuru => 'Гуру бюджета',
  EndingType.bankruptcy => 'Финансовый крах',
  EndingType.debtPit => 'Долговая кабала',
  EndingType.healthCollapse => 'Копилка ценой здоровья',
  EndingType.hedonist => 'Жизнь в моменте',
  EndingType.earlyRetirement => 'Ранняя пенсия',
};

String endingDescription(EndingType ending) => switch (ending) {
  EndingType.financialIndependence =>
    'Ты создал(а) подушку и закрыл(а) долги. Теперь деньги работают на твою свободу.',
  EndingType.majorGoal =>
    'Финансовая цель закрыта. Ты доказал(а), что дисциплина приносит результат.',
  EndingType.budgetGuru =>
    'Идеальная серия месяцев без долгов с максимальным благополучием.',
  EndingType.bankruptcy =>
    'Обязательные платежи не покрыты два месяца подряд. Нужна перезагрузка стратегии.',
  EndingType.debtPit =>
    'Платежи по долгам стали выше дохода. Выбираться можно через жесткий план.',
  EndingType.healthCollapse =>
    'Постоянная экономия на базовых потребностях подорвала здоровье.',
  EndingType.hedonist =>
    'Жил(а) в удовольствие, но без финансового резерва на будущее.',
  EndingType.earlyRetirement =>
    'Инвестиции и дисциплина дали право жить на своих условиях.',
};
