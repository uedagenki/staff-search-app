enum UploadFolder {
  avatar,
  portfolio,
  post,
  story,
  chat,
  introVideo,
}

class UploadFolderConfig {
  final String folderName;
  final int maxSizeBytes;
  final List<String> allowedMimeTypes;

  const UploadFolderConfig({
    required this.folderName,
    required this.maxSizeBytes,
    required this.allowedMimeTypes,
  });
}

const uploadFolderConfigs = {
  UploadFolder.avatar: UploadFolderConfig(
    folderName: 'avatars',
    maxSizeBytes: 5 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
  ),
  UploadFolder.portfolio: UploadFolderConfig(
    folderName: 'portfolio',
    maxSizeBytes: 10 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
  ),
  UploadFolder.post: UploadFolderConfig(
    folderName: 'posts',
    maxSizeBytes: 100 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'video/mp4'],
  ),
  UploadFolder.story: UploadFolderConfig(
    folderName: 'stories',
    maxSizeBytes: 50 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'video/mp4'],
  ),
  UploadFolder.chat: UploadFolderConfig(
    folderName: 'chat',
    maxSizeBytes: 10 * 1024 * 1024,
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
  ),
  UploadFolder.introVideo: UploadFolderConfig(
    folderName: 'intro_videos',
    maxSizeBytes: 100 * 1024 * 1024,
    allowedMimeTypes: ['video/mp4', 'video/quicktime'],
  ),
};

class UploadResult {
  final String fileKey;
  final String publicUrl;

  const UploadResult({required this.fileKey, required this.publicUrl});
}

class UploadValidationException implements Exception {
  final String message;
  UploadValidationException(this.message);
  @override
  String toString() => message;
}

class UploadNetworkException implements Exception {
  @override
  String toString() => 'Upload failed. Check your connection and try again.';
}

class UploadExpiredException implements Exception {
  @override
  String toString() => 'Upload session expired. Please try again.';
}
