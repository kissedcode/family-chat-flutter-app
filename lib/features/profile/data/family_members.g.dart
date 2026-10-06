// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_members.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyMembersHash() => r'c1a8bcb1e572ea98abd313b9d44aae59a1569bd8';

/// Все члены семьи с профилем в `users`, кроме текущего пользователя,
/// отсортированные по имени.
///
/// Copied from [familyMembers].
@ProviderFor(familyMembers)
final familyMembersProvider =
    AutoDisposeStreamProvider<List<UserProfile>>.internal(
  familyMembers,
  name: r'familyMembersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyMembersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyMembersRef = AutoDisposeStreamProviderRef<List<UserProfile>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
