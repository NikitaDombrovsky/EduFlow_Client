import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friflex_starter/app/app_context_ext.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/app/ui_kit/app_snackbar.dart';
import 'package:friflex_starter/features/material_builder/domain/bloc/material_builder_bloc.dart';
import 'package:friflex_starter/features/material_builder/domain/entity/material_template_entity.dart';
import 'package:friflex_starter/features/material_builder/presentation/components/fragment_editor_card.dart';
import 'package:friflex_starter/features/material_builder/presentation/components/fragment_type_selector.dart';

/// {@template MaterialEditorScreen}
/// Экран редактирования учебного материала
///
/// Отвечает за:
/// - Просмотр и редактирование фрагментов материала
/// - Добавление новых фрагментов
/// - Удаление и переупорядочивание фрагментов
/// - Сохранение изменений
/// {@endtemplate}
class MaterialEditorScreen extends StatefulWidget {
  /// {@macro MaterialEditorScreen}
  const MaterialEditorScreen({
    required this.material,
    super.key,
  });

  /// Материал для редактирования
  final ProcessedMaterialEntity material;

  @override
  State<MaterialEditorScreen> createState() => _MaterialEditorScreenState();
}

class _MaterialEditorScreenState extends State<MaterialEditorScreen> {
  late List<MaterialTemplateEntity> _fragments;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _fragments = List.from(widget.material.fragments);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.material.originalFileName),
          actions: [
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _resetChanges,
                tooltip: 'Отменить изменения',
              ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _hasChanges ? _saveChanges : null,
              tooltip: 'Сохранить',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _showExportDialog,
              tooltip: 'Экспортировать',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildStatusBar(),
            Expanded(
              child: _fragments.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
                      buildDefaultDragHandles: false,
                      onReorder: _onReorder,
                      itemCount: _fragments.length,
                      itemBuilder: (context, index) {
                        final fragment = _fragments[index];
                        return ReorderableDragStartListener(
                          key: ValueKey(fragment.id),
                          index: index,
                          child: FragmentEditorCard(
                            fragment: fragment,
                            onUpdate: (updated) => _updateFragment(index, updated),
                            onDelete: () => _deleteFragment(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddFragmentDialog,
          icon: const Icon(Icons.add),
          label: const Text('Добавить фрагмент'),
        ),
      ),
    );
  }

  /// Строка статуса с информацией о материале
  Widget _buildStatusBar() {
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
          Icon(
            Icons.article,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const WBox(8),
          Text(
            'Фрагментов: ${_fragments.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          if (_hasChanges)
            Chip(
              avatar: const Icon(Icons.edit, size: 16),
              label: const Text('Есть изменения'),
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

  /// Состояние пустого списка
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const HBox(16),
          Text(
            'Нет фрагментов',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const HBox(8),
          Text(
            'Добавьте первый фрагмент материала',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const HBox(24),
          ElevatedButton.icon(
            onPressed: _showAddFragmentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Добавить фрагмент'),
          ),
        ],
      ),
    );
  }

  /// Обновляет фрагмент по индексу
  void _updateFragment(int index, MaterialTemplateEntity updated) {
    setState(() {
      _fragments[index] = updated;
      _hasChanges = true;
    });
  }

  /// Удаляет фрагмент по индексу
  void _deleteFragment(int index) {
    setState(() {
      _fragments.removeAt(index);
      _hasChanges = true;
    });
    AppSnackBar.showSuccess(
      context: context,
      message: 'Фрагмент удален',
    );
  }

  /// Переупорядочивает фрагменты
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _fragments.removeAt(oldIndex);
      _fragments.insert(newIndex, item);
      
      // Обновляем порядок для всех фрагментов
      for (var i = 0; i < _fragments.length; i++) {
        _fragments[i] = _fragments[i].copyWith(order: i + 1);
      }
      
      _hasChanges = true;
    });
  }

  /// Показывает диалог добавления нового фрагмента
  Future<void> _showAddFragmentDialog() async {
    MaterialTemplateType? selectedType;
    
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Добавить фрагмент'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Выберите тип фрагмента:'),
            const HBox(16),
            FragmentTypeSelector(
              onTypeSelected: (type) {
                selectedType = type;
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );

    if (selectedType != null) {
      _addNewFragment(selectedType!);
    }
  }

  /// Добавляет новый фрагмент
  void _addNewFragment(MaterialTemplateType type) {
    final newFragment = MaterialTemplateEntity(
      id: 'fragment_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      content: '',
      order: _fragments.length + 1,
      title: '',
      isEdited: true,
    );

    setState(() {
      _fragments.add(newFragment);
      _hasChanges = true;
    });

    AppSnackBar.showSuccess(
      context: context,
      message: 'Фрагмент добавлен',
    );
  }

  /// Сбрасывает изменения
  void _resetChanges() {
    setState(() {
      _fragments = List.from(widget.material.fragments);
      _hasChanges = false;
    });
    AppSnackBar.showInfo(
      context,
      message: 'Изменения отменены',
    );
  }

  /// Сохраняет изменения
  void _saveChanges() {
    // Обновляем все фрагменты в BLoC
    for (final fragment in _fragments) {
      context.read<MaterialBuilderBloc>().add(
            MaterialBuilderUpdateFragmentEvent(fragment: fragment),
          );
    }

    setState(() => _hasChanges = false);

    AppSnackBar.showSuccess(
      context: context,
      message: 'Изменения сохранены',
    );
  }

  /// Показывает диалог экспорта
  void _showExportDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Экспорт материала'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF документ'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _exportMaterial('pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.slideshow),
              title: const Text('PowerPoint презентация'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _exportMaterial('pptx');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Экспортирует материал
  void _exportMaterial(String format) {
    final updatedMaterial = ProcessedMaterialEntity(
      documentId: widget.material.documentId,
      originalFileName: widget.material.originalFileName,
      fragments: _fragments,
      processedAt: widget.material.processedAt,
      metadata: widget.material.metadata,
    );

    context.read<MaterialBuilderBloc>().add(
          MaterialBuilderGenerateOutputEvent(
            material: updatedMaterial,
            outputFormat: format,
          ),
        );
  }

  /// Показывает диалог подтверждения выхода
  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Несохраненные изменения'),
        content: const Text('У вас есть несохраненные изменения. Выйти без сохранения?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
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
