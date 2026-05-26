import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/content_model.dart';
import '../../models/app_user.dart';
import '../../services/content_service.dart';

class CreateContentScreen extends StatefulWidget {
  final AppUser admin;
  const CreateContentScreen({super.key, required this.admin});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _arabicController = TextEditingController();
  final _contentService = ContentService();

  ContentType _selectedType = ContentType.text;
  File? _pickedFile;
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _arabicController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    File? file;
    switch (_selectedType) {
      case ContentType.image:
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked != null) file = File(picked.path);
        break;
      case ContentType.audio:
      case ContentType.video:
        final result = await FilePicker.platform.pickFiles(
          type: _selectedType == ContentType.audio
              ? FileType.audio
              : FileType.video,
        );
        if (result != null && result.files.single.path != null) {
          file = File(result.files.single.path!);
        }
        break;
      case ContentType.text:
        break;
    }
    if (file != null) setState(() => _pickedFile = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType != ContentType.text && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a media file')),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      await _contentService.createCard(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: _selectedType,
        authorId: widget.admin.uid,
        arabic: _arabicController.text.trim().isEmpty
            ? null
            : _arabicController.text.trim(),
        mediaFile: _pickedFile,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content type selector
              Text('Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _TypeSelector(
                selected: _selectedType,
                onChanged: (t) => setState(() {
                  _selectedType = t;
                  _pickedFile = null;
                }),
              ),
              const SizedBox(height: 20),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              // Body / description
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Text / Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Text is required' : null,
              ),
              const SizedBox(height: 16),
              // Arabic (optional)
              TextFormField(
                controller: _arabicController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'Arabic text (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Media picker (shown only when not text)
              if (_selectedType != ContentType.text) ...[
                Text('Media file', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _MediaPicker(
                  type: _selectedType,
                  file: _pickedFile,
                  onPick: _pickMedia,
                ),
                const SizedBox(height: 20),
              ],
              // Submit
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _uploading ? null : _submit,
                  icon: _uploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(_uploading ? 'Uploading...' : 'Publish Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final ContentType selected;
  final ValueChanged<ContentType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const types = [
      (ContentType.text, Icons.text_fields, 'Text'),
      (ContentType.image, Icons.image_outlined, 'Image'),
      (ContentType.audio, Icons.audiotrack_outlined, 'Audio'),
      (ContentType.video, Icons.videocam_outlined, 'Video'),
    ];

    return Row(
      children: types.map((t) {
        final isSelected = selected == t.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onChanged(t.$1),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1B5E20)
                      : Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(t.$2,
                        color: isSelected ? Colors.white : Colors.grey[400]),
                    const SizedBox(height: 4),
                    Text(
                      t.$3,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MediaPicker extends StatelessWidget {
  final ContentType type;
  final File? file;
  final VoidCallback onPick;

  const _MediaPicker({required this.type, this.file, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: file != null
            ? (type == ContentType.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type == ContentType.audio
                              ? Icons.audiotrack
                              : Icons.videocam,
                          color: Colors.green[400],
                          size: 36,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          file!.path.split('/').last,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, color: Colors.grey[500], size: 36),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to pick ${type.name} file',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
      ),
    );
  }
}
