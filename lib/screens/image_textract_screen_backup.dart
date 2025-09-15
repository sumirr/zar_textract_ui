import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile_screen.dart';
import 'pdf_textract_screen.dart';
import 'history_screen.dart';
import '../services/auth_service.dart';
import '../services/textract_service.dart';
import '../services/theme_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/image_picker_section.dart';
import '../widgets/extracted_text_display.dart';
import '../widgets/zoomable_image.dart';

class ImageTextractScreen extends StatefulWidget {
  final String userName;
  final String userId;
  final VoidCallback onSignOut;

  const ImageTextractScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.onSignOut,
  });

  @override
  State<ImageTextractScreen> createState() => _ImageTextractScreenState();
}

class _ImageTextractScreenState extends State<ImageTextractScreen> {
  File? _imageFile;
  String? _imageMimeType;
  String? _extractedText;
  String? _errorMessage;
  bool _isLoading = false;
  int _currentIndex = 0;
  String _userEmail = '';
  final GlobalKey _extractedTextKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final userInfo = await AuthService.getCurrentUserInfo();
    if (userInfo != null && mounted) {
      setState(() {
        _userEmail = userInfo['email'];
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageMimeType = _inferMimeType(pickedFile);
          _extractedText = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to pick image. Please try again.';
        });
      }
    }
  }

  String? _inferMimeType(XFile pickedFile) {
    String? mimeType = pickedFile.mimeType;
    if (mimeType == null) {
      final extension = pickedFile.path.split('.').last.toLowerCase();
      if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      }
    }
    return mimeType;
  }

  Future<void> _uploadAndExtractText() async {
    if (_imageFile == null || _imageMimeType == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please select a valid image first.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _extractedText = null;
      });
    }

    try {
      final extractedText = await TextractService.uploadAndExtractText(
        imageFile: _imageFile!,
        imageMimeType: _imageMimeType!,
        userId: widget.userId,
      );

      if (mounted) {
        setState(() {
          _extractedText = extractedText;
        });
        _scrollToExtractedText();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToExtractedText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _extractedTextKey.currentContext != null) {
        Scrollable.ensureVisible(
          _extractedTextKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Widget _buildMainScreen() {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text('Text Extractor'),
          ),
          drawer: AppDrawer(
            userName: widget.userName,
            userEmail: _userEmail,
            isDarkMode: _themeService.isDarkMode,
            onProfileTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
            onToggleDarkMode: () {
              Navigator.pop(context);
              _themeService.toggleTheme();
            },
            onSignOut: () {
              Navigator.pop(context);
              widget.onSignOut();
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ImagePickerSection(
                  isDarkMode: _themeService.isDarkMode,
                  onPickImage: _pickImage,
                ),
              if (_imageFile != null) ...[
                const SizedBox(height: 16),
                ZoomableImage(
                  imageFile: _imageFile!,
                  isDarkMode: _themeService.isDarkMode,
                  height: _extractedText != null ? 150 : 200,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              backgroundColor: _themeService.isDarkMode ? Colors.black : Colors.white,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                leading: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: _themeService.isDarkMode ? Colors.white : Colors.black,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                title: Text(
                                  'Image Preview',
                                  style: TextStyle(
                                    color: _themeService.isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              body: Center(
                                child: InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 5.0,
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.zoom_in),
                        label: const Text('Preview'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _uploadAndExtractText,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.text_fields),
                        label: Text(_isLoading ? 'Processing...' : 'Extract Text'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _themeService.isDarkMode ? Colors.red[900] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _themeService.isDarkMode ? Colors.red[700]! : Colors.red[200]!,
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: _themeService.isDarkMode ? Colors.red[300] : Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (_extractedText != null) ...[
                const SizedBox(height: 16),
                ExtractedTextDisplay(
                  extractedText: _extractedText!,
                  isDarkMode: _themeService.isDarkMode,
                  widgetKey: _extractedTextKey,
                ),
              ],
            ],
          ),
        ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Images'),
              BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: 'PDF'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentIndex) {
      case 1:
        return PdfTextractScreen(
          userId: widget.userId,
          userName: widget.userName,
          onNavigateBack: () => setState(() => _currentIndex = 0),
          onNavigateToImages: () => setState(() => _currentIndex = 0),
          onNavigateToHistory: () => setState(() => _currentIndex = 2),
          onNavigateToProfile: () => setState(() => _currentIndex = 3),
          onSignOut: widget.onSignOut,
        );
      case 2:
        return HistoryScreen(
          userName: widget.userName,
          onNavigateBack: () => setState(() => _currentIndex = 0),
          onNavigateToImages: () => setState(() => _currentIndex = 0),
          onNavigateToPdf: () => setState(() => _currentIndex = 1),
          onNavigateToProfile: () => setState(() => _currentIndex = 3),
          onSignOut: widget.onSignOut,
        );
      case 3:
        return ProfileScreen(
          userName: widget.userName,
          userEmail: _userEmail,
          onNavigateBack: () => setState(() => _currentIndex = 0),
        );
      default:
        return _buildMainScreen();
    }
  }
}