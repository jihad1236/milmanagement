class ApiConstants {
  static const String baseUrl = 'https://jahidtestmysite.pythonanywhere.com';

  // Correct string interpolation for the register endpoint
  static const String register = '$baseUrl/auth/register/register_user/';
  static const String verifyOtp = '$baseUrl/auth/register/verify-otp/';
  static const String login = '$baseUrl/auth/login/';
  static const String forgotPassword =
      '$baseUrl/auth/password/forgot/request-otp/';
  static const String forgotVerifyOtp =
      '$baseUrl/auth/password/forgot/verify-otp/';
  
  // Collection endpoint
  // static const String discoverCollection = '$baseUrl/explore/city_group/';
static const String discoverCollection = '$baseUrl/explore/collection/';
  static const String favouritesCollection = '$baseUrl/explore/favorite/';
  static const String savedToursCollection = '$baseUrl/tour/saved/all/';
  static const String recentFindsCollection = '$baseUrl/tour/all/';
  static String collectionDetails(int id) => '$baseUrl/explore/explore/$id/';


  static const String landmarkDetect =
      'https://benkelly864-ai.onrender.com/api/v1/landmark/detect';
  static const String exploreCreate = '$baseUrl/explore/explore/';
  static const String resetPassword = '$baseUrl/auth/password/reset/';
  static const String googleSocialLogin = '$baseUrl/auth/social/google/';
  static const String privacy = '$baseUrl/auth/privacy/';
  static const String customerProfile = '$baseUrl/auth/customer/profile/';
  static const String settings = '$baseUrl/auth/settings/';
  static const String plans = '$baseUrl/payment/plans/';
  static const String createPayment = '$baseUrl/payment/create/';
}
