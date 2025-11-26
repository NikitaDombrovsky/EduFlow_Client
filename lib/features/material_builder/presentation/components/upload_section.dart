import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/features/material_builder/domain/bloc/material_builder_bloc.dart';

/// {@template UploadSection}
/// Компонент для загрузки документов
/// {@endtemplate}
class UploadSection extends StatelessWidget {
  /// {@macro UploadSection}
  const UploadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.upload_file,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const HBox(24),
            Text(
              'Загрузите документ для обработки',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const HBox(12),
            Text(
              'Поддерживаемые форматы: DOCX, PDF, Markdown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const HBox(32),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Выбрать файл'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const HBox(16),
                  Text(
                    'или перетащите файл сюда',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const HBox(24),
            const _HelpSection(),
          ],
        ),
      ),
    );
  }

  /// Открывает диалог выбора файла
  void _pickFile(BuildContext context) {
    // TODO(dev): Интеграция с file_picker
    // Пример использования:
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['docx', 'pdf', 'md'],
    // );
    // if (result != null && result.files.single.path != null) {
    //   context.read<MaterialBuilderBloc>().add(
    //     MaterialBuilderUploadDocumentEvent(
    //       filePath: result.files.single.path!,
    //     ),
    //   );
    // }

    // Временная демонстрация
    context.read<MaterialBuilderBloc>().add(
      const MaterialBuilderUploadDocumentEvent(
        filePath: '/demo/sample.docx',
      ),
    );
  }
}

/// {@template HelpSection}
/// Секция с подсказками
/// {@endtemplate}
class _HelpSection extends StatelessWidget {
  /// {@macro HelpSection}
  const _HelpSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const WBox(8),
                Text(
                  'Как это работает:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const HBox(12),
            _HelpItem(
              number: '1',
              text: 'Загрузите документ с учебным материалом',
            ),
            _HelpItem(
              number: '2',
              text: 'ИИ автоматически разобьет материал на фрагменты',
            ),
            _HelpItem(
              number: '3',
              text: 'Проверьте и отредактируйте при необходимости',
            ),
            _HelpItem(
              number: '4',
              text: 'Экспортируйте готовый материал в PDF или PPTX',
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template HelpItem}
/// Элемент списка подсказок
/// {@endtemplate}
class _HelpItem extends StatelessWidget {
  /// {@macro HelpItem}
  const _HelpItem({required this.number, required this.text});

  /// Номер шага
  final String number;

  /// Описание шага
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const WBox(12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
