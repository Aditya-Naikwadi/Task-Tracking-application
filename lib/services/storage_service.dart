import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  FirebaseStorage get _storage {
    try {
      return FirebaseStorage.instance;
    } catch (e) {
      debugPrint('FirebaseStorage.instance access failed: $e');
      rethrow;
    }
  }

  Future<String?> uploadTaskAttachment(String taskId, File file) async {
    try {
      final fileName = path.basename(file.path);
      final ref = _storage.ref().child('tasks/$taskId/attachments/$fileName');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload Error: $e');
      return null;
    }
  }

  Future<void> deleteAttachment(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      debugPrint('Delete Attachment Error: $e');
    }
  }
}
