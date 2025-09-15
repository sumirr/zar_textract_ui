import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExtractedTextDisplay extends StatefulWidget {
  final String extractedText;
  final bool isDarkMode;
  final GlobalKey widgetKey;

  const ExtractedTextDisplay({
    super.key,
    required this.extractedText,
    required this.isDarkMode,
    required this.widgetKey,
  });

  @override
  State<ExtractedTextDisplay> createState() => _ExtractedTextDisplayState();
}

class _ExtractedTextDisplayState extends State<ExtractedTextDisplay> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.extractedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Set background color based on dark mode
        backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.green,
        content: Text(
          'Text copied to clipboard',
          style: TextStyle(
            // Explicitly set text color for better contrast in dark mode
            color: widget.isDarkMode
                ? Colors.white
                : Colors.white, // Ensure white text for both modes
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      key: widget.widgetKey,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.1,
            ), // Corrected 'withValues' to 'withOpacity'
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extracted Text',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _textController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _textController.text.length,
                      );
                    },
                    icon: const Icon(Icons.select_all),
                    tooltip: 'Select all',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey[700] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Focus(
              child: TextField(
                controller: _textController,
                maxLines: null,
                contextMenuBuilder: (context, editableTextState) {
                  return AdaptiveTextSelectionToolbar.editableText(
                    editableTextState: editableTextState,
                  );
                },
                style: TextStyle(fontSize: 16, height: 1.6, color: textColor),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
