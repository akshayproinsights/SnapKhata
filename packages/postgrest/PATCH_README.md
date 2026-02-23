# Local Patch: postgrest 2.6.0

## Why this exists

`postgrest` 2.x has a bug where `PostgrestRpcBuilder extends RawPostgrestBuilder`
is written without explicit type parameters. Dart infers `Never` for the missing
`T, S, R` generics, which is valid for `dart analyze` but **crashes the Dart-to-JS
compiler (DDC)** when targeting web/Chrome with:

```
Unsupported operation: Undetermined nullability.
... type: NeverType(Never%).
```

## The fix (1 line)

**File**: `lib/src/postgrest_rpc_builder.dart`, line 3

```dart
// Before (crashes DDC for web builds):
class PostgrestRpcBuilder extends RawPostgrestBuilder {

// After (fixed):
class PostgrestRpcBuilder extends RawPostgrestBuilder<dynamic, dynamic, dynamic> {
```

## How it's wired in

`pubspec.yaml` uses `dependency_overrides` with a local `path:`:

```yaml
dependency_overrides:
  postgrest:
    path: packages/postgrest
```

## When to remove this

Once the `postgrest` pub.dev package releases a version that fixes this upstream
(check the [issue tracker](https://github.com/supabase-community/postgrest-dart/issues)),
you can:
1. Delete this `packages/postgrest/` directory
2. Remove the `dependency_overrides` block from `pubspec.yaml`
3. Run `flutter pub get`
