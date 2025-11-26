part of 'material_builder_bloc.dart';

/// {@template MaterialBuilderState}
/// Состояния для процесса создания учебных материалов
/// {@endtemplate}
sealed class MaterialBuilderState extends Equatable {
  /// {@macro MaterialBuilderState}
  const MaterialBuilderState();

  @override
  List<Object?> get props => [];
}

/// {@template MaterialBuilderInitialState}
/// Начальное состояние
/// {@endtemplate}
final class MaterialBuilderInitialState extends MaterialBuilderState {
  /// {@macro MaterialBuilderInitialState}
  const MaterialBuilderInitialState();
}

/// {@template MaterialBuilderLoadingState}
/// Состояние загрузки
/// {@endtemplate}
final class MaterialBuilderLoadingState extends MaterialBuilderState {
  /// {@macro MaterialBuilderLoadingState}
  const MaterialBuilderLoadingState();
}

/// {@template MaterialBuilderProcessingState}
/// Состояние обработки документа
/// {@endtemplate}
final class MaterialBuilderProcessingState extends MaterialBuilderState {
  /// {@macro MaterialBuilderProcessingState}
  const MaterialBuilderProcessingState();
}

/// {@template MaterialBuilderGeneratingState}
/// Состояние генерации финального документа
/// {@endtemplate}
final class MaterialBuilderGeneratingState extends MaterialBuilderState {
  /// {@macro MaterialBuilderGeneratingState}
  const MaterialBuilderGeneratingState();
}

/// {@template MaterialBuilderDocumentUploadedState}
/// Состояние успешной загрузки документа
/// {@endtemplate}
final class MaterialBuilderDocumentUploadedState extends MaterialBuilderState {
  /// {@macro MaterialBuilderDocumentUploadedState}
  const MaterialBuilderDocumentUploadedState({required this.material});

  /// Загруженный материал
  final ProcessedMaterialEntity material;

  @override
  List<Object> get props => [material];
}

/// {@template MaterialBuilderProcessedState}
/// Состояние успешной обработки документа
/// {@endtemplate}
final class MaterialBuilderProcessedState extends MaterialBuilderState {
  /// {@macro MaterialBuilderProcessedState}
  const MaterialBuilderProcessedState({required this.material});

  /// Обработанный материал с фрагментами
  final ProcessedMaterialEntity material;

  @override
  List<Object> get props => [material];
}

/// {@template MaterialBuilderOutputGeneratedState}
/// Состояние успешной генерации документа
/// {@endtemplate}
final class MaterialBuilderOutputGeneratedState extends MaterialBuilderState {
  /// {@macro MaterialBuilderOutputGeneratedState}
  const MaterialBuilderOutputGeneratedState({required this.outputPath});

  /// Путь к сгенерированному файлу
  final String outputPath;

  @override
  List<Object> get props => [outputPath];
}

/// {@template MaterialBuilderMaterialsLoadedState}
/// Состояние успешной загрузки списка материалов
/// {@endtemplate}
final class MaterialBuilderMaterialsLoadedState extends MaterialBuilderState {
  /// {@macro MaterialBuilderMaterialsLoadedState}
  const MaterialBuilderMaterialsLoadedState({required this.materials});

  /// Список обработанных материалов
  final List<ProcessedMaterialEntity> materials;

  @override
  List<Object> get props => [materials];
}

/// {@template MaterialBuilderErrorState}
/// Состояние ошибки
/// {@endtemplate}
final class MaterialBuilderErrorState extends MaterialBuilderState {
  /// {@macro MaterialBuilderErrorState}
  const MaterialBuilderErrorState({
    required this.message,
    required this.error,
    this.stackTrace,
  });

  /// Сообщение об ошибке
  final String message;

  /// Объект ошибки
  final Object error;

  /// Стек трейс
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, error, stackTrace];
}
