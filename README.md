# BitSwag 0.4 — corrected rootless build

This version builds only the main tweak. The iOS Settings preference bundle is intentionally excluded for now because its previous build failed while linking `PSListController` from the private `Preferences` framework.

## Build

Run from the repository root:

```sh
make package FINALPACKAGE=1
```

Theos expects the tweak filter as `BitSwag.plist` at the repository root. It stages the filter into the package; do not rely only on a copy under `layout/`.

## Important

- `com.candywriter.bitlife` is a provisional bundle identifier. Verify BitLife's actual `CFBundleIdentifier` before testing; if it differs, update `BitSwag.plist`.
- The menu is still a prototype and game features are not implemented yet.
- This archive has not been built or tested on the user's device.
- Settings preferences are not included in this build.
