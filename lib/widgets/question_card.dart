import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final String? selectedAnswer;
  final bool showResult;
  final ValueChanged<String?> onAnswerChanged;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.showResult = false,
    required this.onAnswerChanged,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  Set<String> _multiSelected = {};
  String? _singleSelected;

  @override
  void initState() {
    super.initState();
    _singleSelected = widget.selectedAnswer;
    if (widget.selectedAnswer != null && widget.selectedAnswer!.length > 1) {
      _multiSelected = widget.selectedAnswer!.split('').toSet();
    }
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswer != oldWidget.selectedAnswer) {
      _singleSelected = widget.selectedAnswer;
      if (widget.selectedAnswer != null && widget.selectedAnswer!.length > 1) {
        _multiSelected = widget.selectedAnswer!.split('').toSet();
      }
    }
  }

  Color _getOptionColor(String label) {
    if (!widget.showResult) {
      if (widget.question.isMulti) {
        return _multiSelected.contains(label)
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade200;
      }
      return _singleSelected == label
          ? Theme.of(context).colorScheme.primary
          : Colors.grey.shade200;
    }

    // Show result mode
    final isCorrect = widget.question.answer.contains(label);
    final isSelected = widget.question.isMulti
        ? _multiSelected.contains(label)
        : _singleSelected == label;

    if (isSelected && isCorrect) return Colors.green;
    if (isSelected && !isCorrect) return Colors.red;
    if (isCorrect) return Colors.green.shade100;
    return Colors.grey.shade200;
  }

  Color _getOptionTextColor(String label) {
    if (!widget.showResult) {
      if (widget.question.isMulti) {
        return _multiSelected.contains(label) ? Colors.white : Colors.black87;
      }
      return _singleSelected == label ? Colors.white : Colors.black87;
    }

    final isCorrect = widget.question.answer.contains(label);
    final isSelected = widget.question.isMulti
        ? _multiSelected.contains(label)
        : _singleSelected == label;

    if (isSelected || isCorrect) return Colors.white;
    return Colors.black87;
  }

  IconData? _getOptionIcon(String label) {
    if (!widget.showResult) return null;

    final isCorrect = widget.question.answer.contains(label);
    final isSelected = widget.question.isMulti
        ? _multiSelected.contains(label)
        : _singleSelected == label;

    if (isSelected && isCorrect) return Icons.check_circle;
    if (isSelected && !isCorrect) return Icons.cancel;
    if (isCorrect) return Icons.check_circle_outline;
    return null;
  }

  void _onTapOption(String label) {
    if (widget.showResult) return;

    setState(() {
      if (widget.question.isMulti) {
        if (_multiSelected.contains(label)) {
          _multiSelected.remove(label);
        } else {
          _multiSelected.add(label);
        }
        final answer = _multiSelected.toList()..sort();
        widget.onAnswerChanged(answer.join(''));
      } else {
        _singleSelected = _singleSelected == label ? null : label;
        widget.onAnswerChanged(_singleSelected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final typeLabel = q.isSingle ? '单选题' : q.isMulti ? '多选题' : '判断题';

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: q.isSingle
                        ? Colors.blue
                        : q.isMulti
                            ? Colors.orange
                            : Colors.purple,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    typeLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '第 ${q.id} 题',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '${q.options.length}个选项',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              q.question,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w500, height: 1.5),
            ),
            const SizedBox(height: 16),
            ...q.options.asMap().entries.map((entry) {
              final i = entry.key;
              final opt = entry.value;
              final color = _getOptionColor(opt.label);
              final textColor = _getOptionTextColor(opt.label);
              final icon = _getOptionIcon(opt.label);

              return Padding(
                padding: EdgeInsets.only(bottom: i < q.options.length - 1 ? 8 : 0),
                child: InkWell(
                  onTap: () => _onTapOption(opt.label),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.showResult
                            ? (widget.question.answer.contains(opt.label)
                                ? Colors.green
                                : color)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.question.isMulti
                                ? Colors.white.withAlpha(200)
                                : Colors.transparent,
                            border: widget.question.isMulti
                                ? null
                                : Border.all(
                                    color: _singleSelected == opt.label
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                    width: 2),
                          ),
                          child: widget.question.isMulti
                              ? Center(
                                  child: Checkbox(
                                    value: _multiSelected.contains(opt.label),
                                    onChanged: null,
                                    fillColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    checkColor: Colors.green,
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _singleSelected == opt.label
                                          ? Colors.white
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${opt.label}. ${opt.text}',
                            style: TextStyle(
                                fontSize: 15,
                                color: textColor,
                                height: 1.3),
                          ),
                        ),
                        if (icon != null)
                          Icon(icon, color: textColor, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (widget.showResult) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isCorrect() ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isCorrect() ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect() ? Icons.check_circle : Icons.info,
                      color: _isCorrect() ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isCorrect()
                            ? '回答正确！✓'
                            : '正确答案：${widget.question.answer}',
                        style: TextStyle(
                          color:
                              _isCorrect() ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isCorrect() {
    final ans = widget.selectedAnswer ?? '';
    if (widget.question.isMulti) {
      final sorted = ans.split('')..sort();
      final correct = widget.question.answer.split('')..sort();
      return sorted.join('') == correct.join('');
    }
    return ans == widget.question.answer;
  }
}
