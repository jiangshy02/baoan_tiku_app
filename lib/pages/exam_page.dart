import 'package:flutter/material.dart';
import '../models/question.dart';
import '../widgets/question_card.dart';

class ExamPage extends StatefulWidget {
  final TikuData tiku;
  final String mode; // 'all' | 'single' | 'multi' | 'judge' | 'wrong'
  final List<int>? wrongIds;

  const ExamPage({
    super.key,
    required this.tiku,
    this.mode = 'all',
    this.wrongIds,
  });

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  late List<Question> _questions;
  int _currentIndex = 0;
  final Map<int, String> _answers = {};
  bool _showResult = false;
  int _correctCount = 0;
  int _wrongCount = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _filterQuestions();
  }

  void _filterQuestions() {
    if (widget.mode == 'wrong' && widget.wrongIds != null) {
      _questions = widget.tiku.questions
          .where((q) => widget.wrongIds!.contains(q.id))
          .toList();
    } else if (widget.mode == 'single') {
      _questions =
          widget.tiku.questions.where((q) => q.isSingle).toList();
    } else if (widget.mode == 'multi') {
      _questions =
          widget.tiku.questions.where((q) => q.isMulti).toList();
    } else if (widget.mode == 'judge') {
      _questions =
          widget.tiku.questions.where((q) => q.isJudge).toList();
    } else {
      _questions = List.from(widget.tiku.questions);
    }
  }

  void _submitAll() {
    int correct = 0;
    int wrong = 0;
    for (final q in _questions) {
      final userAns = _answers[q.id] ?? '';
      if (userAns.isEmpty) {
        wrong++;
        continue;
      }
      if (q.isMulti) {
        final sortedUser = userAns.split('')..sort();
        final sortedCorrect = q.answer.split('')..sort();
        if (sortedUser.join('') == sortedCorrect.join('')) {
          correct++;
        } else {
          wrong++;
        }
      } else {
        if (userAns == q.answer) {
          correct++;
        } else {
          wrong++;
        }
      }
    }

    setState(() {
      _showResult = true;
      _correctCount = correct;
      _wrongCount = wrong;
    });
  }

  void _reset() {
    setState(() {
      _answers.clear();
      _currentIndex = 0;
      _showResult = false;
      _correctCount = 0;
      _wrongCount = 0;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final progress = '${_currentIndex + 1} / ${_questions.length}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == 'single'
              ? '单选题练习'
              : widget.mode == 'multi'
                  ? '多选题练习'
                  : widget.mode == 'judge'
                      ? '判断题练习'
                      : widget.mode == 'wrong'
                          ? '错题重做'
                          : widget.mode == 'exam'
                              ? '模拟考试'
                              : '全部题库',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_showResult)
            TextButton.icon(
              onPressed: _submitAll,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('交卷', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / _questions.length,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        _showResult
                            ? ( _correctCount >= _wrongCount
                                ? Colors.green : Colors.orange)
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(progress,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700)),
              ],
            ),
          ),

          // Result banner
          if (_showResult)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: _correctCount >= _questions.length * 0.6
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '正确 $_correctCount 题',
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '错误 $_wrongCount 题',
                    style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '正确率 ${_questions.length > 0 ? (_correctCount / _questions.length * 100).toStringAsFixed(1) : 0}%',
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14),
                  ),
                ],
              ),
            ),

          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: QuestionCard(
                    key: ValueKey('q_${question.id}_${_answers[question.id]}'),
                    question: question,
                    selectedAnswer: _answers[question.id],
                    showResult: _showResult,
                    onAnswerChanged: (ans) {
                      setState(() {
                        if (ans == null || ans.isEmpty) {
                          _answers.remove(question.id);
                        } else {
                          _answers[question.id] = ans;
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('上一题'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _currentIndex < _questions.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('下一题'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
