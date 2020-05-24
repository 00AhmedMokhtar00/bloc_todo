import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'bloc.dart';
import '../models/todo.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosBloc({@required this.todosRepository});

  @override
  TodosState get initialState => TodosLoadInProgress();

  @override
  Stream<TodosState> mapEventToState(TodosEvent event) async* {
    if (event is TodosLoadSuccess) {
      yield* _mapTodosLoadedToState();
    } else if (event is TodoAdded) {
      yield* _mapTodoAddedToState(event);
    } else if (event is TodoUpdated) {
      yield* _mapTodoUpdatedToState(event);
    } else if (event is TodoDeleted) {
      yield* _mapTodoDeletedToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    }
  }

  Stream<TodosState> _mapTodosLoadedToState() async* {
    try {
      final todos = await this.todosRepository.loadTodos();
      yield TodosLoadedSuccess(
        todos.map(Todo.fromEntity).toList(),
      );
    } catch (_) {
      yield TodosLoadFailure();
    }
  }

  Stream<TodosState> _mapTodoAddedToState(TodoAdded event) async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = List.from((state as TodosLoadedSuccess).todos)
        ..add(event.todo);
      yield TodosLoadedSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodoUpdatedToState(TodoUpdated event) async* {
    if (state is TodosLoadedSuccess) {
      final List<Todo> updatedTodos = (state as TodosLoadedSuccess).todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();
      yield TodosLoadedSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodoDeletedToState(TodoDeleted event) async* {
    if (state is TodosLoadedSuccess) {
      final updatedTodos = (state as TodosLoadedSuccess)
          .todos
          .where((todo) => todo.id != event.todo.id)
          .toList();
      yield TodosLoadedSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapToggleAllToState() async* {
    if (state is TodosLoadSuccess) {
      final allComplete =
      (state as TodosLoadedSuccess).todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = (state as TodosLoadedSuccess)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodosLoadedSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapClearCompletedToState() async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
      (state as TodosLoadedSuccess).todos.where((todo) => !todo.complete).toList();
      yield TodosLoadedSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }
}
