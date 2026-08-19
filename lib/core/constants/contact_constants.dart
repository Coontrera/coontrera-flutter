abstract final class ContactConstants {
  static const String whatsappPhoneE164 = '5516994593131';
  static const String whatsappDisplay = '(16) 99459-3131';
  static const String instagramHandle = '@contrera.pilatesefisioterapia';
  static const String instagramUrl =
      'https://www.instagram.com/contrera.pilatesefisioterapia/';
  static const String addressLine = 'R. 9 de Julho, 795';
  static const String cityLine = 'Santa Ernestina - SP';
  static const String zipCode = '15970-000';
  static const String mapsQuery =
      'R. 9 de Julho, 795, Santa Ernestina - SP, 15970-000';

  static String whatsappUrl([String message = 'Olá! Gostaria de mais informações.']) {
    final encoded = Uri.encodeComponent(message);
    return 'https://api.whatsapp.com/send?phone=$whatsappPhoneE164&text=$encoded';
  }

  static String get mapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapsQuery)}';
}
