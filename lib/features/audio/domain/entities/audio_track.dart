import 'package:equatable/equatable.dart';

class AudioTrack extends Equatable {
  final String remoteUrl;
  final String localPath;
  final bool isDownloaded;

  const AudioTrack({
    required this.remoteUrl,
    required this.localPath,
    required this.isDownloaded,
  });

  @override
  List<Object?> get props => [remoteUrl, localPath, isDownloaded];
}
