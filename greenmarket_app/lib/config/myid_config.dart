class MyIDConfig {
  // Asosiy URL - PRODUCTION
  static const String baseUrl = 'https://api.myid.uz';

  // Sizning ma'lumotlaringiz
  static const String clientId =
      'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
  static const String clientSecret =
      'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
  static const String clientHashId = 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c';

  // Client Hash (o'zgartirmang)
  static const String clientHash = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''';

  // API endpointlari
  static const String authEndpoint = '$baseUrl/oauth/authorize';
  static const String tokenEndpoint = '$baseUrl/oauth/token';
  static const String userInfoEndpoint = '$baseUrl/api/v1/user';

  // Callback URL (o'z ilovangiz uchun sozlang)
  static const String redirectUri = 'greenmarket://callback';

  // Scope (qaysi ma'lumotlarni so'ramoqchisiz)
  static const String scope = 'openid profile email phone';
}
