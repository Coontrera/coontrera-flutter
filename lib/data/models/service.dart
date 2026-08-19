import 'package:hive/hive.dart';

part 'service.g.dart';

@HiveType(typeId: 4)
class Service extends HiveObject {
  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.benefits,
    required this.ctaText,
    required this.iconAsset,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> benefits;

  @HiveField(4)
  String ctaText;

  @HiveField(5)
  String iconAsset;
}
