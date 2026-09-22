// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contactService)
final contactServiceProvider = ContactServiceProvider._();

final class ContactServiceProvider
    extends $FunctionalProvider<ContactService, ContactService, ContactService>
    with $Provider<ContactService> {
  ContactServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactServiceHash();

  @$internal
  @override
  $ProviderElement<ContactService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContactService create(Ref ref) {
    return contactService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactService>(value),
    );
  }
}

String _$contactServiceHash() => r'5955c2a50993ed70eb950b749479e5ebb2770f96';

@ProviderFor(contacts)
final contactsProvider = ContactsFamily._();

final class ContactsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Contact>>,
          List<Contact>,
          Stream<List<Contact>>
        >
    with $FutureModifier<List<Contact>>, $StreamProvider<List<Contact>> {
  ContactsProvider._({
    required ContactsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'contactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$contactsHash();

  @override
  String toString() {
    return r'contactsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Contact>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Contact>> create(Ref ref) {
    final argument = this.argument as String;
    return contacts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$contactsHash() => r'2554cae6e69126f561925baa54e57122d52e3d19';

final class ContactsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Contact>>, String> {
  ContactsFamily._()
    : super(
        retry: null,
        name: r'contactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContactsProvider call(String uid) =>
      ContactsProvider._(argument: uid, from: this);

  @override
  String toString() => r'contactsProvider';
}

@ProviderFor(ContactController)
final contactControllerProvider = ContactControllerProvider._();

final class ContactControllerProvider
    extends $AsyncNotifierProvider<ContactController, void> {
  ContactControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactControllerHash();

  @$internal
  @override
  ContactController create() => ContactController();
}

String _$contactControllerHash() => r'99100ea1eb792c79dad35d05527aa326befe3a2a';

abstract class _$ContactController extends $AsyncNotifier<void> {
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
