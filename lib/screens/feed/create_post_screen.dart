// SCREEN: Create Post Screen | FEED-01
import '../../../utils/screen_logger.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/upload_result.dart';
import '../../services/post_service.dart';
import '../../services/upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> with ScreenLogMixin {
  @override
  String get screenId => 'Create Post Screen | FEED-01';

  XFile? _selectedFile;
  String? _mimeType;
  final _captionController = TextEditingController();
  bool _isUploading = false;
  String? _validationMessage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {bool video = false}) async {
    final picker = ImagePicker();
    XFile? file;
    if (video) {
      file = await picker.pickVideo(source: source);
      if (file != null) _mimeType = 'video/mp4';
    } else {
      file = await picker.pickImage(source: source);
      if (file != null) {
        final ext = file.name.toLowerCase().split('.').last;
        _mimeType = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp' : 'image/jpeg';
      }
    }
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _validationMessage = null;
      });
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () { Navigator.pop(ctx); _pickMedia(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () { Navigator.pop(ctx); _pickMedia(ImageSource.gallery, video: true); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () { Navigator.pop(ctx); _pickMedia(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleShare() async {
    final caption = _captionController.text.trim();
    if (_selectedFile == null && caption.isEmpty) {
      setState(() => _validationMessage = 'Add a photo, video, or caption to share.');
      return;
    }

    setState(() { _isUploading = true; _validationMessage = null; });

    try {
      String? mediaUrl;
      String? mediaType;

      if (_selectedFile != null) {
        final result = await UploadService.instance.uploadFile(_selectedFile!, UploadFolder.post);
        mediaUrl = result.publicUrl;
        mediaType = (_mimeType?.startsWith('video') == true) ? 'video' : 'image';
      }

      await PostService.instance.createPost(
        content: caption.isNotEmpty ? caption : null,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared successfully.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on UploadValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } on UploadNetworkException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Check your connection and try again.'), backgroundColor: Colors.red),
      );
    } on UploadExpiredException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload session expired. Please try again.'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final captionLength = _captionController.text.length;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _handleShare,
            child: _isUploading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media area
            GestureDetector(
              onTap: _showMediaPicker,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedFile == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to add photo or video', style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_mimeType?.startsWith('video') == true)
                              const Center(child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white70))
                            else
                              Image.network(_selectedFile!.path, fit: BoxFit.cover, width: double.infinity),
                            Positioned(
                              top: 8, right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white),
                                style: IconButton.styleFrom(backgroundColor: Colors.black45),
                                onPressed: () => setState(() { _selectedFile = null; _mimeType = null; }),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Caption
            TextField(
              controller: _captionController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterStyle: TextStyle(
                  color: captionLength > 450 ? Colors.red : Colors.grey,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (_validationMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_validationMessage!, style: const TextStyle(color: Colors.red)),
              ),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
