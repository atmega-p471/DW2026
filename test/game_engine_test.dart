import 'package:flutter_test/flutter_test.dart';
import 'package:moneyflow_month_by_month/core/game_engine.dart';
import 'package:moneyflow_month_by_month/core/models.dart';

void main() {
  group('GameEngine', () {
    late GameEngine engine;
    late GameRun run;

    setUp(() {
      engine = GameEngine();
      run = engine.newGame(
        avatar: Avatar(
          name: 'Тест',
          hair: 'Короткая',
          outfit: 'Casual',
          accessory: 'Часы',
          profession: Profession.officeManager,
        ),
        goal: Goal(title: 'Подушка', targetAmount: 100000, savedAmount: 0),
        difficulty: Difficulty.normal,
      );
    });

    test('банкротство при уходе в минус на событии', () {
      run.balance = 1000;

      engine.applyLifeEventChoice(
        run,
        LifeEventChoice(
          title: 'Слишком дорогой выбор',
          cost: 5000,
          energyChange: 0,
          happinessChange: 0,
        ),
      );

      expect(run.balance, 0);
      expect(run.ending, EndingType.bankruptcy);
    });

    test('проигрыш при нулевой энергии', () {
      run.energy = 3;

      engine.applyLifeEventChoice(
        run,
        LifeEventChoice(
          title: 'Полное выгорание',
          cost: 0,
          energyChange: -10,
          happinessChange: 0,
        ),
      );

      expect(run.energy, 0);
      expect(run.ending, EndingType.healthCollapse);
    });

    test('месячный отчет учитывает траты события и начисляет финкоины', () {
      run.balance = 50000;
      run.currentIncome = 50000;
      run.currentPlan = MonthPlan(
        rent: 10000,
        utilities: 2000,
        communication: 1000,
        transport: 2000,
        food: 5000,
        wants: 4000,
        savings: 3000,
      );

      final finCoinsBefore = run.finCoins;
      engine.applyLifeEventChoice(
        run,
        LifeEventChoice(
          title: 'Событие',
          cost: 3500,
          energyChange: 0,
          happinessChange: 0,
        ),
      );

      final report = engine.closeMonth(run);

      expect(report.totalExpense, 30500);
      expect(run.finCoins, greaterThan(finCoinsBefore));
    });

    test('цель не дает победу при нулевом балансе', () {
      run.balance = 0;
      run.currentIncome = 40000;
      run.goal.savedAmount = run.goal.targetAmount;
      run.currentPlan = MonthPlan(
        rent: 0,
        utilities: 0,
        communication: 0,
        transport: 0,
        food: 0,
        wants: 0,
        savings: 0,
      );

      engine.closeMonth(run);

      expect(run.ending, isNot(EndingType.majorGoal));
      expect(run.ending, EndingType.bankruptcy);
    });
  });
}
