import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/security_repository.dart';
part 'security_providers.g.dart';
@Riverpod(keepAlive: true)
SecurityRepository securityRepository(SecurityRepositoryRef ref) => SecurityRepository();
