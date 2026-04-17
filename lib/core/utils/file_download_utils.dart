import 'dart:io';
import 'dart:typed_data';

/// Utility class for safe and atomic file downloads.
class FileDownloadUtils {
  /// Writes [bytes] to a temporary file, verifies its integrity, and then moves
  /// it to [finalPath].
  ///
  /// [fileType] can be 'audio' or 'image' to apply specific header checks.
  /// Throws [FileSystemException] if verification fails.
  static Future<void> atomicWriteFile({
    required Uint8List bytes,
    required String finalPath,
    required String fileType,
  }) async {
    final tempPath = '$finalPath.tmp';
    final tempFile = File(tempPath);
    final finalFile = File(finalPath);

    // 1. Ensure parent directory exists
    final parentDir = finalFile.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    // 2. Perform validation before writing (optional, but good for early exit)
    _validateBytes(bytes, fileType);

    // 3. Atomic Write: Write to temp file
    await tempFile.writeAsBytes(bytes, flush: true);

    try {
      // 4. Post-write verification
      final length = await tempFile.length();
      if (length != bytes.length) {
        throw FileSystemException(
          'File size mismatch: Expected ${bytes.length}, got $length',
          tempPath,
        );
      }

      // 5. Final Rename (Atomic operation on most filesystems)
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(finalPath);
    } catch (e) {
      // Cleanup temp file on failure
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      rethrow;
    }
  }

  /// Appends [bytes] to an existing file at [path].
  /// Used for resumable downloads.
  static Future<void> appendToFile({
    required Uint8List bytes,
    required String path,
  }) async {
    final file = File(path);
    
    // 1. Ensure parent directory exists
    final parentDir = file.parent;
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }

    // 2. Open file for appending
    final raf = await file.open(mode: FileMode.append);
    try {
      await raf.writeFrom(bytes);
      await raf.flush();
    } finally {
      await raf.close();
    }
  }

  /// Safely gets the current size of a partially downloaded file without integrity checks.
  static Future<int> getExistingFileSizeBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    try {
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Checks if a file exists and meets basic audio integrity requirements.
  static Future<bool> isValidAudioFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;
    try {
      final length = await file.length();
      if (length < 10240) return false; // Min 10KB

      // Check header syncword
      final bytes = await file.openRead(0, 2).first;
      if (bytes.length < 2) return false;
      return bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
    } catch (e) {
      return false;
    }
  }

  /// Prunes all .tmp files in a given directory.
  static Future<void> pruneTempFiles(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      if (await dir.exists()) {
        final List<FileSystemEntity> entities = await dir.list().toList();
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.tmp')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // Ignore errors during pruning
    }
  }

  static void _validateBytes(Uint8List bytes, String fileType) {
    if (fileType == 'audio') {
      // MP3 Header Check: Minimum size 10 KB + syncword
      if (bytes.length < 10240) {
        throw const FileSystemException('MP3 file too small (less than 10 KB)');
      }
      // Check for MP3 Syncword: 0xFF, (next byte & 0xE0) == 0xE0
      if (bytes[0] != 0xFF || (bytes[1] & 0xE0) != 0xE0) {
        throw const FileSystemException('Invalid MP3 header (Syncword not found)');
      }
    } else if (fileType == 'image') {
      // PNG Header Check: Minimum size 1 KB + PNG signature
      if (bytes.length < 1024) {
        throw const FileSystemException('PNG file too small (less than 1 KB)');
      }
      // PNG Signature: 0x89 0x50 0x4E 0x47
      if (bytes[0] != 0x89 ||
          bytes[1] != 0x50 ||
          bytes[2] != 0x4E ||
          bytes[3] != 0x47) {
        throw const FileSystemException('Invalid PNG header (Signature mismatch)');
      }
    }
  }
}
