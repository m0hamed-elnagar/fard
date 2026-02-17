import 'package:equatable/equatable.dart';
import 'package:fard/core/errors/failure.dart';

class SurahNumber extends Equatable {
  final int value;
  
  const SurahNumber._(this.value);

  static Result<SurahNumber> create(int value) {
    if (value < 1 || value > 114) {
      return Result.failure(const InvalidSurahNumberFailure());
    }
    return Result.success(SurahNumber._(value));
  }

  @override
  List<Object> get props => [value];
}
