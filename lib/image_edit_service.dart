import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageEditProvider =
StateNotifierProvider.autoDispose<ImageEditService, ImageEditState>((ref) {
  return ImageEditService();
});

class ImageEditService extends StateNotifier<ImageEditState> {
  ImageEditService()
      : super(ImageEditState(
      editType: EditType.eraser, eraserPath: [], paintPath: []));

  PlaygroundEraserCanvasPath _currentPath =
  PlaygroundEraserCanvasPath(drawPoints: []);

  void startEdit(Offset position) {
    _currentPath = PlaygroundEraserCanvasPath(drawPoints: [position]);
    if (state.editType == EditType.eraser) {
      _editingHistory.add(EditType.eraser);
      List<PlaygroundEraserCanvasPath> tempList = List.from(state.eraserPath);
      tempList.add(_currentPath);
      state = state.copyWith(eraserPath: tempList);
    } else {
      _editingHistory.add(EditType.paint);
      List<PlaygroundEraserCanvasPath> tempList = List.from(state.paintPath);
      tempList.add(_currentPath);
      state = state.copyWith(paintPath: tempList);
    }
  }

  void updateEdit(Offset position) {
    _currentPath.drawPoints.add(position);
    if (state.editType == EditType.eraser) {
      List<PlaygroundEraserCanvasPath> tempList = List.from(state.eraserPath);
      tempList.last = _currentPath;
      state = state.copyWith(eraserPath: tempList);
    } else {
      List<PlaygroundEraserCanvasPath> tempList = List.from(state.paintPath);
      tempList.last = _currentPath;
      state = state.copyWith(paintPath: tempList);
    }
  }

  List<EditType> _editingHistory = [];

  void undo() {
    if (_editingHistory.isEmpty) return;
    final historyLast = _editingHistory.last;
    if (historyLast == EditType.eraser) {
      List<PlaygroundEraserCanvasPath> tempList = List.from(state.eraserPath);
      tempList.removeLast();
      state = state.copyWith(eraserPath: tempList);
    } else {
      List<PlaygroundEraserCanvasPath> tempList = List.from(state.paintPath);
      tempList.removeLast();
      state = state.copyWith(paintPath: tempList);
    }
    _editingHistory.removeLast();
  }

  void updateEditType() {
    state = state.copyWith(
      editType:
      state.editType == EditType.eraser ? EditType.paint : EditType.eraser,
    );
  }
}

class PlaygroundEraserCanvasPath {
  final List<Offset> drawPoints;

  PlaygroundEraserCanvasPath({
    required this.drawPoints,
  });
}

@immutable
class ImageEditState {
  EditType editType;
  List<PlaygroundEraserCanvasPath> eraserPath;
  List<PlaygroundEraserCanvasPath> paintPath;

  ImageEditState({
    required this.editType,
    required this.eraserPath,
    required this.paintPath,
  });

  ImageEditState copyWith({
    EditType? editType,
    List<PlaygroundEraserCanvasPath>? eraserPath,
    List<PlaygroundEraserCanvasPath>? paintPath,
  }) {
    return ImageEditState(
      editType: editType ?? this.editType,
      eraserPath: eraserPath ?? this.eraserPath,
      paintPath: paintPath ?? this.paintPath,
    );
  }
}

enum EditType {
  eraser,
  paint,
}