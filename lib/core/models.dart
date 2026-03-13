import 'dart:math';

enum Profession { designer, officeManager, doctor }

enum EndingType {
  financialIndependence,
  majorGoal,
  budgetGuru,
  bankruptcy,
  debtPit,
  healthCollapse,
  hedonist,
  earlyRetirement,
}

enum ExpenseCategory { mandatory, wants, savings }

enum Difficulty { easy, normal, hard }

class ProfessionConfig {
  const ProfessionConfig({
    required this.title,
    required this.baseIncome,
    required this.incomeVariance,
    required this.energyModifier,
    required this.happinessModifier,
    required this.description,
  });

  final String title;
  final int baseIncome;
  final int incomeVariance;
  final int energyModifier;
  final int happinessModifier;
  final String description;
}

const professionConfigs = <Profession, ProfessionConfig>{
  Profession.designer: ProfessionConfig(
    title: 'Дизайнер',
    baseIncome: 78000,
    incomeVariance: 25000,
    energyModifier: 0,
    happinessModifier: 8,
    description: 'Фриланс: доход высокий, но нестабильный.',
  ),
  Profession.officeManager: ProfessionConfig(
    title: 'Офис-менеджер',
    baseIncome: 65000,
    incomeVariance: 10000,
    energyModifier: 5,
    happinessModifier: 2,
    description: 'Стабильный средний доход и соцпакет.',
  ),
  Profession.doctor: ProfessionConfig(
    title: 'Врач',
    baseIncome: 92000,
    incomeVariance: 12000,
    energyModifier: -8,
    happinessModifier: 4,
    description: 'Высокий статус и доход, но меньше свободного времени.',
  ),
};

class Avatar {
  Avatar({
    required this.name,
    required this.hair,
    required this.outfit,
    required this.accessory,
    required this.profession,
  });

  final String name;
  final String hair;
  final String outfit;
  final String accessory;
  final Profession profession;

  Map<String, dynamic> toJson() => {
    'name': name,
    'hair': hair,
    'outfit': outfit,
    'accessory': accessory,
    'profession': profession.name,
  };

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
    name: json['name'] as String,
    hair: json['hair'] as String,
    outfit: json['outfit'] as String,
    accessory: json['accessory'] as String,
    profession: Profession.values.firstWhere(
      (item) => item.name == json['profession'],
    ),
  );
}

class Debt {
  Debt({
    required this.name,
    required this.principalLeft,
    required this.monthlyPayment,
    required this.rate,
    required this.monthsLeft,
  });

  final String name;
  int principalLeft;
  int monthlyPayment;
  final double rate;
  int monthsLeft;

  Map<String, dynamic> toJson() => {
    'name': name,
    'principalLeft': principalLeft,
    'monthlyPayment': monthlyPayment,
    'rate': rate,
    'monthsLeft': monthsLeft,
  };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
    name: json['name'] as String,
    principalLeft: json['principalLeft'] as int,
    monthlyPayment: json['monthlyPayment'] as int,
    rate: (json['rate'] as num).toDouble(),
    monthsLeft: json['monthsLeft'] as int,
  );
}

class Goal {
  Goal({
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
  });

  final String title;
  final int targetAmount;
  int savedAmount;

  bool get isReached => savedAmount >= targetAmount;

  Map<String, dynamic> toJson() => {
    'title': title,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    title: json['title'] as String,
    targetAmount: json['targetAmount'] as int,
    savedAmount: json['savedAmount'] as int,
  );
}

class WeeklyQuiz {
  WeeklyQuiz({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class LifeEventChoice {
  LifeEventChoice({
    required this.title,
    required this.cost,
    required this.energyChange,
    required this.happinessChange,
    this.addDebt,
    this.glossaryTerm,
  });

  final String title;
  final int cost;
  final int energyChange;
  final int happinessChange;
  final Debt? addDebt;
  final String? glossaryTerm;
}

class LifeEvent {
  LifeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.choices,
  });

  final String id;
  final String title;
  final String description;
  final List<LifeEventChoice> choices;
}

class MonthPlan {
  MonthPlan({
    required this.rent,
    required this.utilities,
    required this.communication,
    required this.transport,
    required this.food,
    required this.wants,
    required this.savings,
  });

  int rent;
  int utilities;
  int communication;
  int transport;
  int food;
  int wants;
  int savings;

  int get mandatoryTotal => rent + utilities + communication + transport + food;
  int get total => mandatoryTotal + wants + savings;

  Map<String, dynamic> toJson() => {
    'rent': rent,
    'utilities': utilities,
    'communication': communication,
    'transport': transport,
    'food': food,
    'wants': wants,
    'savings': savings,
  };

  factory MonthPlan.fromJson(Map<String, dynamic> json) => MonthPlan(
    rent: json['rent'] as int,
    utilities: json['utilities'] as int,
    communication: json['communication'] as int,
    transport: json['transport'] as int,
    food: json['food'] as int,
    wants: json['wants'] as int,
    savings: json['savings'] as int,
  );

