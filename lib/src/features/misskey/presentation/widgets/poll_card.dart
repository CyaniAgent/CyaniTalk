import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '/src/features/misskey/domain/poll.dart';
import '/src/features/misskey/data/misskey_repository.dart';
import '/src/features/misskey/application/misskey_notifier.dart';
import '/src/core/utils/logger.dart';
import '/src/shared/extensions/ui_extensions.dart';

/// 投票卡片组件
/// 
/// 用于在笔记中显示投票选项和结果，具有日系次元化动效。
class PollCard extends ConsumerStatefulWidget {
  final String noteId;
  final PollResult poll;
  final String? timelineType;

  const PollCard({
    super.key,
    required this.noteId,
    required this.poll,
    this.timelineType,
  });

  @override
  ConsumerState<PollCard> createState() => _PollCardState();
}

class _PollCardState extends ConsumerState<PollCard> {
  bool _isVoting = false;
  final Map<int, bool> _selectedChoices = {};

  @override
  void initState() {
    super.initState();
    // 如果已投票，记录已选中的选项
    for (int i = 0; i < widget.poll.choices.length; i++) {
      if (widget.poll.choices[i].isVoted) {
        _selectedChoices[i] = true;
      }
    }
  }

  bool get _hasVoted => widget.poll.choices.any((c) => c.isVoted);
  bool get _isExpired => widget.poll.expiresAt != null && 
                         widget.poll.expiresAt!.isBefore(DateTime.now());
  bool get _showResults => _hasVoted || _isExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poll = widget.poll;
    
    // Miku Green 及其变体
    const mikuGreen = Color(0xFF39C5BB);
    final mikuGreenSoft = mikuGreen.withValues(alpha: 0.2);

    Widget cardBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...poll.choices.asMap().entries.map((entry) {
          final index = entry.key;
          final choice = entry.value;
          final totalVotes = poll.votesCount;
          final percentage = totalVotes > 0 ? (choice.votes / totalVotes) : 0.0;
          
          return _buildChoiceRow(
            index: index,
            choice: choice,
            percentage: percentage,
            mikuGreen: mikuGreen,
            mikuGreenSoft: mikuGreenSoft,
            theme: theme,
          );
        }),
        
        _buildFooter(theme),
      ],
    );

    // 如果是单选且可以投票，使用 RadioGroup 包装
    if (!_showResults && !widget.poll.multiple) {
      cardBody = RadioGroup<int>(
        groupValue: _selectedChoices.keys.firstOrNull,
        onChanged: (int? val) {
          if (_isVoting || val == null) return;
          setState(() {
            _selectedChoices.clear();
            _selectedChoices[val] = true;
          });
        },
        child: cardBody,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: cardBody,
    );
  }

  Widget _buildChoiceRow({
    required int index,
    required PollChoiceResult choice,
    required double percentage,
    required Color mikuGreen,
    required Color mikuGreenSoft,
    required ThemeData theme,
  }) {
    final isSelected = _selectedChoices[index] ?? false;
    final canVote = !_showResults && !_isVoting;

    return InkWell(
      onTap: canVote ? () => _handleVote(index) : null,
      child: Stack(
        children: [
          // 进度条背景 (结果显示模式下)
          if (_showResults)
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  color: choice.isVoted ? mikuGreenSoft : theme.colorScheme.surfaceContainerHighest,
                ).animate().shimmer(
                  duration: 1500.ms,
                  color: mikuGreen.withValues(alpha: 0.1),
                ),
              ).animate().custom(
                duration: 800.ms,
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value * percentage,
                    child: child,
                  );
                },
              ),
            ),

          // 内容层
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 投票指示器
                if (!_showResults)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: widget.poll.multiple
                          ? Checkbox(
                              value: isSelected,
                              onChanged: _isVoting ? null : (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedChoices[index] = true;
                                  } else {
                                    _selectedChoices.remove(index);
                                  }
                                });
                              },
                              activeColor: mikuGreen,
                            )
                          : Radio<int>(
                              value: index,
                              activeColor: mikuGreen,
                            ),
                    ),
                  ),
                
                // 选项文本
                Expanded(
                  child: Text(
                    choice.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: choice.isVoted ? FontWeight.bold : FontWeight.normal,
                      color: choice.isVoted ? mikuGreen : theme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // 百分比和票数 (结果显示模式下)
                if (_showResults)
                  _buildResultInfo(choice, percentage, mikuGreen, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfo(PollChoiceResult choice, double percentage, Color mikuGreen, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (choice.isVoted)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.check_circle, size: 16, color: mikuGreen),
          ),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: choice.isVoted ? mikuGreen : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${choice.votes})',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final poll = widget.poll;
    String expiresText = '';
    if (poll.expiresAt != null) {
      if (_isExpired) {
        expiresText = 'poll_expired'.tr();
      } else {
        final remaining = poll.expiresAt!.difference(DateTime.now());
        if (remaining.inDays > 0) {
          expiresText = 'poll_ends_in_days'.tr(args: [remaining.inDays.toString()]);
        } else if (remaining.inHours > 0) {
          expiresText = 'poll_ends_in_hours'.tr(args: [remaining.inHours.toString()]);
        } else {
          expiresText = 'poll_ends_soon'.tr();
        }
      }
    } else {
      expiresText = 'poll_permanent'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'poll_total_votes'.tr(args: [poll.votesCount.toString()]),
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          Text(
            expiresText,
            style: TextStyle(
              fontSize: 11,
              color: _isExpired ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
            ),
          ),

          if (!_showResults && widget.poll.multiple && _selectedChoices.isNotEmpty)
            TextButton(
              onPressed: _isVoting ? null : _handleMultipleVote,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: _isVoting 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('poll_submit'.tr()),
            ),
        ],
      ),
    );
  }

  Future<void> _handleVote(int index) async {
    if (widget.poll.multiple) {
      setState(() {
        final current = _selectedChoices[index] ?? false;
        if (current) {
          _selectedChoices.remove(index);
        } else {
          _selectedChoices[index] = true;
        }
      });
      return;
    }

    // 单选直接投票
    _submitVote([index]);
  }

  Future<void> _handleMultipleVote() async {
    final indices = _selectedChoices.keys.toList();
    if (indices.isEmpty) return;
    _submitVote(indices);
  }

  Future<void> _submitVote(List<int> indices) async {
    setState(() => _isVoting = true);
    try {
      final repository = await ref.read(misskeyRepositoryProvider.future);
      
      // Misskey 投票 API 通常一个一个投
      for (final index in indices) {
        await repository.votePoll(widget.noteId, index);
      }

      // 刷新笔记以获取最新投票结果
      final updatedNote = await repository.getNote(widget.noteId);
      
      // 触发 UI 更新
      if (widget.timelineType != null) {
        ref.read(misskeyTimelineProvider(widget.timelineType!).notifier).updateNote(updatedNote);
      } else {
        MisskeyTimelineNotifier.cacheManager.putNote(updatedNote);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showTopSnackBar(
          SnackBar(content: Text('poll_voted_successfully'.tr()), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      logger.error('Error voting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showTopSnackBar(
          SnackBar(content: Text('poll_vote_failed'.tr(namedArgs: {'error': e.toString()})), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }
}
