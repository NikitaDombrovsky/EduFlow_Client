import 'package:flutter/material.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/features/material_builder/domain/entity/material_template_entity.dart';

/// {@template FragmentEditorCard}
/// Карточка редактирования фрагмента материала
///
/// Отвечает за:
/// - Отображение и редактирование содержимого фрагмента
/// - Изменение типа и заголовка
/// - Удаление фрагмента
/// {@endtemplate}
class FragmentEditorCard extends StatefulWidget {
  /// {@macro FragmentEditorCard}
  const FragmentEditorCard({
    required this.fragment,
    required this.onUpdate,
    required this.onDelete,
    super.key,
  });

  /// Фрагмент для редактирования
  final MaterialTemplateEntity fragment;

  /// Колбек при обновлении фрагмента
  final void Function(MaterialTemplateEntity) onUpdate;

  /// Колбек при удалении фрагмента
  final VoidCallback onDelete;

  @override
  State<FragmentEditorCard> createState() => _FragmentEditorCardState();
}

class _FragmentEditorCardState extends State<FragmentEditorCard> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late MaterialTemplateType _selectedType;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.fragment.title ?? '');
    _contentController = TextEditingController(text: widget.fragment.content);
    _selectedType = widget.fragment.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок карточки
          ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drag_handle,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const WBox(8),
                _TypeIcon(type: _selectedType),
              ],
            ),
            title: Text(
              _titleController.text.isEmpty
                  ? _getTypeLabel(_selectedType)
                  : _titleController.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${_contentController.text.length} символов',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _showDeleteConfirmation,
                ),
              ],
            ),
          ),

          // Развернутое содержимое
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Выбор типа
                  Text(
                    'Тип фрагмента:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const HBox(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: MaterialTemplateType.values.map((type) {
                      return ChoiceChip(
                        avatar: _TypeIcon(type: type, size: 16),
                        label: Text(_getTypeLabel(type)),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = type);
                            _notifyUpdate();
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const HBox(16),

                  // Заголовок
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Заголовок (опционально)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _notifyUpdate(),
                  ),
                  const HBox(16),

                  // Содержимое
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Содержимое',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      helperText: _getHelperText(),
                      helperMaxLines: 2,
                    ),
                    maxLines: _selectedType == MaterialTemplateType.example ? 15 : 8,
                    minLines: 5,
                    onChanged: (_) => _notifyUpdate(),
                  ),

                  // Дополнительные поля для примеров кода
                  if (_selectedType == MaterialTemplateType.example) ...[
                    const HBox(12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Язык программирования (опционально)',
                        border: OutlineInputBorder(),
                        isDense: true,
                        hintText: 'dart, python, javascript...',
                      ),
                      onChanged: (_) => _notifyUpdate(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Уведомляет родителя об обновлении
  void _notifyUpdate() {
    final updated = widget.fragment.copyWith(
      type: _selectedType,
      title: _titleController.text.isEmpty ? null : _titleController.text,
      content: _contentController.text,
      isEdited: true,
    );
    widget.onUpdate(updated);
  }

  /// Показывает диалог подтверждения удаления
  Future<void> _showDeleteConfirmation() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить фрагмент?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      widget.onDelete();
    }
  }

  /// Возвращает подсказку в зависимости от типа
  String _getHelperText() {
    return switch (_selectedType) {
      MaterialTemplateType.theory =>
        'Теоретический материал, объяснения, определения',
      MaterialTemplateType.example =>
        'Пример кода с пояснениями',
      MaterialTemplateType.task =>
        'Практическое задание для студентов',
      MaterialTemplateType.visualization =>
        'Описание схемы, диаграммы или визуализации',
    };
  }

  /// Возвращает текстовую метку типа
  String _getTypeLabel(MaterialTemplateType type) {
    return switch (type) {
      MaterialTemplateType.theory => 'Теория',
      MaterialTemplateType.example => 'Пример',
      MaterialTemplateType.task => 'Задание',
      MaterialTemplateType.visualization => 'Визуализация',
    };
  }
}

/// {@template TypeIcon}
/// Иконка типа фрагмента
/// {@endtemplate}
class _TypeIcon extends StatelessWidget {
  /// {@macro TypeIcon}
  const _TypeIcon({required this.type, this.size = 24});

  /// Тип фрагмента
  final MaterialTemplateType type;

  /// Размер иконки
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      MaterialTemplateType.theory => (Icons.book, Colors.blue),
      MaterialTemplateType.example => (Icons.code, Colors.green),
      MaterialTemplateType.task => (Icons.assignment, Colors.orange),
      MaterialTemplateType.visualization => (Icons.image, Colors.purple),
    };

    return Icon(icon, size: size, color: color);
  }
}
