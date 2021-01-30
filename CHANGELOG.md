# Changelog

## v0.2.0

### New Features

- Added `add_new/2` which only adds an item if it is not already present
- Added `add_new!/2` which adds an item if it is not already present, or raises if it is
- Added `remove!/2` which removes an item if it exists, or raises if it doesn't

### Bug Fixes

- Fix some incorrect references to `__MODULE__` in docs
- Correctly update linkages and move `value` to then end when calling `add/2`
  with an existing value

---

## v0.1.0

Initial release
