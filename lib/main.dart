import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/app_state.dart';
import 'core/game_engine.dart';
import 'core/models.dart';
import 'ui/fx_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoneyFlowApp());
}

class MoneyFlowApp extends StatefulWidget {
  const MoneyFlowApp({super.key});

  @override
  State<MoneyFlowApp> createState() => _MoneyFlowAppState();
}

class _MoneyFlowAppState extends State<MoneyFlowApp> {
  final MoneyFlowState state = MoneyFlowState();

  @override
  void initState() {
    super.initState();
    state.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MoneyFlow: Месяц за месяцем',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F6D63),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F7FB),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Color(0xFF1F2937),
              centerTitle: false,
              elevation: 0,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              elevation: 0,
              height: 72,
              indicatorColor: const Color(0xFF2F6D63).withValues(alpha: 0.12),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD6DDE7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFD6DDE7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF2F6D63),
                  width: 1.4,
                ),
              ),
            ),
          ),
          home: !state.isLoaded
              ? const SplashScreen()
              : state.hasGame
              ? GameShell(state: state)
              : OnboardingScreen(state: state),
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MoneyFlowBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 28,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 44,
                  color: Color(0xFF2F6D63),
                ),
              ).animate().fadeIn(duration: 300.ms).scale(),
              const SizedBox(height: 20),
              Text(
                'MoneyFlow',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ).animate().fadeIn(delay: 120.ms),
              const SizedBox(height: 6),
              const Text(
                'Месяц за месяцем',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
              ).animate().fadeIn(delay: 220.ms),
              const SizedBox(height: 30),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.8),
              ).animate().fadeIn(delay: 320.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state});

  final MoneyFlowState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController nameController = TextEditingController(
    text: 'Алекс',
  );
  final goals = const [
    ('Отпуск', 100000),
    ('Игровая консоль', 150000),
    ('Автомобиль', 500000),
    ('Первый взнос', 1000000),
  ];

  Profession profession = Profession.officeManager;
  Difficulty difficulty = Difficulty.normal;
  int selectedGoal = 0;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Начало игры')),
      body: MoneyFlowBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  GradientHeroCard(
                    title: 'Спокойный старт',
                    subtitle:
                        'Минимум перегруза: сначала создаём персонажа, потом сразу переходим к жизни и бюджету.',
                    trailing: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F2EF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.auto_graph_rounded,
                        color: Color(0xFF2F6D63),
                      ),
                    ),
                  ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.05),
                  const SizedBox(height: 14),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(
                          title: 'Профиль',
                          subtitle: 'База для начала истории.',
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: nameController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Имя персонажа',
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<Profession>(
                          initialValue: profession,
                          decoration: const InputDecoration(
                            labelText: 'Профессия',
                          ),
                          items: professionConfigs.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value.title),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => profession = value);
                          },
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            professionConfigs[profession]!.description,
                            key: ValueKey(profession.name),
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<Difficulty>(
                          initialValue: difficulty,
                          decoration: const InputDecoration(
                            labelText: 'Сложность',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: Difficulty.easy,
                              child: Text('Легко'),
                            ),
                            DropdownMenuItem(
                              value: Difficulty.normal,
                              child: Text('Нормально'),
                            ),
                            DropdownMenuItem(
                              value: Difficulty.hard,
                              child: Text('Сложно'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => difficulty = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          initialValue: selectedGoal,
                          decoration: const InputDecoration(
                            labelText: 'Финансовая цель',
                          ),
                          items: [
                            for (var i = 0; i < goals.length; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text(
                                  '${goals[i].$1} • ${goals[i].$2} ₽',
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => selectedGoal = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F6D63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final avatar = Avatar(
                        name: nameController.text.trim().isEmpty
                            ? 'Игрок'
                            : nameController.text.trim(),
                        hair: 'Короткая',
                        outfit: 'Casual',
                        accessory: 'Часы',
                        profession: profession,
                      );
                      await widget.state.startNewGame(
                        avatar: avatar,
                        difficulty: difficulty,
                        goal: Goal(
                          title: goals[selectedGoal].$1,
                          targetAmount: goals[selectedGoal].$2,
                          savedAmount: 0,
                        ),
                      );
                    },
                    child: const Text('Начать новую жизнь'),
                  ).animate().fadeIn(delay: 160.ms).slideY(begin: 0.06),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameShell extends StatefulWidget {
  const GameShell({super.key, required this.state});

  final MoneyFlowState state;

  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  int navIndex = 1;
  EndingType? shownEnding;

  @override
  Widget build(BuildContext context) {
    final run = widget.state.run;
    if (run == null) return const SizedBox.shrink();
    _showEndingIfNeeded(run);

    final pages = [
      OverviewTab(state: widget.state),
      MonthTab(state: widget.state),
      ShopTab(state: widget.state),
      ProfileTab(
        state: widget.state,
        onOpenStats: () => _openStats(context),
      ),
    ];

    return Scaffold(
      body: MoneyFlowBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(navIndex),
            child: pages[navIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (index) => setState(() => navIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Обзор'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Месяц',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Магазин',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  void _showEndingIfNeeded(GameRun run) {
    if (run.ending == null || shownEnding == run.ending) return;
    shownEnding = run.ending;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(endingTitle(run.ending!)),
          content: Text(endingDescription(run.ending!)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ок'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.state.reset();
              },
              child: const Text('Новая игра'),
            ),
          ],
        ),
      );
    });
  }

  void _openStats(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => StatsScreen(state: widget.state)),
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.state});

  final MoneyFlowState state;

  @override
  Widget build(BuildContext context) {
    final run = state.run;
    if (run == null) return const SizedBox.shrink();
    final roomLevel = (run.goal.savedAmount / max(1, run.goal.targetAmount) * 4)
        .clamp(1, 4)
        .toInt();

    return _ScreenFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          GradientHeroCard(
            title: 'Привет, ${run.avatar.name}',
            subtitle:
                'Месяц ${run.month} • ${professionConfigs[run.avatar.profession]!.title}',
            gradientColors: const [Color(0xFF2F6D63), Color(0xFF4B8B80)],
            trailing: _HeroBadge(text: '${run.balance} ₽'),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              AnimatedMetricPill(
                label: 'Баланс',
                value: run.balance,
                color: const Color(0xFF2F6D63),
                icon: Icons.wallet_outlined,
                suffix: ' ₽',
              ),
              AnimatedMetricPill(
                label: 'Энергия',
                value: run.energy,
                color: const Color(0xFFD97706),
                icon: Icons.bolt_outlined,
                suffix: '%',
              ),
              AnimatedMetricPill(
                label: 'Счастье',
                value: run.happiness,
                color: const Color(0xFF7C3AED),
                icon: Icons.favorite_outline,
                suffix: '%',
              ),
              AnimatedMetricPill(
                label: 'ФинКоины',
                value: run.finCoins,
                color: const Color(0xFF4F46E5),
                icon: Icons.stars_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Цель и атмосфера',
                  subtitle: 'Сколько уже накоплено и как меняется жизнь персонажа.',
                ),
                const SizedBox(height: 14),
                AnimatedProgressBar(
                  value: run.goal.savedAmount / run.goal.targetAmount,
                  height: 12,
                ),
                const SizedBox(height: 14),
                _InfoLine(label: 'Цель', value: run.goal.title),
                const SizedBox(height: 8),
                _InfoLine(
                  label: 'Накоплено',
                  value: '${run.goal.savedAmount} / ${run.goal.targetAmount} ₽',
                ),
                const SizedBox(height: 8),
                _InfoLine(
                  label: 'Комната',
                  value: 'Уровень уюта $roomLevel/4',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Состояние месяца',
                  subtitle: 'Короткие выводы без перегруза цифрами.',
                ),
                const SizedBox(height: 14),
                _StatusRow(
                  label: run.debts.isEmpty ? 'Долгов нет' : 'Есть долговая нагрузка',
                  tone: run.debts.isEmpty ? _Tone.good : _Tone.bad,
                ),
                const SizedBox(height: 10),
                _StatusRow(
                  label: run.energy >= 40 ? 'Энергия в норме' : 'Стоит добавить отдых',
                  tone: run.energy >= 40 ? _Tone.good : _Tone.warn,
                ),
                const SizedBox(height: 10),
                _StatusRow(
                  label: run.happiness >= 40
                      ? 'Эмоциональный фон стабильный'
                      : 'Есть риск импульсивных трат',
                  tone: run.happiness >= 40 ? _Tone.good : _Tone.warn,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Достижения',
                  subtitle: 'Ключевые вехи этого прохождения.',
                ),
                const SizedBox(height: 14),
                if (run.achievements.isEmpty)
                  const Text(
                    'Пока достижений нет. Первый стабильный месяц уже станет хорошим стартом.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: run.achievements
                        .map((item) => Chip(label: Text(item)))
                        .toList(),
                  ),
              ],
            ),
          ),
          if (run.debts.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    title: 'Долги',
                    subtitle: 'Что влияет на твой ежемесячный платеж.',
                  ),
                  const SizedBox(height: 14),
                  for (final debt in run.debts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DebtTile(debt: debt),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MonthTab extends StatefulWidget {
  const MonthTab({super.key, required this.state});

  final MoneyFlowState state;

  @override
  State<MonthTab> createState() => _MonthTabState();
}

class _MonthTabState extends State<MonthTab> {
  double needs = 0;
  double wants = 0;
  double savings = 0;
  int investmentAmount = 5000;
  int investmentProfile = 0;
  int? syncedMonth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFromRun();
  }

  @override
  void didUpdateWidget(covariant MonthTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFromRun();
  }

  void _syncFromRun() {
    final run = widget.state.run;
    if (run == null || syncedMonth == run.month) return;
    needs = run.currentPlan.mandatoryTotal.toDouble();
    wants = run.currentPlan.wants.toDouble();
    savings = run.currentPlan.savings.toDouble();
    final spendable = max(0.0, (run.balance - run.debtPaymentTotal).toDouble());
    _fitWithinBudget(spendable, changed: 'savings');
    syncedMonth = run.month;
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.state.run;
    if (run == null) return const SizedBox.shrink();
    final available = run.balance.toDouble();
    final reservedForDebts = run.debtPaymentTotal.toDouble();
    final spendable = max(0.0, available - reservedForDebts);
    final plan = _buildPlan();
    final overBudget = plan.total > spendable.round();
    final mandatoryMin = (run.currentIncome * 0.5).round();
    final freeCash = spendable.round() - plan.total;

    return _ScreenFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          GradientHeroCard(
            title: 'План на месяц ${run.month}',
            subtitle:
                'Сначала распределение по трем корзинам, затем запускается симуляция месяца.',
            trailing: _HeroBadge(text: '${run.currentIncome} ₽'),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Три корзины бюджета',
                  subtitle: 'Вместо россыпи ползунков — понятная верхнеуровневая модель.',
                ),
                const SizedBox(height: 14),
                _BudgetSliderCard(
                  title: 'Обязательные',
                  subtitle: 'Аренда, еда, транспорт, связь и коммунальные',
                  color: const Color(0xFF2F6D63),
                  value: needs,
                  max: spendable,
                  onChanged: (value) => setState(() {
                    needs = value;
                    _fitWithinBudget(spendable, changed: 'needs');
                  }),
                ),
                const SizedBox(height: 14),
                _BudgetSliderCard(
                  title: 'Желания',
                  subtitle: 'Развлечения, покупки и все, что делает месяц приятнее',
                  color: const Color(0xFFD97706),
                  value: wants,
                  max: spendable,
                  onChanged: (value) => setState(() {
                    wants = value;
                    _fitWithinBudget(spendable, changed: 'wants');
                  }),
                ),
                const SizedBox(height: 14),
                _BudgetSliderCard(
                  title: 'Накопления',
                  subtitle: 'Подушка безопасности и движение к цели',
                  color: const Color(0xFF4F46E5),
                  value: savings,
                  max: spendable,
                  onChanged: (value) => setState(() {
                    savings = value;
                    _fitWithinBudget(spendable, changed: 'savings');
                  }),
                ),
                const SizedBox(height: 14),
                _InfoLine(label: 'Баланс', value: '${available.round()} ₽'),
                const SizedBox(height: 8),
                _InfoLine(
                  label: 'Резерв на долги',
                  value: '${reservedForDebts.round()} ₽',
                ),
                const SizedBox(height: 8),
                _InfoLine(label: 'На план', value: '${plan.total} ₽'),
                const SizedBox(height: 8),
                _InfoLine(label: 'Останется', value: '$freeCash ₽'),
                if (overBudget) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'План превышает реально доступные деньги после обязательных выплат по долгам.',
                    style: TextStyle(color: Color(0xFFDC2626)),
                  ),
                ],
                if (plan.mandatoryTotal < mandatoryMin) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'На обязательные расходы заложено опасно мало.',
                    style: TextStyle(color: Color(0xFFD97706)),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Детализация обязательных',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PlanBreakdownLine(label: 'Аренда', value: plan.rent),
                      _PlanBreakdownLine(
                        label: 'Коммунальные',
                        value: plan.utilities,
                      ),
                      _PlanBreakdownLine(
                        label: 'Связь',
                        value: plan.communication,
                      ),
                      _PlanBreakdownLine(
                        label: 'Транспорт',
                        value: plan.transport,
                      ),
                      _PlanBreakdownLine(label: 'Еда', value: plan.food),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6D63),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (overBudget) return;
                    widget.state.updatePlan(plan);
                    await showActionFxDialog(
                      context,
                      title: 'План сохранен',
                      subtitle: 'Распределение бюджета обновлено.',
                      positive: true,
                    );
                  },
                  child: const Text('Сохранить распределение'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF111827),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: overBudget
                ? null
                : () async {
              widget.state.updatePlan(plan);
              if (!context.mounted) return;
              await showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => MonthSimulationDialog(state: widget.state),
              );
              if (!context.mounted) return;
              if (widget.state.isFinished) return;
              final report = await widget.state.closeCurrentMonth();
              if (!context.mounted || report == null) return;
              await showDialog<void>(
                context: context,
                builder: (_) => MonthReportDialog(report: report),
              );
              await widget.state.proceedNextMonth();
              _syncFromRun();
              if (mounted) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text('Подтвердить бюджет'),
          ),
        ],
      ),
    );
  }

  void _fitWithinBudget(double totalBudget, {required String changed}) {
    var overflow = needs + wants + savings - totalBudget;
    if (overflow <= 0) return;

    for (final bucket in ['needs', 'wants', 'savings']) {
      if (bucket == changed || overflow <= 0) continue;
      final current = _bucketValue(bucket);
      final reduce = min(current, overflow);
      _setBucketValue(bucket, current - reduce);
      overflow -= reduce;
    }

    if (overflow > 0) {
      _setBucketValue(changed, max(0, _bucketValue(changed) - overflow));
    }
  }

  double _bucketValue(String bucket) => switch (bucket) {
    'needs' => needs,
    'wants' => wants,
    _ => savings,
  };

  void _setBucketValue(String bucket, double value) {
    switch (bucket) {
      case 'needs':
        needs = value;
        break;
      case 'wants':
        wants = value;
        break;
      default:
        savings = value;
    }
  }

  MonthPlan _buildPlan() {
    final mandatory = needs.round();
    final rent = (mandatory * 0.42).round();
    final utilities = (mandatory * 0.14).round();
    final communication = (mandatory * 0.08).round();
    final transport = (mandatory * 0.12).round();
    final food = max(0, mandatory - rent - utilities - communication - transport);

    return MonthPlan(
      rent: rent,
      utilities: utilities,
      communication: communication,
      transport: transport,
      food: food,
      wants: wants.round(),
      savings: savings.round(),
    );
  }
}

