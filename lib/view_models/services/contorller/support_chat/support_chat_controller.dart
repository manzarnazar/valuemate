import 'dart:async';

import 'package:get/get.dart';
import 'package:valuemate/models/support_chat/support_chat_models.dart';
import 'package:valuemate/repository/support_chat_repository.dart';
import 'package:valuemate/view_models/services/contorller/auth/user_prefrence_view_model.dart';

class SupportChatController extends GetxController {
  SupportChatController({SupportChatRepository? repository})
      : _repository = repository ?? SupportChatRepository();

  final SupportChatRepository _repository;

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<SupportChatRoom?> room = Rx<SupportChatRoom?>(null);
  final RxList<SupportChatMessage> messages =
      <SupportChatMessage>[].obs;

  Timer? _pollingTimer;
  bool _isFetchingMessages = false;

  Future<void> initChat() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final token = await _ensureToken();
      final response = await _repository.getOrCreateRoom(token);

      if (!response.status || response.room == null) {
        throw Exception(response.message ?? 'Unable to load chat room');
      }

      room.value = response.room;
      await fetchMessages();
    } catch (e) {
      errorMessage.value = e.toString();
      messages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMessages() async {
    if (_isFetchingMessages) return;
    try {
      _isFetchingMessages = true;
      final token = await _ensureToken();
      final response = await _repository.getMessages(token);

      if (!response.status) {
        if (response.message != null && response.message!.isNotEmpty) {
          errorMessage.value = response.message!;
        }
        return;
      }

      errorMessage.value = '';
      messages.assignAll(response.messages);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      _isFetchingMessages = false;
    }
  }

  Future<void> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    isSending.value = true;
    try {
      final token = await _ensureToken();
      final response = await _repository.sendMessage(token, trimmed);

      if (!response.status) {
        final error = response.message ?? 'Failed to send message';
        throw Exception(error);
      }

      await fetchMessages();
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isSending.value = false;
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    stopPolling();
    _pollingTimer = Timer.periodic(interval, (_) {
      fetchMessages();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<String> _ensureToken() async {
    final token = await UserPreference().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token missing');
    }
    return token;
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }
}

