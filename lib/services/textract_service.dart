import 'dart:io';

// Abstract interface for document text extraction
// Implement this with your preferred text extraction service

abstract class TextractService {
  Future<String> extractTextFromImage(File imageFile, String userId);
  Future<String> extractTextFromPdf(File pdfFile, String userId);
}
