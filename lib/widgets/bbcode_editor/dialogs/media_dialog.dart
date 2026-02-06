import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/knockout_api_service.dart';

/// Types of media that can be inserted
enum MediaType {
  image(
    'Image',
    'Enter the image URL',
    Icons.image,
    'https://example.com/image.jpg',
    true,
  ),
  video(
    'Video',
    'Enter the video URL',
    Icons.videocam,
    'https://example.com/video.mp4',
    true,
  ),
  youtube(
    'YouTube',
    'Enter the YouTube URL',
    Icons.play_circle_outline,
    'https://youtube.com/watch?v=...',
    false,
  ),
  twitter(
    'Twitter/X',
    'Enter the tweet URL',
    Icons.alternate_email,
    'https://twitter.com/user/status/...',
    false,
  ),
  reddit(
    'Reddit',
    'Enter the Reddit URL',
    Icons.forum,
    'https://reddit.com/r/...',
    false,
  ),
  twitch(
    'Twitch',
    'Enter the Twitch URL',
    Icons.live_tv,
    'https://twitch.tv/...',
    false,
  ),
  bluesky(
    'Bluesky',
    'Enter the Bluesky URL',
    Icons.cloud,
    'https://bsky.app/...',
    false,
  ),
  vimeo(
    'Vimeo',
    'Enter the Vimeo URL',
    Icons.ondemand_video,
    'https://vimeo.com/...',
    false,
  ),
  streamable(
    'Streamable',
    'Enter the Streamable URL',
    Icons.stream,
    'https://streamable.com/...',
    false,
  ),
  vocaroo(
    'Vocaroo',
    'Enter the Vocaroo URL',
    Icons.mic,
    'https://vocaroo.com/...',
    false,
  ),
  spotify(
    'Spotify',
    'Enter the Spotify URL',
    Icons.music_note,
    'https://open.spotify.com/...',
    false,
  ),
  soundcloud(
    'SoundCloud',
    'Enter the SoundCloud URL',
    Icons.headphones,
    'https://soundcloud.com/...',
    false,
  ),
  instagram(
    'Instagram',
    'Enter the Instagram URL',
    Icons.camera_alt,
    'https://instagram.com/p/...',
    false,
  ),
  tiktok(
    'TikTok',
    'Enter the TikTok URL',
    Icons.movie_creation,
    'https://tiktok.com/@user/video/...',
    false,
  ),
  tumblr(
    'Tumblr',
    'Enter the Tumblr URL',
    Icons.text_snippet,
    'https://tumblr.com/...',
    false,
  ),
  mastodon(
    'Mastodon',
    'Enter the Mastodon URL',
    Icons.public,
    'https://mastodon.social/@user/...',
    false,
  );

  final String title;
  final String hint;
  final IconData icon;
  final String placeholder;
  final bool supportsUpload;

  const MediaType(
    this.title,
    this.hint,
    this.icon,
    this.placeholder,
    this.supportsUpload,
  );
}

/// Result from the media dialog
class MediaDialogResult {
  final String url;
  final bool thumbnail;

  const MediaDialogResult({required this.url, this.thumbnail = false});
}

/// Shows a dialog to input a media URL or upload a file
Future<MediaDialogResult?> showMediaDialog(BuildContext context, MediaType type) {
  final api = KnockoutApiService();
  final canUpload = type.supportsUpload && api.isAuthenticated;

  return showDialog<MediaDialogResult>(
    context: context,
    builder: (context) => _MediaDialog(type: type, canUpload: canUpload),
  );
}

class _MediaDialog extends StatefulWidget {
  final MediaType type;
  final bool canUpload;

  const _MediaDialog({required this.type, required this.canUpload});

  @override
  State<_MediaDialog> createState() => _MediaDialogState();
}

class _MediaDialogState extends State<_MediaDialog> {
  late final TextEditingController _urlController;
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _api = KnockoutApiService();

  bool _isUploading = false;
  double _uploadProgress = 0;
  String? _uploadError;
  XFile? _selectedFile;
  bool _thumbnail = false;
  bool _hasPopped = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submitUrl() {
    if (_hasPopped) return;
    if (_formKey.currentState?.validate() ?? false) {
      _hasPopped = true;
      Navigator.of(context).pop(MediaDialogResult(
        url: _urlController.text.trim(),
        thumbnail: _thumbnail,
      ));
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _uploadError = null;
    });

    try {
      XFile? file;
      if (widget.type == MediaType.image) {
        file = await _imagePicker.pickImage(source: ImageSource.gallery);
      } else if (widget.type == MediaType.video) {
        file = await _imagePicker.pickVideo(source: ImageSource.gallery);
      }

      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
        await _uploadFile(file);
      }
    } catch (e) {
      setState(() {
        _uploadError = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _uploadFile(XFile file) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _uploadError = null;
    });

    try {
      String? url;
      if (widget.type == MediaType.image) {
        url = await _api.uploadImage(
          file,
          onProgress: (sent, total) {
            if (total > 0) {
              setState(() {
                _uploadProgress = sent / total;
              });
            }
          },
        );
      } else if (widget.type == MediaType.video) {
        url = await _api.uploadVideo(
          file,
          onProgress: (sent, total) {
            if (total > 0) {
              setState(() {
                _uploadProgress = sent / total;
              });
            }
          },
        );
      }

      if (url != null && mounted && !_hasPopped) {
        _hasPopped = true;
        Navigator.of(context).pop(MediaDialogResult(
          url: url,
          thumbnail: _thumbnail,
        ));
      } else if (mounted && !_hasPopped) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Upload failed - no URL returned';
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        String errorMessage = 'Upload failed';
        if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data.containsKey('error')) {
            errorMessage = data['error'].toString();
          } else if (data is String) {
            errorMessage = data;
          }
        } else if (e.message != null) {
          errorMessage = e.message!;
        }
        setState(() {
          _isUploading = false;
          _uploadError = errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Upload failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Insert ${widget.type.title}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.canUpload) ...[
              _buildUploadSection(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _buildUrlSection(),
            if (widget.type == MediaType.image) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _thumbnail,
                onChanged: _isUploading
                    ? null
                    : (value) => setState(() => _thumbnail = value ?? false),
                title: const Text('Thumbnail'),
                subtitle: const Text('Display as smaller preview'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isUploading ? null : _submitUrl,
          child: const Text('Insert URL'),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isUploading) ...[
          Text(
            'Uploading ${_selectedFile?.name ?? "file"}...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _uploadProgress),
          const SizedBox(height: 4),
          Text(
            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: Icon(
              widget.type == MediaType.image
                  ? Icons.photo_library
                  : Icons.video_library,
            ),
            label: Text(
              widget.type == MediaType.image
                  ? 'Upload from Gallery'
                  : 'Upload Video',
            ),
          ),
        ],
        if (_uploadError != null) ...[
          const SizedBox(height: 8),
          Text(
            _uploadError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildUrlSection() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _urlController,
        decoration: InputDecoration(
          labelText: 'URL',
          hintText: widget.type.placeholder,
          helperText: widget.type.hint,
          prefixIcon: Icon(widget.type.icon),
        ),
        keyboardType: TextInputType.url,
        autofocus: !widget.canUpload,
        enabled: !_isUploading,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a URL';
          }
          final uri = Uri.tryParse(value.trim());
          if (uri == null || !uri.hasScheme) {
            return 'Please enter a valid URL';
          }
          return null;
        },
        onFieldSubmitted: (_) => _submitUrl(),
      ),
    );
  }
}