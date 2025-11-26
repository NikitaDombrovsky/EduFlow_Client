import 'package:friflex_starter/features/material_builder/domain/entity/material_template_entity.dart';
import 'package:friflex_starter/features/material_builder/domain/repository/i_material_builder_repository.dart';

/// {@template MaterialBuilderMockRepository}
/// Моковая реализация репозитория для создания учебных материалов
/// {@endtemplate}
final class MaterialBuilderMockRepository
    implements IMaterialBuilderRepository {
  /// {@macro MaterialBuilderMockRepository}
  const MaterialBuilderMockRepository();

  @override
  String get name => 'MaterialBuilderMockRepository';

  @override
  Future<ProcessedMaterialEntity> uploadDocument(String filePath) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    return ProcessedMaterialEntity(
      documentId: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      originalFileName: filePath.split('/').last,
      fragments: [],
      processedAt: DateTime.now(),
    );
  }

  @override
  Future<ProcessedMaterialEntity> processDocument({
    required String documentId,
    required String content,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    return ProcessedMaterialEntity(
      documentId: documentId,
      originalFileName: 'Основы программирования на Dart.docx',
      fragments: [
        const MaterialTemplateEntity(
          id: 'fragment_1',
          type: MaterialTemplateType.theory,
          content: '''
Dart - это язык программирования, оптимизированный для создания 
пользовательских интерфейсов. Он поддерживает как AOT, так и JIT компиляцию, 
что обеспечивает высокую производительность при разработке и в продакшене.
''',
          order: 1,
          title: 'Введение в Dart',
        ),
        const MaterialTemplateEntity(
          id: 'fragment_2',
          type: MaterialTemplateType.example,
          content: '''
void main() {
  print('Hello, Dart!');
  
  var name = 'Студент';
  var age = 20;
  
  print('Меня зовут \$name, мне \$age лет');
}
''',
          order: 2,
          title: 'Пример: Hello World',
          codeLanguage: 'dart',
        ),
        const MaterialTemplateEntity(
          id: 'fragment_3',
          type: MaterialTemplateType.theory,
          content: '''
Переменные в Dart могут быть объявлены с использованием ключевых слов var, 
final или const. Используйте final для значений, которые устанавливаются 
один раз, и const для compile-time констант.
''',
          order: 3,
          title: 'Переменные в Dart',
        ),
        const MaterialTemplateEntity(
          id: 'fragment_4',
          type: MaterialTemplateType.task,
          content: '''
Создайте программу, которая:
1. Объявляет переменные с вашим именем и возрастом
2. Вычисляет год вашего рождения
3. Выводит результат в формате: "Я родился в [год]"

Используйте строковую интерполяцию для вывода.
''',
          order: 4,
          title: 'Задание: Работа с переменными',
        ),
        const MaterialTemplateEntity(
          id: 'fragment_5',
          type: MaterialTemplateType.visualization,
          content: '''
[Диаграмма процесса компиляции Dart]
Исходный код → Dart Analyzer → AOT/JIT Компилятор → Нативный код
''',
          order: 5,
          title: 'Схема компиляции Dart',
        ),
      ],
      processedAt: DateTime.now(),
      metadata: {
        'totalFragments': 5,
        'processingTime': '2s',
      },
    );
  }

  @override
  Future<void> updateFragment(MaterialTemplateEntity fragment) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<String> generateOutput({
    required ProcessedMaterialEntity material,
    required String outputFormat,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 3));

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '/downloads/${material.originalFileName}_$timestamp.$outputFormat';
  }

  @override
  Future<List<ProcessedMaterialEntity>> getProcessedMaterials() async {
    await Future<void>.delayed(const Duration(seconds: 1));

    return [
      ProcessedMaterialEntity(
        documentId: 'doc_1',
        originalFileName: 'Введение в Flutter.docx',
        fragments: const [],
        processedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProcessedMaterialEntity(
        documentId: 'doc_2',
        originalFileName: 'ООП в Dart.pdf',
        fragments: const [],
        processedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
