part of 'material_builder_bloc.dart';

/// {@template MaterialBuilderEvent}
/// События для управления созданием учебных материалов
/// {@endtemplate}
sealed class MaterialBuilderEvent extends Equatable {
  /// {@macro MaterialBuilderEvent}
  const MaterialBuilderEvent();

  @override
  List<Object> get props => [];
}

/// {@template MaterialBuilderUploadDocumentEvent}
/// Событие загрузки документа для обработки
/// {@endtemplate}
final class MaterialBuilderUploadDocumentEvent extends MaterialBuilderEvent {
  /// {@macro MaterialBuilderUploadDocumentEvent}
  const MaterialBuilderUploadDocumentEvent({required this.filePath});

  /// Путь к файлу документа
  final String filePath;

  @override
  List<Object> get props => [filePath];
}

/// {@template MaterialBuilderProcessDocumentEvent}
/// Событие обработки документа через AI
/// {@endtemplate}
final class MaterialBuilderProcessDocumentEvent extends MaterialBuilderEvent {
  /// {@macro MaterialBuilderProcessDocumentEvent}
  const MaterialBuilderProcessDocumentEvent({
    required this.documentId,
    required this.content,
  });

  /// Идентификатор документа
  final String documentId;

  /// Содержимое документа
  final String content;

  @override
  List<Object> get props => [documentId, content];
}

/// {@template MaterialBuilderUpdateFragmentEvent}
/// Событие обновления фрагмента материала
/// {@endtemplate}
final class MaterialBuilderUpdateFragmentEvent extends MaterialBuilderEvent {
  /// {@macro MaterialBuilderUpdateFragmentEvent}
  const MaterialBuilderUpdateFragmentEvent({required this.fragment});

  /// Обновленный фрагмент
  final MaterialTemplateEntity fragment;

  @override
  List<Object> get props => [fragment];
}

/// {@template MaterialBuilderGenerateOutputEvent}
/// Событие генерации финального документа
/// {@endtemplate}
final class MaterialBuilderGenerateOutputEvent extends MaterialBuilderEvent {
  /// {@macro MaterialBuilderGenerateOutputEvent}
  const MaterialBuilderGenerateOutputEvent({
    required this.material,
    required this.outputFormat,
  });

  /// Обработанный материал
  final ProcessedMaterialEntity material;

  /// Формат вывода (pdf, pptx)
  final String outputFormat;

  @override
  List<Object> get props => [material, outputFormat];
}

/// {@template MaterialBuilderLoadMaterialsEvent}
/// Событие загрузки списка обработанных материалов
/// {@endtemplate}
final class MaterialBuilderLoadMaterialsEvent extends MaterialBuilderEvent {
  /// {@macro MaterialBuilderLoadMaterialsEvent}
  const MaterialBuilderLoadMaterialsEvent();
}
