import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/app/ui_kit/app_snackbar.dart';
import 'package:friflex_starter/features/material_builder/domain/bloc/material_builder_bloc.dart';
import 'package:friflex_starter/features/material_builder/presentation/screens/text_preview_screen.dart';

/// {@template UploadSection}
/// Компонент для загрузки документов
/// {@endtemplate}
class UploadSection extends StatefulWidget {
  /// {@macro UploadSection}
  const UploadSection({super.key});

  @override
  State<UploadSection> createState() => _UploadSectionState();
}

class _UploadSectionState extends State<UploadSection> {
  bool _isProcessing = false;
  DropzoneViewController? _dropzoneController;
  bool _isDraggingOver = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                'Поддерживаемые форматы: DOCX, PDF, Markdown, TXT',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const HBox(32),
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (_isDraggingOver
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3)),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: _isDraggingOver
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.2)
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isProcessing)
                          const CircularProgressIndicator()
                        else ...[
                          Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.6),
                          ),
                          const HBox(8),
                          Text(
                            'Перетащите файл сюда или выберите вручную',
                            textAlign: TextAlign.center,
                          ),
                          const HBox(16),
                          ElevatedButton.icon(
                            onPressed: _pickFile,
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
                          OutlinedButton.icon(
                            onPressed: _pasteFromClipboard,
                            icon: const Icon(Icons.content_paste),
                            label: const Text('Вставить текст'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (kIsWeb)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: _isProcessing,
                        child: DropzoneView(
                          onCreated: (controller) => _dropzoneController = controller,
                          onDrop: (ev) async {
                            if (_isProcessing) return;
                            setState(() => _isProcessing = true);
                            try {
                              final name = await _dropzoneController!.getFilename(ev);
                              final mime = await _dropzoneController!.getFileMIME(ev);
                              final data = await _dropzoneController!.getFileData(ev);
                              await _processDroppedFile(name, mime, data);
                            } on Object catch (e) {
                              if (!mounted) return;
                              AppSnackBar.showError(
                                context,
                                message: 'Ошибка загрузки файла: $e',
                              );
                            } finally {
                              if (mounted) setState(() => _isProcessing = false);
                            }
                          },
                          onHover: () => setState(() => _isDraggingOver = true),
                          onLeave: () => setState(() => _isDraggingOver = false),
                        ),
                      ),
                    ),
                ],
              ),
              const HBox(24),
              const _HelpSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Открывает системный файловый менеджер для выбора файла
  Future<void> _pickFile() async {
    try {
      setState(() => _isProcessing = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'pdf', 'md', 'txt'],
        allowMultiple: false,
      );

      if (!mounted) return;

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final fileName = filePath.split('/').last;

        if (await file.exists()) {
          // Читаем содержимое файла
          final content = await _readFileContent(file, filePath);
          
          if (!mounted) return;

          // Переходим к экрану предпросмотра
          await _navigateToPreview(
            documentId: 'doc_${DateTime.now().millisecondsSinceEpoch}',
            content: content,
            fileName: fileName,
          );
        } else {
          if (!mounted) return;
          AppSnackBar.showError(
            context,
            message: 'Файл не найден',
          );
        }
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Ошибка доступа к файлу: ${e.message}',
      );
    } on Object catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Ошибка при выборе файла: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Читает содержимое файла в зависимости от расширения
  Future<String> _readFileContent(File file, String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'txt':
      case 'md':
        // Текстовые файлы читаем напрямую
        return await file.readAsString();
      
      case 'docx':
        // TODO(dev): Добавить парсинг DOCX через docx_to_text или аналог
        // Временно возвращаем сообщение
        return 'DOCX файл: ${filePath.split('/').last}\n\nДля полной обработки DOCX требуется интеграция с backend.';
      
      case 'pdf':
        // TODO(dev): Добавить парсинг PDF через pdf_text или аналог
        // Временно возвращаем сообщение
        return 'PDF файл: ${filePath.split('/').last}\n\nДля полной обработки PDF требуется интеграция с backend.';
      
      default:
        throw Exception('Неподдерживаемый формат файла');
    }
  }

  Future<void> _processDroppedFile(
    String fileName,
    String mime,
    Uint8List data,
  ) async {
    final ext = fileName.split('.').last.toLowerCase();
    late final String content;

    switch (ext) {
      case 'txt':
      case 'md':
        content = utf8.decode(data, allowMalformed: true);
        break;
      case 'docx':
        content = 'DOCX файл: $fileName\n\nДля полной обработки DOCX требуется интеграция с backend.';
        break;
      case 'pdf':
        content = 'PDF файл: $fileName\n\nДля полной обработки PDF требуется интеграция с backend.';
        break;
      default:
        throw Exception('Неподдерживаемый формат файла');
    }

    await _navigateToPreview(
      documentId: 'web_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      fileName: fileName,
    );
  }

  /// Вставляет текст из буфера обмена
  Future<void> _pasteFromClipboard() async {
    try {
      setState(() => _isProcessing = true);

      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

      if (!mounted) return;

      if (clipboardData != null && clipboardData.text != null) {
        final text = clipboardData.text!.trim();

        if (text.isEmpty) {
          AppSnackBar.showInfo(
            context,
            message: 'Буфер обмена пуст',
          );
          return;
        }

        if (text.length < 10) {
          AppSnackBar.showError(
            context,
            message: 'Слишком мало текста для обработки (минимум 10 символов)',
          );
          return;
        }

        // Переходим к экрану предпросмотра
        await _navigateToPreview(
          documentId: 'clipboard_${DateTime.now().millisecondsSinceEpoch}',
          content: text,
          fileName: 'Текст из буфера обмена',
        );
      } else {
        AppSnackBar.showError(
          context,
          message: 'Буфер обмена пуст или не содержит текст',
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Ошибка доступа к буферу обмена: ${e.message}',
      );
    } on Object catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Ошибка при вставке текста: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Переходит к экрану предпросмотра текста
  Future<void> _navigateToPreview({
    required String documentId,
    required String content,
    required String fileName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MaterialBuilderBloc>(),
          child: TextPreviewScreen(
            documentId: documentId,
            initialText: content,
            fileName: fileName,
          ),
        ),
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
              text: 'Выберите файл или вставьте текст из буфера обмена',
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
