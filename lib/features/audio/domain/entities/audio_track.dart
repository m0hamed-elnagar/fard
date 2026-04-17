import 'dart:io';
import 'package:equatable/equatable.dart';

class AudioTrack extends Equatable {
  final String remoteUrl;
  final String localPath;

  const AudioTrack({
    required this.remoteUrl,
    required this.localPath,
  });

  bool get isDownloaded => File(localPath).existsSync();

  @override
  List<Object?> get props => [remoteUrl, localPath];
}
