import 'package:flutter/widgets.dart';
import 'package:friflex_starter/features/material_builder/presentation/screens/material_builder_screen.dart';
import 'package:go_router/go_router.dart';

/// {@template MaterialBuilderRoutes}
/// Роуты для модуля создания учебных материалов
/// {@endtemplate}
abstract final class MaterialBuilderRoutes {
  /// Название роута главного экрана
  static const String materialBuilderScreenName = 'material_builder_screen';

  /// Путь роута главного экрана
  static const String _materialBuilderScreenPath = '/material-builder';

  /// Метод для построения ветки роутов по фиче профиля пользователя
  ///
  /// Принимает:
  /// - [routes] - вложенные роуты
  static StatefulShellBranch buildShellBranch({
    List<RouteBase> routes = const [],
    List<NavigatorObserver>? observers,
  }) => StatefulShellBranch(
    initialLocation: _materialBuilderScreenPath,
    observers: observers,
    routes: [
      GoRoute(
        path: _materialBuilderScreenPath,
        name: materialBuilderScreenName,
        builder: (context, state) => const MaterialBuilderScreen(),
        routes: routes,
      ),
    ],
  );
  /// Метод для построения роутов модуля
  ///
  /// Принимает:
  /// - [routes] - вложенные роуты
  /// - [observers] - наблюдатели навигации
  static GoRoute buildRoutes({
    List<RouteBase> routes = const [],
    List<NavigatorObserver>? observers,
  }) =>
      GoRoute(
        path: _materialBuilderScreenPath,
        name: materialBuilderScreenName,
        builder: (context, state) => const MaterialBuilderScreen(),
        routes: routes,
      );
}
