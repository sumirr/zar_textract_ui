import 'package:flutter/material.dart';
import 'dart:io';

class ZoomableImage extends StatefulWidget {
  final File imageFile;
  final bool isDarkMode;
  final double height;

  const ZoomableImage({
    super.key,
    required this.imageFile,
    required this.isDarkMode,
    required this.height,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  final TransformationController _controller = TransformationController();

  void _showFullscreenImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          imageFile: widget.imageFile,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDarkMode ? Colors.grey[800] : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GestureDetector(
              onDoubleTap: _showFullscreenImage,
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1.0,
                maxScale: 3.0,
                child: Image.file(
                  widget.imageFile,
                  height: widget.height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                  onPressed: _showFullscreenImage,
                  tooltip: 'View fullscreen',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullscreenImageViewer extends StatefulWidget {
  final File imageFile;
  final bool isDarkMode;

  const FullscreenImageViewer({
    super.key,
    required this.imageFile,
    required this.isDarkMode,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  final TransformationController _controller = TransformationController();

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.zoom_out_map,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: _resetZoom,
            tooltip: 'Reset zoom',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.file(
            widget.imageFile,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}