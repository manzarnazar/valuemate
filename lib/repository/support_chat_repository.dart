import 'package:valuemate/data/network/base_api_services.dart';
import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/support_chat/support_chat_models.dart';

class SupportChatRepository {
  SupportChatRepository({BaseApiServices? apiServices})
      : _apiServices = apiServices ?? NetworkApiServices();

  final BaseApiServices _apiServices;

  static const String _baseUrl = 'https://valuma8.com/api';

  Future<SupportChatRoomResponse> getOrCreateRoom(String token) async {
    final response = await _apiServices.postApiWithToken(
      {},
      '$_baseUrl/support-chat/room',
      token,
    );
    return SupportChatRoomResponse.fromJson(
        response as Map<String, dynamic>);
  }

  Future<SupportChatMessagesResponse> getMessages(String token) async {
    final response = await _apiServices.getApiWithToken(
      '$_baseUrl/support-chat/messages',
      token,
    );
    return SupportChatMessagesResponse.fromJson(
        response as Map<String, dynamic>);
  }

  Future<SupportChatSendResponse> sendMessage(
    String token,
    String message,
  ) async {
    final response = await _apiServices.postApiWithToken(
      {
        'message': message,
      },
      '$_baseUrl/support-chat/send',
      token,
    );
    return SupportChatSendResponse.fromJson(
        response as Map<String, dynamic>);
  }
}

