import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';

class CustomFilePicker extends StatefulWidget {
  final Directory? initialDirectory;

  const CustomFilePicker({super.key, this.initialDirectory});

  @override
  State<CustomFilePicker> createState() => _CustomFilePickerState();
}

class _CustomFilePickerState extends State<CustomFilePicker> {
  late Directory _currentDir;
  List<FileSystemEntity> _files = [];
  final Set<String> _selectedPaths = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentDir =
        widget.initialDirectory ??
        (Platform.isAndroid
            ? Directory('/storage/emulated/0')
            : Directory(Platform.environment['USERPROFILE'] ?? '/'));
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        final entities = _currentDir.listSync()
          ..sort((a, b) {
            // Sort directories first, then files
            var isADir = a is Directory;
            var isBDir = b is Directory;
            if (isADir && !isBDir) return -1;
            if (!isADir && isBDir) return 1;
            return a.path.toLowerCase().compareTo(b.path.toLowerCase());
          });

        setState(() {
          _files = entities;
        });
      }
    } catch (e) {
      debugPrint("Error loading files: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateUp() {
    final parent = _currentDir.parent;
    if (parent.path != _currentDir.path) {
      setState(() => _currentDir = parent);
      _loadFiles();
    }
  }

  void _openDirectory(Directory dir) {
    setState(() => _currentDir = dir);
    _loadFiles();
  }

  void _toggleSelection(File file) {
    setState(() {
      if (_selectedPaths.contains(file.path)) {
        _selectedPaths.remove(file.path);
      } else {
        _selectedPaths.add(file.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Files'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentDir.path == '/storage/emulated/0' ||
                _currentDir.path ==
                    (Platform.environment['USERPROFILE'] ?? '/')) {
              Navigator.pop(context);
            } else {
              _navigateUp();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: _selectedPaths.isNotEmpty
                ? () => Navigator.pop(context, _selectedPaths.toList())
                : null,
            child: Text(
              'Done (${_selectedPaths.length})',
              style: TextStyle(
                color: _selectedPaths.isNotEmpty ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Path Header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            width: double.infinity,
            child: Text(
              _currentDir.path,
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final entity = _files[index];
                      final name = path.basename(entity.path);
                      final isDir = entity is Directory;
                      final isSelected = _selectedPaths.contains(entity.path);

                      if (name.startsWith('.'))
                        return const SizedBox.shrink(); // Hide hidden files

                      return ListTile(
                        leading: Icon(
                          isDir ? Icons.folder : Icons.insert_drive_file,
                          color: isDir ? Colors.amber : Colors.blueGrey,
                          size: 30,
                        ),
                        title: Text(name),
                        trailing: isDir
                            ? const Icon(Icons.chevron_right)
                            : Checkbox(
                                value: isSelected,
                                onChanged: (val) =>
                                    _toggleSelection(entity as File),
                              ),
                        onTap: () {
                          if (isDir) {
                            _openDirectory(entity as Directory);
                          } else {
                            _toggleSelection(entity as File);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
