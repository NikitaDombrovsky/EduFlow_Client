import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/features/material_builder/domain/bloc/material_builder_bloc.dart';
import 'package:friflex_starter/features/material_builder/domain/entity/material_template_entity.dart';

/// {@template FragmentEditorSection}
/// Компонент для редактирования обработанных фрагментов
/// {@endtemplate}
class FragmentEditorSection extends StatelessWidget {
  /// {@macro FragmentEditorSection}
  const FragmentEditorSection({required this.material, super.key});

  /// Обработанный материал
  final ProcessedMaterialEntity material;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeaderSection(material: material),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final fragment = material.fragments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FragmentCard(fragment: fragment),
                );
              },
              childCount: material.fragments.length,
            ),
          ),
        ),
      ],
    );
  }
}

/// {@template HeaderSection}
/// Заголовок секции с информацией о документе
/// {@endtemplate}
class _HeaderSection extends StatelessWidget {
  /// {@macro HeaderSection}
  const _HeaderSection({required this.material});

  /// Обработанный материал
  final ProcessedMaterialEntity material;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            material.originalFileName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const HBox(8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green,
              ),
              const WBox(4),
              Flexible(
                child: Text(
                  'Обработано фрагментов: ${material.fragments.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// {@template FragmentCard}
/// Карточка отдельного фрагмента для редактирования
/// {@endtemplate}
class _FragmentCard extends StatefulWidget {
  /// {@macro FragmentCard}
  const _FragmentCard({required this.fragment});

  /// Фрагмент материала
  final MaterialTemplateEntity fragment;

  @override
  State<_FragmentCard> createState() => _FragmentCardState();
}

class _FragmentCardState extends State<_FragmentCard> {
  late TextEditingController _contentController;
  late TextEditingController _titleController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.fragment.content);
    _titleController = TextEditingController(text: widget.fragment.title ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _TypeChip(type: widget.fragment.type),
                if (widget.fragment.isEdited)
                  Chip(
                    label: const Text('Отредактировано'),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: _toggleEdit,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showDeleteDialog(context),
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const HBox(12),
            if (_isEditing) ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const HBox(12),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Содержимое',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 6,
                minLines: 3,
              ),
            ] else ...[
              if (widget.fragment.title != null) ...[
                Text(
                  widget.fragment.title!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const HBox(8),
              ],
              Text(
                widget.fragment.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Переключает режим редактирования
  void _toggleEdit() {
    if (_isEditing) {
      final updatedFragment = widget.fragment.copyWith(
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        content: _contentController.text,
        isEdited: true,
      );
      context.read<MaterialBuilderBloc>().add(
        MaterialBuilderUpdateFragmentEvent(fragment: updatedFragment),
      );
    }
    setState(() => _isEditing = !_isEditing);
  }

  /// Показывает диалог подтверждения удаления
  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить фрагмент?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // TODO(dev): Реализовать удаление фрагмента
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

/// {@template TypeChip}
/// Чип для отображения типа фрагмента
/// {@endtemplate}
class _TypeChip extends StatelessWidget {
  /// {@macro TypeChip}
  const _TypeChip({required this.type});

  /// Тип фрагмента
  final MaterialTemplateType type;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (type) {
      MaterialTemplateType.theory => (Colors.blue, Icons.book, 'Теория'),
      MaterialTemplateType.example => (Colors.green, Icons.code, 'Пример'),
      MaterialTemplateType.task => (Colors.orange, Icons.assignment, 'Задание'),
      MaterialTemplateType.visualization => (Colors.purple, Icons.image, 'Визуализация'),
    };

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color.shade800, fontSize: 12),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}