  static MonthPlan defaultFromIncome(int income) {
    final mandatory = (income * 0.5).round();
    final wants = (income * 0.2).round();
    final savings = (income * 0.15).round();
    return MonthPlan(
      rent: (mandatory * 0.42).round(),
      utilities: (mandatory * 0.14).round(),
      communication: (mandatory * 0.08).round(),
      transport: (mandatory * 0.12).round(),
      food: max(6000, (mandatory * 0.24).round()),
      wants: wants,
      savings: savings,
    );
  }
}

class MonthlyReport {
  MonthlyReport({
    required this.month,
    required this.income,
    required this.totalExpense,
    required this.balanceEnd,
    required this.energyDelta,
    required this.happinessDelta,
    required this.notes,
  });

  final int month;
  final int income;
  final int totalExpense;
  final int balanceEnd;
  final int energyDelta;
  final int happinessDelta;
  final List<String> notes;

  Map<String, dynamic> toJson() => {
    'month': month,
    'income': income,
    'totalExpense': totalExpense,
    'balanceEnd': balanceEnd,
    'energyDelta': energyDelta,
    'happinessDelta': happinessDelta,
    'notes': notes,
  };

  factory MonthlyReport.fromJson(Map<String, dynamic> json) => MonthlyReport(
    month: json['month'] as int,
    income: json['income'] as int,
    totalExpense: json['totalExpense'] as int,
    balanceEnd: json['balanceEnd'] as int,
    energyDelta: json['energyDelta'] as int,
    happinessDelta: json['happinessDelta'] as int,
    notes: (json['notes'] as List<dynamic>).cast<String>(),
  );
}

class GameStats {
  GameStats();

  int totalIncome = 0;
  int totalExpenses = 0;
  int mandatoryExpenses = 0;
  int wantsExpenses = 0;
  int savingsExpenses = 0;
  int creditsTaken = 0;
  int quizCorrect = 0;
  int quizzesTaken = 0;
  int monthsWithPositiveRemainder = 0;
  int monthsNoDebt = 0;
  int monthsConsecutiveNoDebt = 0;
  int monthsConsecutiveHealthy = 0;
  int monthsConsecutiveSavings10 = 0;
  int impulseSpendTriggers = 0;
  int investmentsDone = 0;
  int bankruptcyWarnings = 0;
  int debtTrapWarnings = 0;

  Map<String, dynamic> toJson() => {
    'totalIncome': totalIncome,
    'totalExpenses': totalExpenses,
    'mandatoryExpenses': mandatoryExpenses,
    'wantsExpenses': wantsExpenses,
    'savingsExpenses': savingsExpenses,
    'creditsTaken': creditsTaken,
    'quizCorrect': quizCorrect,
    'quizzesTaken': quizzesTaken,
    'monthsWithPositiveRemainder': monthsWithPositiveRemainder,
    'monthsNoDebt': monthsNoDebt,
    'monthsConsecutiveNoDebt': monthsConsecutiveNoDebt,
    'monthsConsecutiveHealthy': monthsConsecutiveHealthy,
    'monthsConsecutiveSavings10': monthsConsecutiveSavings10,
    'impulseSpendTriggers': impulseSpendTriggers,
    'investmentsDone': investmentsDone,
    'bankruptcyWarnings': bankruptcyWarnings,
    'debtTrapWarnings': debtTrapWarnings,
  };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    final stats = GameStats();
    stats.totalIncome = json['totalIncome'] as int;
    stats.totalExpenses = json['totalExpenses'] as int;
    stats.mandatoryExpenses = json['mandatoryExpenses'] as int;
    stats.wantsExpenses = json['wantsExpenses'] as int;
    stats.savingsExpenses = json['savingsExpenses'] as int;
    stats.creditsTaken = json['creditsTaken'] as int;
    stats.quizCorrect = json['quizCorrect'] as int;
    stats.quizzesTaken = json['quizzesTaken'] as int;
    stats.monthsWithPositiveRemainder =
        json['monthsWithPositiveRemainder'] as int;
    stats.monthsNoDebt = json['monthsNoDebt'] as int;
    stats.monthsConsecutiveNoDebt = json['monthsConsecutiveNoDebt'] as int;
    stats.monthsConsecutiveHealthy = json['monthsConsecutiveHealthy'] as int;
    stats.monthsConsecutiveSavings10 =
        json['monthsConsecutiveSavings10'] as int;
    stats.impulseSpendTriggers = json['impulseSpendTriggers'] as int;
    stats.investmentsDone = json['investmentsDone'] as int;
    stats.bankruptcyWarnings = json['bankruptcyWarnings'] as int;
    stats.debtTrapWarnings = json['debtTrapWarnings'] as int;
    return stats;
  }
}

int nextIncome(Profession profession, Random random) {
  final cfg = professionConfigs[profession]!;
  final variance =
      random.nextInt(cfg.incomeVariance * 2 + 1) - cfg.incomeVariance;
  return (cfg.baseIncome + variance).clamp(28000, 180000);
}
