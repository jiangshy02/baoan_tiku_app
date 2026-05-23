import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';
import 'exam_page.dart';

class HomePage extends StatefulWidget {
  final TikuData tiku;

  const HomePage({super.key, required this.tiku});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final tiku = widget.tiku;
    final singleCount = tiku.questions.where((q) => q.isSingle).length;
    final multiCount = tiku.questions.where((q) => q.isMulti).length;
    final judgeCount = tiku.questions.where((q) => q.isJudge).length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '国家保安员资格考试',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '题库练习 · 共${tiku.total}题',
                      style: TextStyle(
                          color: Colors.white.withAlpha(200), fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    // Stat cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatCard(
                          label: '单选',
                          count: singleCount,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: '多选',
                          count: multiCount,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: '判断',
                          count: judgeCount,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '练习模式',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '选择题目类型开始刷题',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          children: [
                            _ModeCard(
                              icon: Icons.assignment,
                              title: '模拟考试',
                              subtitle: '60单选+20多选+20判断',
                              color: Colors.deepOrange,
                              count: 100,
                              onTap: () => _startSimulatedExam(context),
                            ),
                            _ModeCard(
                              icon: Icons.quiz_outlined,
                              title: '全部随机',
                              subtitle: '混合练习',
                              color: Colors.blue,
                              count: tiku.total,
                              onTap: () => _startExam(context, 'all'),
                            ),
                            _ModeCard(
                              icon: Icons.radio_button_checked,
                              title: '单选题',
                              subtitle: '60题随机练习',
                              color: Colors.blue.shade300,
                              count: singleCount,
                              onTap: () => _startExam(context, 'single'),
                            ),
                            _ModeCard(
                              icon: Icons.check_box,
                              title: '多选题',
                              subtitle: '20题随机练习',
                              color: Colors.orange,
                              count: multiCount,
                              onTap: () => _startExam(context, 'multi'),
                            ),
                            _ModeCard(
                              icon: Icons.thumbs_up_down,
                              title: '判断题',
                              subtitle: '20题随机练习',
                              color: Colors.purple,
                              count: judgeCount,
                              onTap: () => _startExam(context, 'judge'),
                            ),
                          ],
                        ),
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

  void _startSimulatedExam(BuildContext context) {
    // Build a simulated exam: 60 single + 20 multi + 20 judge randomly sampled
    final rng = DateTime.now().microsecondsSinceEpoch;
    final random = Random(rng);

    final singles = widget.tiku.questions.where((q) => q.isSingle).toList()..shuffle(random);
    final multis = widget.tiku.questions.where((q) => q.isMulti).toList()..shuffle(random);
    final judges = widget.tiku.questions.where((q) => q.isJudge).toList()..shuffle(random);

    final sampled = <Question>[
      ...singles.take(60),
      ...multis.take(20),
      ...judges.take(20),
    ];

    final simulatedTiku = TikuData(
      title: '模拟考试（${sampled.length}题）',
      total: sampled.length,
      questions: sampled,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ExamPage(tiku: simulatedTiku, mode: 'exam')),
    );
  }

  void _startExam(BuildContext context, String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamPage(tiku: widget.tiku, mode: mode),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(80),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count题',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: Colors.white.withAlpha(200), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
