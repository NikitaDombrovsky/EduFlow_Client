import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/app/ui_kit/app_snackbar.dart';
import 'package:friflex_starter/features/material_builder/domain/bloc/material_builder_bloc.dart';

/// {@template TextPreviewScreen}
/// Экран предварительного просмотра и редактирования текста перед AI-обработкой
///
/// Отвечает за:
/// - Отображение загруженного текста
/// - Редактирование текста перед обработкой
/// - Статистику по тексту (символы, слова, строки)
/// - Отправку на AI-обработку
/// {@endtemplate}
class TextPreviewScreen extends StatefulWidget {
  /// {@macro TextPreviewScreen}
  const TextPreviewScreen({
    required this.documentId,
    required this.initialText,
    required this.fileName,
    super.key,
  });

  /// Идентификатор документа
  final String documentId;

  /// Исходный текст
  final String initialText;

  /// Название файла
  final String fileName;

  @override
  State<TextPreviewScreen> createState() => _TextPreviewScreenState();
}

class _TextPreviewScreenState extends State<TextPreviewScreen> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _hasChanges = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_textController.text != widget.initialText) {
      if (!_hasChanges) {
        setState(() => _hasChanges = true);
      }
    } else {
      if (_hasChanges) {
        setState(() => _hasChanges = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges || _isProcessing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges && !_isProcessing) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Проверка текста'),
              Text(
                widget.fileName,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _resetText,
                tooltip: 'Вернуть исходный текст',
              ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Копировать текст',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatisticsBar(),
            Expanded(
              child: _buildTextEditor(),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  /// Статистика по тексту
  Widget _buildStatisticsBar() {
    final text = _textController.text;
    final charCount = text.length;
    final wordCount = text.trim().isEmpty
        ? 0
        : text.trim().split(RegExp(r'\s+')).length;
    final lineCount = text.isEmpty ? 0 : '\n'.allMatches(text).length + 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.text_fields,
            label: 'Символов',
            value: charCount.toString(),
          ),
          const WBox(24),
          _StatItem(
            icon: Icons.article_outlined,
            label: 'Слов',
            value: wordCount.toString(),
          ),
          const WBox(24),
          _StatItem(
            icon: Icons.format_list_numbered,
            label: 'Строк',
            value: lineCount.toString(),
          ),
          const Spacer(),
          if (_hasChanges)
            Chip(
              avatar: const Icon(Icons.edit, size: 16),
              label: const Text('Изменен'),
              backgroundColor: Colors.orange.shade100,
              labelStyle: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade800,
              ),
            ),
        ],
      ),
    );
  }

  /// Редактор текста
  Widget _buildTextEditor() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: [
          // Основной редактор
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: 16,
                  ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Введите или вставьте текст для обработки...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // Плавающая панель форматирования
          if (_focusNode.hasFocus)
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildFormattingPanel(),
            ),
        ],
      ),
    );
  }

  /// Панель форматирования
  Widget _buildFormattingPanel() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.format_clear),
              onPressed: _clearFormatting,
              tooltip: 'Очистить форматирование',
              iconSize: 20,
            ),
            const VerticalDivider(width: 1),
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: 'Выделить все',
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Нижняя панель с действиями
  Widget _buildBottomBar() {
    final text = _textController.text.trim();
    final isValid = text.isNotEmpty && text.length >= 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isValid) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const WBox(12),
                    Expanded(
                      child: Text(
                        text.isEmpty
                            ? 'Добавьте текст для обработки'
                            : 'Минимум 10 символов для обработки',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const HBox(12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Назад'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const WBox(12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isValid && !_isProcessing ? _processText : null,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isProcessing ? 'Обработка...' : 'Обработать с ИИ',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Обрабатывает текст через AI
  Future<void> _processText() async {
    final text = _textController.text.trim();

    if (text.isEmpty || text.length < 10) {
      AppSnackBar.showError(
        context,
        message: 'Текст слишком короткий для обработки',
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Отправляем на обработку
      context.read<MaterialBuilderBloc>().add(
            MaterialBuilderProcessDocumentEvent(
              documentId: widget.documentId,
              content: text,
            ),
          );

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(
          context: context,
          message: 'Текст отправлен на обработку',
        );
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        AppSnackBar.showError(
          context,
          message: 'Ошибка при обработке: $e',
        );
      }
    }
  }

  /// Сбрасывает текст к исходному
  void _resetText() {
    setState(() {
      _textController.text = widget.initialText;
      _hasChanges = false;
    });
    AppSnackBar.showInfo(
      context,
      message: 'Текст возвращен к исходному',
    );
  }

  /// Копирует текст в буфер обмена
  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (mounted) {
      AppSnackBar.showSuccess(
        context: context,
        message: 'Текст скопирован в буфер обмена',
      );
    }
  }

  /// Очищает форматирование (удаляет лишние пробелы и переносы)
  void _clearFormatting() {
    final text = _textController.text;
    final cleaned = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n');

    setState(() {
      _textController.text = cleaned;
    });

    AppSnackBar.showInfo(
      context,
      message: 'Форматирование очищено',
    );
  }

  /// Выделяет весь текст
  void _selectAll() {
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.text.length,
    );
  }

  /// Показывает диалог подтверждения выхода
  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Несохраненные изменения'),
        content: const Text(
          'Вы изменили текст. Выйти без обработки?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// {@template StatItem}
/// Элемент статистики
/// {@endtemplate}
class _StatItem extends StatelessWidget {
  /// {@macro StatItem}
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  /// Иконка
  final IconData icon;

  /// Название
  final String label;

  /// Значение
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const WBox(4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
