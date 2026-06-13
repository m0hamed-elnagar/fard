import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:fard/core/services/connectivity_service.dart';

// Events
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();
  @override
  List<Object> get props => [];
}

class ConnectivityChanged extends ConnectivityEvent {
  final List<ConnectivityResult> results;
  const ConnectivityChanged(this.results);
  @override
  List<Object> get props => [results];
}

// States
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();
  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityStatus extends ConnectivityState {
  final bool isConnected;
  const ConnectivityStatus(this.isConnected);
  @override
  List<Object> get props => [isConnected];
}

// BLoC
@injectable
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityBloc({required this._connectivityService})
    : super(ConnectivityInitial()) {
    on<ConnectivityChanged>(_onConnectivityChanged);

    // Initial check
    _connectivityService.checkConnectivity().then((results) {
      if (!isClosed) {
        add(ConnectivityChanged(results));
      }
    });

    // Listen to stream
    _subscription = _connectivityService.onConnectivityChanged.listen((results) {
      if (!isClosed) {
        add(ConnectivityChanged(results));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<ConnectivityState> emit,
  ) async {
    final isConnected = await _connectivityService.hasNetwork();
    if (!isClosed) {
      emit(ConnectivityStatus(isConnected));
    }
  }
}
