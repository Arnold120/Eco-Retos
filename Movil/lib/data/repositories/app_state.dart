import 'package:equatable/equatable.dart';

enum AppStatus { initial, loading, success, failure, empty }

class AppState<T> extends Equatable {
  final AppStatus status;
  final T? data;
  final String? errorMessage;

  const AppState({
    this.status = AppStatus.initial,
    this.data,
    this.errorMessage,
  });

  const AppState.initial() : this(status: AppStatus.initial);
  const AppState.loading() : this(status: AppStatus.loading);
  const AppState.success(T data) : this(status: AppStatus.success, data: data);
  const AppState.failure(String message)
      : this(status: AppStatus.failure, errorMessage: message);
  const AppState.empty() : this(status: AppStatus.empty);

  AppState<T> copyWith({
    AppStatus? status,
    T? data,
    String? errorMessage,
  }) {
    return AppState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == AppStatus.loading;
  bool get isSuccess => status == AppStatus.success;
  bool get isFailure => status == AppStatus.failure;
  bool get isEmpty => status == AppStatus.empty;
  bool get isInitial => status == AppStatus.initial;

  @override
  List<Object?> get props => [status, data, errorMessage];
}
