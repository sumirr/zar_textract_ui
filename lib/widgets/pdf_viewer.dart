import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:async';
import 'dart:io';

class PdfViewer extends StatefulWidget {
  final File pdfFile;
  final String fileName;
  final bool isDarkMode;

  const PdfViewer({
    super.key,
    required this.pdfFile,
    required this.fileName,
    required this.isDarkMode,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  bool _showFullPreview = false;
  final GlobalKey _pdfPreviewKey = GlobalKey();

  void _togglePreview() {
    setState(() {
      _showFullPreview = !_showFullPreview;
    });
  }

  void _showFullscreenPdf(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PDFScreen(pdfFile: widget.pdfFile, fileName: widget.fileName),
      ),
    );
  }

  String _getFileSize() {
    final bytes = widget.pdfFile.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 10), // Fixed withValues
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _togglePreview,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showFullPreview ? 400 : 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                ),
              ),
              child: _showFullPreview
                  ? PDFView(
                      key: _pdfPreviewKey,
                      filePath: widget.pdfFile.path,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: 0,
                      fitPolicy: FitPolicy.BOTH,
                      preventLinkNavigation: false,
                      onRender: (pages) {
                        // PDF is rendered
                      },
                      onError: (error) {
                        // Handle error
                      },
                      onPageError: (page, error) {
                        // Handle page error
                      },
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 60,
                          color: Colors.red[600],
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            widget.fileName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getFileSize(),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    _showFullPreview ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: _togglePreview,
                  tooltip: _showFullPreview
                      ? 'Collapse preview'
                      : 'Expand preview',
                ),
                IconButton(
                  icon: Icon(
                    Icons.open_in_full,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _showFullscreenPdf(context),
                  tooltip: 'Open in full screen',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final File pdfFile;
  final String fileName;

  const PDFScreen({super.key, required this.pdfFile, required this.fileName});

  @override
  State<PDFScreen> createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          if (currentPage != null && pages != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '${currentPage! + 1}/$pages',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.pdfFile.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (totalPages) {
              setState(() {
                pages = totalPages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                    ? const Center(child: CircularProgressIndicator())
                    : Container()
              : Center(child: Text(errorMessage)),
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  child: const Icon(Icons.arrow_upward),
                  onPressed: () async {
                    if (currentPage! > 0) {
                      await snapshot.data!.setPage(currentPage! - 1);
                    }
                  },
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'next',
                  child: const Icon(Icons.arrow_downward),
                  onPressed: () async {
                    if (currentPage! < pages! - 1) {
                      await snapshot.data!.setPage(currentPage! + 1);
                    }
                  },
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
