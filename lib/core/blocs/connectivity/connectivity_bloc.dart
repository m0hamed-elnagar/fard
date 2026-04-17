import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;

  ConnectivityBloc({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService,
        super(ConnectivityInitial()) {
    on<ConnectivityChanged>(_onConnectivityChanged);

    // Initial check
    _connectivityService.checkConnectivity().then((results) {
      add(ConnectivityChanged(results));
    });

    // Listen to stream
    _connectivityService.onConnectivityChanged.listen((results) {
      add(ConnectivityChanged(results));
    });
  }

  void _onConnectivityChanged(
      ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    final isConnected = !event.results.contains(ConnectivityResult.none);
    emit(ConnectivityStatus(isConnected));
  }
}
