import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile_screen.dart';
import 'pdf_textract_screen.dart';
import 'history_screen.dart';
import 'subscription_screen.dart';
import '../services/auth_service.dart';
import '../services/textract_service.dart';
import '../services/theme_service.dart';
import '../services/real_user_management_service.dart';
import '../models/subscription_model.dart';
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

class _ImageTextractScreenState extends State<ImageTextractScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
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
  
  // Subscription related state
  SubscriptionTier _currentTier = SubscriptionTier.free;
  Map<String, dynamic> _usageStats = {'used': 0, 'limit': 10, 'remaining': 10, 'percentage': 0.0};

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadUserSubscriptionInfo();
  }

  Future<void> _loadUserEmail() async {
    final userInfo = await AuthService.getCurrentUserInfo();
    if (userInfo != null) {
      setState(() {
        _userEmail = userInfo['email'];
      });
    }
  }

  Future<void> _loadUserSubscriptionInfo() async {
    try {
      final limits = await RealUserManagementService.checkLimits(widget.userId);
      final profile = await RealUserManagementService.getUserProfile(widget.userId);
      
      setState(() {
        _currentTier = (profile['subscription'] as UserSubscription).tierInfo;
        _usageStats = {
          'used': limits.used,
          'limit': limits.monthlyLimit,
          'remaining': limits.remaining,
          'percentage': limits.usagePercentage,
        };
      });
    } catch (e) {
      // Handle error gracefully - use default values so app still works
      debugPrint('Failed to load subscription info: $e');
      setState(() {
        _currentTier = SubscriptionTier.free;
        _usageStats = {
          'used': 0,
          'limit': 10,
          'remaining': 10,
          'percentage': 0.0,
        };
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _imageMimeType = _getMimeType(image.path);
          _extractedText = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _uploadAndExtractText() async {
    if (_imageFile == null || _imageMimeType == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _extractedText = null;
    });

    try {
      final extractedText = await TextractService.uploadAndExtractText(
        imageFile: _imageFile!,
        imageMimeType: _imageMimeType!,
        userId: widget.userId,
      );

      setState(() {
        _extractedText = extractedText;
      });
      
      // Refresh usage statistics after successful extraction
      await _loadUserSubscriptionInfo();
      
      // Auto-scroll to extracted text with animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_extractedTextKey.currentContext != null) {
          Scrollable.ensureVisible(
            _extractedTextKey.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to extract text: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSubscription() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubscriptionScreen(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            actions: [
              // Add subscription button
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: _navigateToSubscription,
                  icon: Icon(
                    Icons.workspace_premium,
                    color: Colors.amber[600],
                    size: 20,
                  ),
                  label: Text(
                    'Plans',
                    style: TextStyle(
                      color: Colors.amber[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ),
            ],
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

          body: _buildCurrentScreen(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.green[600],
            unselectedItemColor: Colors.grey[600],
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: 'Images',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.picture_as_pdf),
                label: 'PDF',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
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
        return _buildImagesScreen();
    }
  }

  Widget _buildImagesScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section with usage info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ${widget.userName}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_currentTier.name} Plan - ${_currentTier.monthlyPageLimit} pages/month',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.document_scanner,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'This month: ${_usageStats['used']}/${_usageStats['limit']} pages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_usageStats['remaining']} left',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_usageStats['percentage'] as double) / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // File selection section
          const Text(
            'Select an image to extract text',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSelectionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
            ],
          ),

          if (_imageFile != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Colors.green[900]!.withValues(alpha: 0.3) : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _themeService.isDarkMode ? Colors.green[700]! : Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.image, color: _themeService.isDarkMode ? Colors.green[400] : Colors.green[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _imageFile!.path.split('/').last,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${(_imageFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(
                            color: _themeService.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _imageFile = null;
                        _imageMimeType = null;
                        _extractedText = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadAndExtractText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing...'),
                        ],
                      )
                    : const Text(
                        'Extract Text',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Colors.red[900]!.withValues(alpha: 0.3) : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _themeService.isDarkMode ? Colors.red[700]! : Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: _themeService.isDarkMode ? Colors.red[400] : Colors.red[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: _themeService.isDarkMode ? Colors.red[300] : Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Results section
          if (_extractedText != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Extracted Text',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              key: _extractedTextKey,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _themeService.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_snippet, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Extracted Text',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _extractedText!.isEmpty ? 'No text found in the image.' : _extractedText!,
                    style: TextStyle(
                      fontSize: 16,
                      color: _themeService.isDarkMode ? Colors.grey[200] : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _themeService.isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _themeService.isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _themeService.isDarkMode ? 0.3 : 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.green[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _themeService.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