class ShopTab extends StatelessWidget {
  const ShopTab({super.key, required this.state});

  final MoneyFlowState state;

  @override
  Widget build(BuildContext context) {
    final run = state.run;
    if (run == null) return const SizedBox.shrink();
    return _ScreenFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          GradientHeroCard(
            title: 'Магазин',
            subtitle: 'ФинКоины тратятся только на приятные бонусы.',
            trailing: _HeroBadge(text: '${run.finCoins} FC'),
          ),
          const SizedBox(height: 16),
          for (final item in shopItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SectionCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${item.description}\n${item.type}',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                  trailing: run.shopInventory.contains(item.id)
                      ? const Chip(label: Text('Куплено'))
                      : FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2F6D63),
                          ),
                          onPressed: run.finCoins >= item.cost
                              ? () async {
                                  await state.buyItem(item);
                                  if (!context.mounted) return;
                                  await showActionFxDialog(
                                    context,
                                    title: 'Покупка успешна',
                                    subtitle: item.title,
                                    positive: true,
                                  );
                                }
                              : null,
                          child: Text('${item.cost}'),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.state,
    required this.onOpenStats,
  });

  final MoneyFlowState state;
  final VoidCallback onOpenStats;

  @override
  Widget build(BuildContext context) {
    final run = state.run;
    if (run == null) return const SizedBox.shrink();

    return _ScreenFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          GradientHeroCard(
            title: 'Профиль и прогресс',
            subtitle: 'Краткая сводка по персонажу и служебные действия.',
            trailing: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              child: const Icon(Icons.person_outline, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Персонаж',
                  subtitle: 'Кто ты сейчас и как выглядит текущее положение.',
                ),
                const SizedBox(height: 14),
                _InfoLine(label: 'Имя', value: run.avatar.name),
                const SizedBox(height: 8),
                _InfoLine(
                  label: 'Профессия',
                  value: professionConfigs[run.avatar.profession]!.title,
                ),
                const SizedBox(height: 8),
                _InfoLine(label: 'Месяц', value: '${run.month}'),
                const SizedBox(height: 8),
                _InfoLine(label: 'Баланс', value: '${run.balance} ₽'),
                const SizedBox(height: 8),
                _InfoLine(label: 'Долги', value: run.debts.isEmpty ? 'Нет' : 'Есть'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.bar_chart_outlined,
                  title: 'Полная статистика',
                  subtitle: 'Доходы, расходы и персональные советы.',
                  onTap: onOpenStats,
                ),
                const Divider(height: 24),
                _ActionTile(
                  icon: Icons.refresh_rounded,
                  title: 'Начать заново',
                  subtitle: 'Сбросить текущее прохождение.',
                  iconColor: const Color(0xFFDC2626),
                  tileColor: const Color(0xFFFEF2F2),
                  onTap: () async => state.reset(),
                ),
              ],
            ),
          ),
          if (run.reports.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    title: 'Последние месяцы',
                    subtitle: 'Краткая лента результатов.',
                  ),
                  const SizedBox(height: 14),
                  for (final report in run.reports.take(5))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Месяц ${report.month}'),
                      subtitle: Text(
                        'Доход ${report.income} ₽ • Расход ${report.totalExpense} ₽',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      trailing: Text(
                        '${report.balanceEnd} ₽',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class QuizDialog extends StatefulWidget {
  const QuizDialog({super.key, required this.state});

  final MoneyFlowState state;

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {
  int? selected;
  bool submitted = false;
  bool result = false;

  @override
  Widget build(BuildContext context) {
    final quiz = widget.state.activeQuiz;
    if (quiz == null) {
      return const AlertDialog(content: Text('Квиз недоступен.'));
    }
    return AlertDialog(
      title: const Text('Челлендж от банка'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quiz.question),
            const SizedBox(height: 12),
            for (var i = 0; i < quiz.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: submitted ? null : () => setState(() => selected = i),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected == i
                          ? const Color(0xFFE7F2EF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected == i
                            ? const Color(0xFF2F6D63)
                            : const Color(0xFFD6DDE7),
                      ),
                    ),
                    child: Text(quiz.options[i]),
                  ),
                ),
              ),
            if (submitted) ...[
              const SizedBox(height: 10),
              Text(
                result
                    ? 'Верно! +20 ФинКоинов'
                    : 'Не совсем так, но +5 ФинКоинов за попытку',
                style: TextStyle(
                  color: result ? const Color(0xFF2F6D63) : const Color(0xFFD97706),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(quiz.explanation),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
        if (!submitted)
          FilledButton(
            onPressed: selected == null
                ? null
                : () async {
                    final isCorrect = await widget.state.answerQuiz(selected!);
                    setState(() {
                      submitted = true;
                      result = isCorrect;
                    });
                  },
            child: const Text('Ответить'),
          ),
      ],
    );
  }
}

class MonthReportDialog extends StatelessWidget {
  const MonthReportDialog({super.key, required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Итоги месяца ${report.month}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoLine(label: 'Доход', value: '${report.income} ₽'),
            const SizedBox(height: 8),
            _InfoLine(label: 'Расход', value: '${report.totalExpense} ₽'),
            const SizedBox(height: 8),
            _InfoLine(label: 'Остаток', value: '${report.balanceEnd} ₽'),
            const SizedBox(height: 8),
            _InfoLine(
              label: 'Энергия',
              value: report.energyDelta >= 0
                  ? '+${report.energyDelta}'
                  : '${report.energyDelta}',
            ),
            const SizedBox(height: 8),
            _InfoLine(
              label: 'Счастье',
              value: report.happinessDelta >= 0
                  ? '+${report.happinessDelta}'
                  : '${report.happinessDelta}',
            ),
            if (report.notes.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Что произошло',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              for (final note in report.notes.take(4)) Text('• $note'),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Дальше'),
        ),
      ],
    );
  }
}

