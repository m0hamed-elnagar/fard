import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Failure']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Failure']);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = 'No Internet Connection']);
}

class InvalidSurahNumberFailure extends Failure {
  const InvalidSurahNumberFailure([super.message = 'Invalid Surah Number']);
}

class InvalidAyahNumberFailure extends Failure {
  const InvalidAyahNumberFailure([super.message = 'Invalid Ayah Number']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}

class Result<T> extends Equatable {
  final T? data;
  final Failure? failure;

  const Result._({this.data, this.failure});

  factory Result.success(T data) => Result._(data: data);
  factory Result.failure(Failure failure) => Result._(failure: failure);

  bool get isSuccess => data != null;
  bool get isFailure => failure != null;

  R fold<R>(R Function(Failure failure) onError, R Function(T data) onSuccess) {
    if (isFailure) {
      return onError(failure!);
    } else {
      return onSuccess(data as T);
    }
  }

  @override
  List<Object?> get props => [data, failure];
}
