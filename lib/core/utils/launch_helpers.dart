import 'package:url_launcher/url_launcher.dart';

abstract final class LaunchHelpers {
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
