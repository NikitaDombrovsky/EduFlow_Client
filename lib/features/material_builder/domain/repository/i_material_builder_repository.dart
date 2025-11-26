import 'package:friflex_starter/di/di_base_repo.dart';
import 'package:friflex_starter/features/material_builder/domain/entity/material_template_entity.dart';

/// {@template IMaterialBuilderRepository}
/// Интерфейс репозитория для работы с созданием учебных материалов
/// {@endtemplate}
abstract interface class IMaterialBuilderRepository with DiBaseRepo {
  /// Загружает документ для обработки
  /// 
  /// Принимает:
  /// - [filePath] - путь к файлу документа
  /// 
  /// Возвращает [ProcessedMaterialEntity] с обработанным материалом
  Future<ProcessedMaterialEntity> uploadDocument(String filePath);

  /// Обрабатывает документ через AI-сервис
  /// 
  /// Принимает:
  /// - [documentId] - идентификатор документа
  /// - [content] - содержимое документа
  /// 
  /// Возвращает [ProcessedMaterialEntity] с классифицированными фрагментами
  Future<ProcessedMaterialEntity> processDocument({
    required String documentId,
    required String content,
  });

  /// Сохраняет отредактированный фрагмент
  /// 
  /// Принимает:
  /// - [fragment] - обновленный фрагмент материала
  Future<void> updateFragment(MaterialTemplateEntity fragment);

  /// Генерирует финальный документ/презентацию
  /// 
  /// Принимает:
  /// - [material] - обработанный материал
  /// - [outputFormat] - формат вывода (pdf, pptx)
  /// 
  /// Возвращает путь к сгенерированному файлу
  Future<String> generateOutput({
    required ProcessedMaterialEntity material,
    required String outputFormat,
  });

  /// Получает список обработанных материалов
  Future<List<ProcessedMaterialEntity>> getProcessedMaterials();
}
