import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersNotifier extends StateNotifier<Map<String, dynamic>> {
  UsersNotifier() : super({});
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, Map<String, dynamic>>(
        (ref) => UsersNotifier());
