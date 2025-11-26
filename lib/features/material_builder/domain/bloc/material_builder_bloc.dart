import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friflex_starter/features/material_builder/domain/entity/material_template_entity.dart';
import 'package:friflex_starter/features/material_builder/domain/repository/i_material_builder_repository.dart';

part 'material_builder_event.dart';
part 'material_builder_state.dart';

/// {@template MaterialBuilderBloc}
/// Bloc для управления состоянием создания учебных материалов
/// {@endtemplate}
class MaterialBuilderBloc
    extends Bloc<MaterialBuilderEvent, MaterialBuilderState> {
  /// {@macro MaterialBuilderBloc}
  MaterialBuilderBloc(this._repository) : super(const MaterialBuilderInitialState()) {
    on<MaterialBuilderUploadDocumentEvent>(_onUploadDocument);
    on<MaterialBuilderProcessDocumentEvent>(_onProcessDocument);
    on<MaterialBuilderUpdateFragmentEvent>(_onUpdateFragment);
    on<MaterialBuilderGenerateOutputEvent>(_onGenerateOutput);
    on<MaterialBuilderLoadMaterialsEvent>(_onLoadMaterials);
  }

  final IMaterialBuilderRepository _repository;

  /// Обработчик загрузки документа
  Future<void> _onUploadDocument(
    MaterialBuilderUploadDocumentEvent event,
    Emitter<MaterialBuilderState> emit,
  ) async {
    try {
      emit(const MaterialBuilderLoadingState());
      final result = await _repository.uploadDocument(event.filePath);
      emit(MaterialBuilderDocumentUploadedState(material: result));
    } on Object catch (error, stackTrace) {
      emit(
        MaterialBuilderErrorState(
          message: 'Ошибка при загрузке документа',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      addError(error, stackTrace);
    }
  }

  /// Обработчик обработки документа через AI
  Future<void> _onProcessDocument(
    MaterialBuilderProcessDocumentEvent event,
    Emitter<MaterialBuilderState> emit,
  ) async {
    try {
      emit(const MaterialBuilderProcessingState());
      final result = await _repository.processDocument(
        documentId: event.documentId,
        content: event.content,
      );
      emit(MaterialBuilderProcessedState(material: result));
    } on Object catch (error, stackTrace) {
      emit(
        MaterialBuilderErrorState(
          message: 'Ошибка при обработке документа',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      addError(error, stackTrace);
    }
  }

  /// Обработчик обновления фрагмента
  Future<void> _onUpdateFragment(
    MaterialBuilderUpdateFragmentEvent event,
    Emitter<MaterialBuilderState> emit,
  ) async {
    try {
      await _repository.updateFragment(event.fragment);
      
      if (state is MaterialBuilderProcessedState) {
        final currentState = state as MaterialBuilderProcessedState;
        final updatedFragments = currentState.material.fragments.map((f) {
          return f.id == event.fragment.id ? event.fragment : f;
        }).toList();
        
        final updatedMaterial = ProcessedMaterialEntity(
          documentId: currentState.material.documentId,
          originalFileName: currentState.material.originalFileName,
          fragments: updatedFragments,
          processedAt: currentState.material.processedAt,
          metadata: currentState.material.metadata,
        );
        
        emit(MaterialBuilderProcessedState(material: updatedMaterial));
      }
    } on Object catch (error, stackTrace) {
      emit(
        MaterialBuilderErrorState(
          message: 'Ошибка при обновлении фрагмента',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      addError(error, stackTrace);
    }
  }

  /// Обработчик генерации финального документа
  Future<void> _onGenerateOutput(
    MaterialBuilderGenerateOutputEvent event,
    Emitter<MaterialBuilderState> emit,
  ) async {
    try {
      emit(const MaterialBuilderGeneratingState());
      final outputPath = await _repository.generateOutput(
        material: event.material,
        outputFormat: event.outputFormat,
      );
      emit(MaterialBuilderOutputGeneratedState(outputPath: outputPath));
    } on Object catch (error, stackTrace) {
      emit(
        MaterialBuilderErrorState(
          message: 'Ошибка при генерации документа',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      addError(error, stackTrace);
    }
  }

  /// Обработчик загрузки списка материалов
  Future<void> _onLoadMaterials(
    MaterialBuilderLoadMaterialsEvent event,
    Emitter<MaterialBuilderState> emit,
  ) async {
    try {
      emit(const MaterialBuilderLoadingState());
      final materials = await _repository.getProcessedMaterials();
      emit(MaterialBuilderMaterialsLoadedState(materials: materials));
    } on Object catch (error, stackTrace) {
      emit(
        MaterialBuilderErrorState(
          message: 'Ошибка при загрузке списка материалов',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      addError(error, stackTrace);
    }
  }
}
