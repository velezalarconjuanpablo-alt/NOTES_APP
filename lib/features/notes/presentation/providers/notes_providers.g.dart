// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notesRepositoryHash() => r'780be5c27dbc91284c4efce70dbfea99a5252534';

/// See also [notesRepository].
@ProviderFor(notesRepository)
final notesRepositoryProvider = Provider<NotesRepository>.internal(
  notesRepository,
  name: r'notesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotesRepositoryRef = ProviderRef<NotesRepository>;
String _$allNotesHash() => r'3d1533bee4e02e567dd7bd6c298a705f7838206f';

/// See also [allNotes].
@ProviderFor(allNotes)
final allNotesProvider = AutoDisposeStreamProvider<List<Note>>.internal(
  allNotes,
  name: r'allNotesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllNotesRef = AutoDisposeStreamProviderRef<List<Note>>;
String _$favoriteNotesHash() => r'a4ad96108f180a08bdf4c33bb6523117f4acd9da';

/// See also [favoriteNotes].
@ProviderFor(favoriteNotes)
final favoriteNotesProvider = AutoDisposeStreamProvider<List<Note>>.internal(
  favoriteNotes,
  name: r'favoriteNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FavoriteNotesRef = AutoDisposeStreamProviderRef<List<Note>>;
String _$trashNotesHash() => r'50493c10df5d56362a124f2cf8f5e6f7aa266e83';

/// See also [trashNotes].
@ProviderFor(trashNotes)
final trashNotesProvider = AutoDisposeStreamProvider<List<Note>>.internal(
  trashNotes,
  name: r'trashNotesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$trashNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TrashNotesRef = AutoDisposeStreamProviderRef<List<Note>>;
String _$notesInFolderHash() => r'40691378e44977e429b6d3f4b088f820a55f0e6b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [notesInFolder].
@ProviderFor(notesInFolder)
const notesInFolderProvider = NotesInFolderFamily();

/// See also [notesInFolder].
class NotesInFolderFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [notesInFolder].
  const NotesInFolderFamily();

  /// See also [notesInFolder].
  NotesInFolderProvider call(
    String folderId,
  ) {
    return NotesInFolderProvider(
      folderId,
    );
  }

  @override
  NotesInFolderProvider getProviderOverride(
    covariant NotesInFolderProvider provider,
  ) {
    return call(
      provider.folderId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notesInFolderProvider';
}

/// See also [notesInFolder].
class NotesInFolderProvider extends AutoDisposeStreamProvider<List<Note>> {
  /// See also [notesInFolder].
  NotesInFolderProvider(
    String folderId,
  ) : this._internal(
          (ref) => notesInFolder(
            ref as NotesInFolderRef,
            folderId,
          ),
          from: notesInFolderProvider,
          name: r'notesInFolderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$notesInFolderHash,
          dependencies: NotesInFolderFamily._dependencies,
          allTransitiveDependencies:
              NotesInFolderFamily._allTransitiveDependencies,
          folderId: folderId,
        );

  NotesInFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final String folderId;

  @override
  Override overrideWith(
    Stream<List<Note>> Function(NotesInFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotesInFolderProvider._internal(
        (ref) => create(ref as NotesInFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Note>> createElement() {
    return _NotesInFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotesInFolderProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NotesInFolderRef on AutoDisposeStreamProviderRef<List<Note>> {
  /// The parameter `folderId` of this provider.
  String get folderId;
}

class _NotesInFolderProviderElement
    extends AutoDisposeStreamProviderElement<List<Note>> with NotesInFolderRef {
  _NotesInFolderProviderElement(super.provider);

  @override
  String get folderId => (origin as NotesInFolderProvider).folderId;
}

String _$searchResultsHash() => r'bf0f383fe6806c8619eb042e95bf9693cf34a0a4';

/// See also [searchResults].
@ProviderFor(searchResults)
final searchResultsProvider = AutoDisposeFutureProvider<List<Note>>.internal(
  searchResults,
  name: r'searchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SearchResultsRef = AutoDisposeFutureProviderRef<List<Note>>;
String _$searchQueryHash() => r'9f97403b5659152608c0dbc158267442c72403bc';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
String _$groupedNotesHash() => r'5fc900cc8bca57a9c99d68f0f19ff2a81b04fb86';

/// See also [GroupedNotes].
@ProviderFor(GroupedNotes)
final groupedNotesProvider =
    AutoDisposeNotifierProvider<GroupedNotes, Map<String, List<Note>>>.internal(
  GroupedNotes.new,
  name: r'groupedNotesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$groupedNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GroupedNotes = AutoDisposeNotifier<Map<String, List<Note>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
