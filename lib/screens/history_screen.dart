import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class HistoryScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onNavigateBack;
  final VoidCallback onNavigateToImages;
  final VoidCallback onNavigateToPdf;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onSignOut;

  const HistoryScreen({
    super.key,
    required this.userName,
    required this.onNavigateBack,
    required this.onNavigateToImages,
    required this.onNavigateToPdf,
    required this.onNavigateToProfile,
    required this.onSignOut,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _userEmail = '';
  final ThemeService _themeService = ThemeService();

  final List<Map<String, dynamic>> _mockHistory = [
    {
      'id': '1',
      'fileName': 'Receipt_2024.jpg',
      'type': 'image',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'preview': 'Total: \$45.99\nStore: Amazon\nDate: 2024-01-15',
    },
    {
      'id': '2',
      'fileName': 'Contract.pdf',
      'type': 'pdf',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'preview': 'This agreement is made between...',
    },
    {
      'id': '3',
      'fileName': 'Invoice_001.png',
      'type': 'image',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'preview': 'Invoice #001\nAmount: \$1,250.00\nDue: 2024-02-01',
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Extraction History'),
          ),
          body: _mockHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No extractions yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your text extractions will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mockHistory.length,
                  itemBuilder: (context, index) {
                    final item = _mockHistory[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: item['type'] == 'pdf' 
                              ? Colors.red[100] 
                              : Colors.blue[100],
                          child: Icon(
                            item['type'] == 'pdf' 
                                ? Icons.picture_as_pdf 
                                : Icons.image,
                            color: item['type'] == 'pdf' 
                                ? Colors.red[600] 
                                : Colors.blue[600],
                          ),
                        ),
                        title: Text(
                          item['fileName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(item['date']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['preview'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Full Text'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'copy',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 18),
                                  SizedBox(width: 8),
                                  Text('Copy Text'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'view':
                                _showFullText(context, item);
                                break;
                              case 'copy':
                                // Copy to clipboard functionality
                                break;
                              case 'delete':
                                _deleteItem(index);
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),

        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showFullText(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['fileName']),
        content: SingleChildScrollView(
          child: SelectableText(item['preview']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int index) {
    if (mounted) {
      setState(() {
        _mockHistory.removeAt(index);
      });
    }
  }
}