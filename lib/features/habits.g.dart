// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitService)
final habitServiceProvider = HabitServiceProvider._();

final class HabitServiceProvider
    extends $FunctionalProvider<HabitService, HabitService, HabitService>
    with $Provider<HabitService> {
  HabitServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitServiceHash();

  @$internal
  @override
  $ProviderElement<HabitService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HabitService create(Ref ref) {
    return habitService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitService>(value),
    );
  }
}

String _$habitServiceHash() => r'be4226255f47c769075b5b0f65bc48ad8c787e3a';

@ProviderFor(habits)
final habitsProvider = HabitsFamily._();

final class HabitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Habit>>,
          List<Habit>,
          Stream<List<Habit>>
        >
    with $FutureModifier<List<Habit>>, $StreamProvider<List<Habit>> {
  HabitsProvider._({
    required HabitsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitsHash();

  @override
  String toString() {
    return r'habitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Habit>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Habit>> create(Ref ref) {
    final argument = this.argument as String;
    return habits(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HabitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitsHash() => r'452c44537bc330e41a275ba006a745fb5a897095';

final class HabitsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Habit>>, String> {
  HabitsFamily._()
    : super(
        retry: null,
        name: r'habitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HabitsProvider call(String uid) =>
      HabitsProvider._(argument: uid, from: this);

  @override
  String toString() => r'habitsProvider';
}

@ProviderFor(HabitController)
final habitControllerProvider = HabitControllerProvider._();

final class HabitControllerProvider
    extends $AsyncNotifierProvider<HabitController, void> {
  HabitControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitControllerHash();

  @$internal
  @override
  HabitController create() => HabitController();
}

String _$habitControllerHash() => r'110896b3b1bd90d7150176b3f23298f1281fd1cd';

abstract class _$HabitController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
