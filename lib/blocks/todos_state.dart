import 'package:equatable/equatable.dart';
import '../models/todo.dart';

abstract class TodosState extends Equatable {
  const TodosState();

  @override
  List<Object> get props => [];
}

class TodosLoadInProgress extends TodosState {}

class TodosLoadedSuccess extends TodosState {
  final List<Todo> todos;

  const TodosLoadedSuccess([this.todos = const []]);

  @override
  List<Object> get props => [todos];

  @override
  String toString() => 'TodosLoadSuccess { todos: $todos }';
}

class TodosLoadFailure extends TodosState {}
