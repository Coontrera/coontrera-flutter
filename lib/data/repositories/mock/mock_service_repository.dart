import 'package:hive/hive.dart';
import '../../models/service.dart';
import '../service_repository.dart';
import 'mock_latency.dart';

class MockServiceRepository implements ServiceRepository {
  MockServiceRepository({required this.servicesBox});

  final Box<Service> servicesBox;

  @override
  Future<List<Service>> getAll() async {
    await simulateLatency();
    return servicesBox.values.toList();
  }

  @override
  Future<Service?> getById(String id) async {
    await simulateLatency();
    return servicesBox.get(id);
  }
}
