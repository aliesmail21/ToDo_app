import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/model/task.dart';
import 'package:flutter_application_1/services/task_storage_service.dart';

class TaskController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final tasks = <Task>[].obs;
  final isLoading = false.obs;
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      userName.value = user.displayName ?? user.email?.split('@')[0] ?? 'User';
    }
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final loadedTasks = await TaskStorageService.loadTasks(user.uid);
        tasks.assignAll(loadedTasks);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        tasks.add(task);
        await TaskStorageService.saveTasks(user.uid, tasks);
        Get.snackbar(
          'Success',
          'Task added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateTask(Task task, int index) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        tasks[index] = task;
        await TaskStorageService.saveTasks(user.uid, tasks);
        Get.snackbar(
          'Success',
          'Task updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteTask(int index) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        tasks.removeAt(index);
        await TaskStorageService.saveTasks(user.uid, tasks);
        Get.snackbar(
          'Success',
          'Task deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleTaskCompletion(int index) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        tasks[index].isCompleted = !tasks[index].isCompleted;
        await TaskStorageService.saveTasks(user.uid, tasks);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
