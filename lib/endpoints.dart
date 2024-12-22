
class ApiEndpoints {
  static const String baseUrl = "https://voiceforher-backend.vercel.app/api/v1";

  // Define your endpoints here
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String fetchData = "$baseUrl/fetchProfileData";
}
