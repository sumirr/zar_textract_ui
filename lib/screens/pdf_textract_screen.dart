import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/pdf_viewer.dart';
import '../widgets/extracted_text_display.dart';

class PdfTextractScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final VoidCallback onNavigateBack;
  final VoidCallback onNavigateToImages;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onSignOut;

  const PdfTextractScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.onNavigateBack,
    required this.onNavigateToImages,
    required this.onNavigateToHistory,
    required this.onNavigateToProfile,
    required this.onSignOut,
  });

  @override
  State<PdfTextractScreen> createState() => _PdfTextractScreenState();
}

class _PdfTextractScreenState extends State<PdfTextractScreen> {
  File? _pdfFile;
  String? _fileName;
  String? _extractedText;
  String? _errorMessage;
  bool _isLoading = false;
  String _userEmail = '';
  final ThemeService _themeService = ThemeService();
  final GlobalKey _extractedTextKey = GlobalKey();

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

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null && mounted) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _extractedText = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _uploadAndExtractText() async {
    if (_pdfFile == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please select a PDF file first.';
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
      final restOperation = Amplify.API.post(
        '/presigned-url',
        body: HttpPayload.json(
          jsonEncode({'userId': widget.userId, 'fileType': 'application/pdf'}),
        ),
      );
      final response = await restOperation.response;
      final jsonResponse = jsonDecode(response.decodeBody());

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to get pre-signed URL: ${jsonResponse['error']}',
        );
      }

      final String presignedUrl = jsonResponse['presignedUrl'];
      final String documentId = jsonResponse['documentId'];
      final String userIdFromLambda = jsonResponse['userId'];

      final bytes = await _pdfFile!.readAsBytes();
      final responseUpload = await http.put(
        Uri.parse(presignedUrl),
        headers: {'Content-Type': 'application/pdf'},
        body: bytes,
      );

      if (responseUpload.statusCode != 200) {
        throw Exception('Failed to upload PDF to S3');
      }

      await Future.delayed(const Duration(seconds: 8));

      final getTextOperation = Amplify.API.get(
        '/documents/$documentId/$userIdFromLambda',
      );
      final getTextResponse = await getTextOperation.response;
      final textJsonResponse = jsonDecode(getTextResponse.decodeBody());

      if (getTextResponse.statusCode != 200) {
        throw Exception(
          'Failed to get extracted text: ${textJsonResponse['error']}',
        );
      }

      if (mounted) {
        setState(() {
          _extractedText = textJsonResponse['extractedText'] ?? 'No text found.';
        });
        _scrollToExtractedText();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('PDF Text Extraction'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 60,
                        color: Colors.red[600],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload PDF Document',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Extract text from PDF documents',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickPdf,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Select PDF File'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_pdfFile != null && _fileName != null) ...[
                  const SizedBox(height: 16),
                  PdfViewer(
                    pdfFile: _pdfFile!,
                    fileName: _fileName!,
                    isDarkMode: _themeService.isDarkMode,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
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
                      label: Text(
                        _isLoading ? 'Processing...' : 'Extract Text',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _themeService.isDarkMode
                          ? Colors.red[900]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _themeService.isDarkMode
                            ? Colors.red[700]!
                            : Colors.red[200]!,
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: _themeService.isDarkMode
                            ? Colors.red[300]
                            : Colors.red[700],
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

        );
      },
    );
  }
}