class MonthSimulationDialog extends StatefulWidget {
  const MonthSimulationDialog({super.key, required this.state});

  final MoneyFlowState state;

  @override
  State<MonthSimulationDialog> createState() => _MonthSimulationDialogState();
}

class _MonthSimulationDialogState extends State<MonthSimulationDialog> {
  late final List<LifeEvent> events;
  late final List<int> days;
  int index = 0;
  bool quietMonth = false;

  @override
  void initState() {
    super.initState();
    final run = widget.state.run;
    events = run == null ? [] : List<LifeEvent>.from(run.eventQueue);
    if (events.isEmpty) {
      quietMonth = true;
      days = [_randomDay()];
    } else {
      days = List<int>.generate(events.length, (_) => _randomDay())..sort();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = quietMonth || index >= events.length;
    return Dialog.fullscreen(
      backgroundColor: Colors.black.withValues(alpha: 0.68),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(28),
            ),
            child: isDone ? _buildDoneStep(context) : _buildEventStep(context),
          ).animate().fadeIn(duration: 220.ms).scale(begin: const Offset(0.96, 0.96)),
        ),
      ),
    );
  }

  Widget _buildEventStep(BuildContext context) {
    final event = events[index];
    final day = days[index];
    final run = widget.state.run;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DayBadge(day: day),
        const SizedBox(height: 16),
        Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          event.description,
          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        if (run != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF374151)),
            ),
            child: Column(
              children: [
                _DarkInfoLine(label: 'Баланс', value: '${run.balance} ₽'),
                const SizedBox(height: 8),
                _DarkInfoLine(
                  label: 'На цель',
                  value: '${run.goal.savedAmount} / ${run.goal.targetAmount} ₽',
                ),
                const SizedBox(height: 8),
                _DarkInfoLine(label: 'ФинКоины', value: '${run.finCoins} FC'),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
        for (final choice in event.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF374151)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await widget.state.applyEventChoice(choice);
                widget.state.run?.eventQueue.removeWhere((item) => item.id == event.id);
                if (!context.mounted) return;
                if (widget.state.isFinished) {
                  Navigator.of(context).pop();
                  return;
                }
                setState(() => index += 1);
              },
              child: Row(
                children: [
                  Expanded(child: Text(choice.title)),
                  const SizedBox(width: 12),
                  Text(
                    choice.cost == 0 ? '0 ₽' : '-${choice.cost} ₽',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: run != null && choice.cost > run.balance
                          ? const Color(0xFFFCA5A5)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDoneStep(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DayBadge(day: quietMonth ? days.first : 30),
        const SizedBox(height: 18),
        const Icon(
          Icons.nights_stay_rounded,
          color: Colors.white,
          size: 42,
        ),
        const SizedBox(height: 16),
        Text(
          quietMonth ? 'Спокойный месяц' : 'Месяц завершен',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          quietMonth
              ? 'В этот раз обошлось без происшествий. Можно подвести итог месяца.'
              : 'Все ключевые события пройдены. Пора смотреть отчет.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFD1D5DB), height: 1.45),
        ),
        const SizedBox(height: 22),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2F6D63),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Показать отчет'),
        ),
      ],
    );
  }

  int _randomDay() => 1 + Random().nextInt(31);
}

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key, required this.state});

  final MoneyFlowState state;

  @override
  Widget build(BuildContext context) {
    final run = state.run;
    final terms = run == null ? <String>[] : (run.glossary.toList()..sort());
    return Scaffold(
      appBar: AppBar(title: const Text('ФинСловарь')),
      body: MoneyFlowBackground(
        child: _ScreenFrame(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const GradientHeroCard(
                title: 'ФинСловарь',
                subtitle: 'Простые объяснения терминов без выхода в отдельные меню.',
              ),
              const SizedBox(height: 16),
              for (final term in terms)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          glossaryData[term] ?? 'Описание будет добавлено позже.',
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.state});

  final MoneyFlowState state;

  @override
  Widget build(BuildContext context) {
    final run = state.run;
    if (run == null) return const SizedBox.shrink();
    final stats = run.stats;

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика и советы')),
      body: MoneyFlowBackground(
        child: _ScreenFrame(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                      title: 'Главные цифры',
                      subtitle: 'Короткий и понятный свод по прохождению.',
                    ),
                    const SizedBox(height: 14),
                    _InfoLine(label: 'Месяцев сыграно', value: '${run.month}'),
                    const SizedBox(height: 8),
                    _InfoLine(label: 'Общий доход', value: '${stats.totalIncome} ₽'),
                    const SizedBox(height: 8),
                    _InfoLine(
                      label: 'Общие расходы',
                      value: '${stats.totalExpenses} ₽',
                    ),
                    const SizedBox(height: 8),
                    _InfoLine(label: 'Кредитов взято', value: '${stats.creditsTaken}'),
                    const SizedBox(height: 8),
                    _InfoLine(
                      label: 'Квизы',
                      value: '${stats.quizCorrect}/${stats.quizzesTaken}',
                    ),
                    const SizedBox(height: 8),
                    _InfoLine(
                      label: 'Инвестиции',
                      value: '${stats.investmentsDone}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(
                      title: 'Персональный совет',
                      subtitle: 'Что можно улучшить в следующем цикле.',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _personalAdvice(run),
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _personalAdvice(GameRun run) {
    final stats = run.stats;
    if (stats.wantsExpenses > stats.savingsExpenses * 2) {
      return 'Ты часто выбираешь потребление вместо накоплений. Попробуй фиксировать сумму накоплений в самом начале месяца, а не откладывать остаток.';
    }
    if (stats.creditsTaken > 2 && run.debts.isNotEmpty) {
      return 'Долговая нагрузка высока. Лучший следующий шаг — перестать брать новые кредиты и сначала облегчить ежемесячные платежи.';
    }
    if (stats.quizCorrect < max(1, stats.quizzesTaken ~/ 2)) {
      return 'Теория пока помогает не в полной мере. Регулярные квизы и словарь дадут заметно более уверенные решения в событиях.';
    }
    return 'Динамика хорошая. Следующая сильная цель — довести подушку безопасности до 6 месяцев обязательных расходов.';
  }
}

class _ScreenFrame extends StatelessWidget {
  const _ScreenFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF6B7280), height: 1.4),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2F6D63).withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'День $day',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DarkInfoLine extends StatelessWidget {
  const _DarkInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

enum _Tone { good, warn, bad }

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.tone});

  final String label;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _Tone.good => const Color(0xFF2F6D63),
      _Tone.warn => const Color(0xFFD97706),
      _Tone.bad => const Color(0xFFDC2626),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({required this.debt});

  final Debt debt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            debt.name,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _InfoLine(label: 'Осталось', value: '${debt.principalLeft} ₽'),
          const SizedBox(height: 6),
          _InfoLine(label: 'Платеж в месяц', value: '${debt.monthlyPayment} ₽'),
        ],
      ),
    );
  }
}

class _BudgetSliderCard extends StatelessWidget {
  const _BudgetSliderCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final Color color;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.round()} ₽',
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Slider(
            value: value.clamp(0, max <= 0 ? 1 : max),
            min: 0,
            max: max <= 0 ? 1 : max,
            divisions: 50,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PlanBreakdownLine extends StatelessWidget {
  const _PlanBreakdownLine({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            '$value ₽',
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = const Color(0xFF2F6D63),
    this.tileColor = const Color(0xFFF3F6FA),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color tileColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
