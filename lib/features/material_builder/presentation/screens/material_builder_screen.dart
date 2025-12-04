import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friflex_starter/app/app_context_ext.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/features/material_builder/domain/bloc/material_builder_bloc.dart';
import 'package:friflex_starter/features/material_builder/presentation/components/fragment_editor_section.dart';
import 'package:friflex_starter/features/material_builder/presentation/components/upload_section.dart';

/// {@template MaterialBuilderScreen}
/// Главный экран для автоматизированного создания учебных материалов
/// 
/// Отвечает за:
/// - Загрузку исходных документов
/// - Отображение обработанных фрагментов
/// - Редактирование материалов
/// - Генерацию финального документа
/// {@endtemplate}
class MaterialBuilderScreen extends StatelessWidget {
  /// {@macro MaterialBuilderScreen}
  const MaterialBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaterialBuilderBloc(
        context.di.repositories.materialBuilderRepository,
      ),
      child: const _MaterialBuilderScreenView(),
    );
  }
}

/// {@template MaterialBuilderScreenView}
/// Виджет отображения UI экрана создания материалов
/// {@endtemplate}
class _MaterialBuilderScreenView extends StatelessWidget {
  /// {@macro MaterialBuilderScreenView}
  const _MaterialBuilderScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание учебных материалов'),
        actions: [
          BlocBuilder<MaterialBuilderBloc, MaterialBuilderState>(
            builder: (context, state) {
              if (state is MaterialBuilderProcessedState) {
                return IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _showExportDialog(context, state.material),
                  tooltip: 'Экспортировать',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<MaterialBuilderBloc, MaterialBuilderState>(
        listener: (context, state) {
          if (state is MaterialBuilderErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MaterialBuilderOutputGeneratedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Документ сгенерирован: ${state.outputPath}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            MaterialBuilderInitialState() ||
            MaterialBuilderDocumentUploadedState() =>
              const UploadSection(),
            MaterialBuilderLoadingState() ||
            MaterialBuilderProcessingState() ||
            MaterialBuilderGeneratingState() =>
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    HBox(16),
                    Text('Обработка документа...'),
                  ],
                ),
              ),
            MaterialBuilderProcessedState() => FragmentEditorSection(
                material: state.material,
              ),
            MaterialBuilderOutputGeneratedState() => SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 64, color: Colors.green),
                        const HBox(16),
                        const Text('Документ успешно создан'),
                        const HBox(8),
                        Text(
                          state.outputPath,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const HBox(24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MaterialBuilderBloc>().add(
                              const MaterialBuilderLoadMaterialsEvent(),
                            );
                          },
                          child: const Text('Создать новый материал'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            MaterialBuilderMaterialsLoadedState() => const UploadSection(),
            MaterialBuilderErrorState() => SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const HBox(16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                        const HBox(24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MaterialBuilderBloc>().add(
                              const MaterialBuilderLoadMaterialsEvent(),
                            );
                          },
                          child: const Text('Попробовать снова'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          };
        },
      ),
    );
  }


  /// TODO Повторяется, вынести в компоненты
  /// Показывает диалог выбора формата экспорта
  void _showExportDialog(BuildContext context, dynamic material) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выберите формат'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('PDF документ'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                context.read<MaterialBuilderBloc>().add(
                  MaterialBuilderGenerateOutputEvent(
                    material: material,
                    outputFormat: 'pdf',
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.slideshow),
              title: const Text('PowerPoint презентация'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                context.read<MaterialBuilderBloc>().add(
                  MaterialBuilderGenerateOutputEvent(
                    material: material,
                    outputFormat: 'pptx',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}