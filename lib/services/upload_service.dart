import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/upload_result.dart';
import '../services/api_client.dart';

const _extToMime = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
  '.mp4': 'video/mp4',
  '.mov': 'video/quicktime',
};

class UploadService {
  static final UploadService instance = UploadService._();
  UploadService._();

  Future<UploadResult> uploadFile(XFile file, UploadFolder folder) async {
    final config = uploadFolderConfigs[folder]!;
    final fileName = file.name;
    final ext = _getExtension(fileName).toLowerCase();
    final mimeType = _extToMime[ext];

    if (mimeType == null || !config.allowedMimeTypes.contains(mimeType)) {
      throw UploadValidationException(
        'Unsupported file type. Please select a JPEG, PNG, WebP, or MP4 file.',
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > config.maxSizeBytes) {
      final maxMB = config.maxSizeBytes ~/ (1024 * 1024);
      throw UploadValidationException(
        'File is too large. Maximum size is $maxMB MB.',
      );
    }

    // Direct multipart upload to local backend
    try {
      final resp = await ApiClient().uploadMultipart(
        '/api/v1/media/upload',
        File(file.path),
        queryParams: {'folder': config.folderName},
      );
      if (!resp.isSuccess || resp.data == null) {
        throw UploadNetworkException();
      }
      return UploadResult(
        fileKey: resp.data!['file_key'] as String,
        publicUrl: resp.data!['public_url'] as String,
      );
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      if (e is UploadValidationException || e is UploadNetworkException) rethrow;
      throw UploadNetworkException();
    }
  }

  String _getExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot);
  }
}
