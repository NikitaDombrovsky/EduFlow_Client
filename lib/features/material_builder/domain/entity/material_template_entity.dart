import 'package:equatable/equatable.dart';

/// {@template MaterialTemplateType}
/// Тип шаблона для классификации материала
/// {@endtemplate}
enum MaterialTemplateType {
  /// Теоретический материал
  theory,
  
  /// Пример кода
  example,
  
  /// Практическое задание
  task,
  
  /// Визуализация/схема
  visualization,
}

/// {@template MaterialTemplateEntity}
/// Сущность для представления обработанного фрагмента материала
/// {@endtemplate}
class MaterialTemplateEntity extends Equatable {
  /// {@macro MaterialTemplateEntity}
  const MaterialTemplateEntity({
    required this.id,
    required this.type,
    required this.content,
    required this.order,
    this.title,
    this.codeLanguage,
    this.isEdited = false,
  });

  /// Уникальный идентификатор фрагмента
  final String id;

  /// Тип фрагмента материала
  final MaterialTemplateType type;

  /// Основной контент фрагмента
  final String content;

  /// Порядок отображения в документе
  final int order;

  /// Заголовок фрагмента (опционально)
  final String? title;

  /// Язык программирования для примеров кода
  final String? codeLanguage;

  /// Флаг редактирования пользователем
  final bool isEdited;

  /// Создание копии с возможностью изменения полей
  MaterialTemplateEntity copyWith({
    String? id,
    MaterialTemplateType? type,
    String? content,
    int? order,
    String? title,
    String? codeLanguage,
    bool? isEdited,
  }) {
    return MaterialTemplateEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      order: order ?? this.order,
      title: title ?? this.title,
      codeLanguage: codeLanguage ?? this.codeLanguage,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        content,
        order,
        title,
        codeLanguage,
        isEdited,
      ];
}

/// {@template ProcessedMaterialEntity}
/// Сущность для представления полного обработанного материала
/// {@endtemplate}
class ProcessedMaterialEntity extends Equatable {
  /// {@macro ProcessedMaterialEntity}
  const ProcessedMaterialEntity({
    required this.documentId,
    required this.originalFileName,
    required this.fragments,
    required this.processedAt,
    this.metadata,
  });

  /// Уникальный идентификатор документа
  final String documentId;

  /// Оригинальное имя файла
  final String originalFileName;

  /// Список обработанных фрагментов
  final List<MaterialTemplateEntity> fragments;

  /// Дата и время обработки
  final DateTime processedAt;

  /// Дополнительные метаданные
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [
        documentId,
        originalFileName,
        fragments,
        processedAt,
        metadata,
      ];
}
