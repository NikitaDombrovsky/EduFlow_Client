import 'package:flutter/material.dart';
import 'package:friflex_starter/app/ui_kit/app_box.dart';
import 'package:friflex_starter/features/material_builder/domain/entity/material_template_entity.dart';

/// {@template FragmentTypeSelector}
/// Компонент для выбора типа фрагмента
/// {@endtemplate}
class FragmentTypeSelector extends StatelessWidget {
  /// {@macro FragmentTypeSelector}
  const FragmentTypeSelector({
    required this.onTypeSelected,
    super.key,
  });

  /// Колбек при выборе типа
  final void Function(MaterialTemplateType) onTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: MaterialTemplateType.values.map((type) {
        return _TypeOption(
          type: type,
          onTap: () => onTypeSelected(type),
        );
      }).toList(),
    );
  }
}

/// {@template TypeOption}
/// Опция выбора типа фрагмента
/// {@endtemplate}
class _TypeOption extends StatelessWidget {
  /// {@macro TypeOption}
  const _TypeOption({
    required this.type,
    required this.onTap,
  });

  /// Тип фрагмента
  final MaterialTemplateType type;

  /// Колбек при нажатии
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label, description) = _getTypeInfo(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const WBox(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const HBox(4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Возвращает информацию о типе
  (IconData, Color, String, String) _getTypeInfo(MaterialTemplateType type) {
    return switch (type) {
      MaterialTemplateType.theory => (
          Icons.book,
          Colors.blue,
          'Теория',
          'Теоретический материал, объяснения',
        ),
      MaterialTemplateType.example => (
          Icons.code,
          Colors.green,
          'Пример кода',
          'Код с пояснениями и комментариями',
        ),
      MaterialTemplateType.task => (
          Icons.assignment,
          Colors.orange,
          'Практическое задание',
          'Задача для самостоятельного решения',
        ),
      MaterialTemplateType.visualization => (
          Icons.image,
          Colors.purple,
          'Визуализация',
          'Схема, диаграмма или иллюстрация',
        ),
    };
  }
}
