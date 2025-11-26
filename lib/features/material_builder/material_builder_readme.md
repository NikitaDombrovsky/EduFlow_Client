# Модуль "Автоматизированное создание учебных материалов"

## Описание

Модуль для автоматизированного создания учебных материалов с использованием AI-сервиса. Позволяет загружать исходные документы, автоматически классифицировать фрагменты, редактировать материалы и экспортировать результат в PDF или PowerPoint.

## Основные возможности

1. **Загрузка документов** - поддержка форматов DOCX, PDF, Markdown
2. **AI-обработка** - автоматическая классификация фрагментов на:
   - Теория
   - Примеры кода
   - Практические задания
   - Визуализации
3. **Редактирование** - ручная корректировка обработанных фрагментов
4. **Экспорт** - генерация финальных документов в PDF или PPTX

## Архитектура

Модуль следует Clean Architecture и feature-first структуре:

```
material_builder/
├── data/
│   └── repository/
│       ├── material_builder_repository.dart      # Реальная реализация
│       └── material_builder_mock_repository.dart # Мок для разработки
├── domain/
│   ├── entity/
│   │   └── material_template_entity.dart         # Доменные сущности
│   ├── repository/
│   │   └── i_material_builder_repository.dart    # Интерфейс репозитория
│   └── bloc/
│       ├── material_builder_bloc.dart            # Бизнес-логика
│       ├── material_builder_event.dart           # События
│       └── material_builder_state.dart           # Состояния
├── presentation/
│   ├── screens/
│   │   └── material_builder_screen.dart          # Главный экран
│   └── components/
│       ├── upload_section.dart                   # Секция загрузки
│       └── fragment_editor_section.dart          # Редактор фрагментов
└── material_builder_routes.dart                  # Роутинг модуля
```

## Использование

### Интеграция в проект

1. Добавьте репозиторий в `di/di_repositories.dart`:

```dart
late final IMaterialBuilderRepository materialBuilderRepository;

// В методе init():
materialBuilderRepository = _lazyInitRepo<IMaterialBuilderRepository>(
  mockFactory: MaterialBuilderMockRepository.new,
  mainFactory: () => MaterialBuilderRepository(
    httpClient: diContainer.httpClientFactory(
      diContainer.debugService,
      diContainer.appConfig,
    ),
  ),
  onProgress: onProgress,
  onError: onError,
  environment: diContainer.env,
);
```

2. Добавьте роуты в `router/app_router.dart`:

```dart
import 'package:friflex_starter/features/material_builder/material_builder_routes.dart';

// В списке routes:
MaterialBuilderRoutes.buildRoutes(),
```

3. Навигация к экрану:

```dart
context.pushNamed(MaterialBuilderRoutes.materialBuilderScreenName);
```

### Сценарий использования

1. **Загрузка документа**
   - Пользователь выбирает файл (DOCX, PDF, MD)
   - Документ загружается на сервер
   - Событие: `MaterialBuilderUploadDocumentEvent`

2. **Обработка AI**
   - AI-сервис анализирует документ
   - Текст разбивается на фрагменты
   - Каждый фрагмент классифицируется по типу
   - Событие: `MaterialBuilderProcessDocumentEvent`
   - Состояние: `MaterialBuilderProcessedState`

3. **Редактирование**
   - Пользователь проверяет фрагменты
   - Редактирует содержимое и заголовки при необходимости
   - Событие: `MaterialBuilderUpdateFragmentEvent`

4. **Экспорт**
   - Выбор формата (PDF или PPTX)
   - Генерация финального документа
   - Событие: `MaterialBuilderGenerateOutputEvent`
   - Состояние: `MaterialBuilderOutputGeneratedState`

## Типы фрагментов

```dart
enum MaterialTemplateType {
  theory,         // Теоретический материал
  example,        // Пример кода
  task,           // Практическое задание
  visualization,  // Визуализация/схема
}
```

## Сущности

### MaterialTemplateEntity

Представляет отдельный фрагмент материала:

- `id` - уникальный идентификатор
- `type` - тип фрагмента
- `content` - основное содержимое
- `order` - порядок отображения
- `title` - заголовок (опционально)
- `codeLanguage` - язык программирования (для примеров)
- `isEdited` - флаг редактирования пользователем

### ProcessedMaterialEntity

Представляет обработанный документ:

- `documentId` - уникальный идентификатор
- `originalFileName` - имя исходного файла
- `fragments` - список фрагментов
- `processedAt` - дата обработки
- `metadata` - дополнительные метаданные

## Состояния BLoC

- `MaterialBuilderInitialState` - начальное состояние
- `MaterialBuilderLoadingState` - загрузка документа
- `MaterialBuilderProcessingState` - обработка AI
- `MaterialBuilderGeneratingState` - генерация документа
- `MaterialBuilderDocumentUploadedState` - документ загружен
- `MaterialBuilderProcessedState` - документ обработан
- `MaterialBuilderOutputGeneratedState` - документ сгенерирован
- `MaterialBuilderErrorState` - ошибка

## TODO

### Backend интеграция

- [ ] Реализовать загрузку файлов на сервер
- [ ] Интегрировать AI-сервис для классификации
- [ ] Реализовать Material Builder для генерации презентаций
- [ ] Добавить хранение истории обработанных документов

### UI улучшения

- [ ] Добавить поддержку drag-and-drop для загрузки файлов
- [ ] Реализовать предпросмотр сгенерированных документов
- [ ] Добавить пакетную обработку документов
- [ ] Улучшить редактор кода с подсветкой синтаксиса

### Дополнительные функции

- [ ] Шаблоны для разных типов материалов
- [ ] Автосохранение прогресса
- [ ] Экспорт в дополнительные форматы (HTML, EPUB)
- [ ] Совместное редактирование материалов

## Зависимости

Для полноценной работы потребуется:

- `file_picker` - для выбора файлов
- `dio` - для HTTP запросов (уже есть)
- Python-сервис для AI обработки
- Python-сервис для генерации презентаций (python-pptx)

## Заметки по разработке

- Моковый репозиторий возвращает демонстрационные данные
- Для dev окружения всегда используется мок
- Для stage/prod нужна реализация с реальным API
- Все TODO помечены комментариями `// TODO(dev):`
