import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'obsecure_password_provider.g.dart';

@riverpod
class ObsecurePassword extends _$ObsecurePassword {
  @override
  bool build() {
    return true;
  }

  void toggle() {
    state = !state;
  }
}
