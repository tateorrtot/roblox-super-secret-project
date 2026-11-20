# Tests

This file loads when a file under `tests` is opened, and brings the conventions with it.

- Tests are plain scripts that mirror `src`, and use `tests/Check.luau`.
- A check's message says what should be true, and starts with the name of the function it is about.
- One file alone: `lune run tests/inventory/Inventory.test.luau`. Everything: `lune run tools/check`.

@../docs/code/names.md
@../docs/code/conventions.md
