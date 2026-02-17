import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/tasks/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  // Create Task
  Future<void> createTask(TaskModel task) async {
    await _firestore.collection(_collection).doc(task.id).set(task.toMap());
  }

  // Update Task
  Future<void> updateTask(TaskModel task) async {
    await _firestore.collection(_collection).doc(task.id).update(task.toMap());
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collection).doc(taskId).delete();
  }

  // Get All Relevant Tasks (Owned + Assigned)
  Stream<List<TaskModel>> getUnifiedTasksStream(String userId) {
    // Combine two streams: one where ownerId == userId, one where assignedTo contains userId
    final ownedStream = _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: userId)
        .snapshots();

    // For now, returning owned stream. In production, combine with assignedStream
    /*
    final assignedStream = _firestore
        .collection(_collection)
        .where('assignedTo', arrayContains: userId)
        .snapshots();
    */

    // In a real production app, you might use RxDart for better stream combining
    // For now, we return the owned stream as primary, but we'll modify TaskProvider to handle both
    return ownedStream.map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromMap(doc.data())).toList();
    });
  }

  // Add Comment
  Future<void> addComment(String taskId, Map<String, dynamic> comment) async {
    await _firestore.collection(_collection).doc(taskId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }

  // Add Attachment URL
  Future<void> addAttachment(String taskId, String url) async {
    await _firestore.collection(_collection).doc(taskId).update({
      'attachments': FieldValue.arrayUnion([url]),
    });
  }
}
