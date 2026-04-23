# Plan to Fix Quran Symbol Models and Analysis Warnings

## Background & Motivation
During a recent interaction, an attempt was made to resolve `invalid_annotation_target` analysis warnings in `QuranSymbol`, `SymbolSource`, and `SymbolExample` models. The `@JsonSerializable` annotations were moved from the `factory` constructors to the class declarations. This approach is incorrect when using `freezed` for immutable models and resulted in broken code generation (e.g., `Cannot populate the required constructor argument: id`) and multiple analysis errors (`non_abstract_class_inherits_abstract_member`, `undefined_named_parameter jsonSerializable`). The `dart fix` command was also run.

## Scope & Impact
- **Revert:** Restore `lib/features/quran/domain/models/quran_symbol.dart` to its original, syntactically correct `freezed` form.
- **Fix Analysis Errors:** Address the `invalid_annotation_target` warning cleanly by suppressing it in `analysis_options.yaml`. This is the officially recommended solution by the authors of `freezed` and `json_serializable` for handling constructor annotations.
- **Review `dart fix` Changes:** Check if the unused imports removed by `dart fix` broke any dependencies, and revert them if necessary.

## Implementation Steps

1.  **Revert `quran_symbol.dart`:**
    *   Change the models (`QuranSymbol`, `SymbolSource`, `SymbolExample`) back to `abstract class` using the `with _$ModelName` mixin.
    *   Move the `@JsonSerializable(fieldRename: FieldRename.snake)` annotation back onto the `const factory` constructors.

2.  **Update `analysis_options.yaml`:**
    *   Add an `analyzer` block with `errors:` to ignore `invalid_annotation_target` globally. This is required because `json_annotation` ^4.10.0 correctly warns that annotations like `@JsonKey` or `@JsonSerializable` on parameters/constructors are technically invalid for standard classes, but `freezed` relies on this exact syntax to map them correctly to the generated implementation classes.
    *   Example configuration:
        ```yaml
        analyzer:
          errors:
            invalid_annotation_target: ignore
        ```

3.  **Revert Unintended `dart fix` Changes:**
    *   Revert `lib/core/utils/symbol_detector.dart`
    *   Revert `lib/features/quran/presentation/pages/symbol_list_screen.dart`
    *   Revert `lib/features/quran/presentation/widgets/quran_reader_help_overlay.dart`
    *   Revert `test/core/services/notification/prayer_scheduler_test.dart`
    *   *(Since `dart fix` only removed unused imports, these changes might be benign, but reverting them guarantees the exact prior state. We can simply run `git restore` on these files).*

4.  **Run Code Generation:**
    *   Execute `dart run build_runner build --delete-conflicting-outputs` to regenerate the `freezed` and `g.dart` files successfully.

## Verification & Testing
1.  Run `flutter analyze` and ensure no `invalid_annotation_target` or `non_abstract_class_inherits_abstract_member` errors exist.
2.  Run `dart run build_runner build` and ensure it completes without failures.
