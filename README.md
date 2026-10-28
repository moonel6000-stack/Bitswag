# BitSwag v0.5.0 — repaired build layout

This revision restores the preferences bundle and adds a root-level `BitSwag.plist` for Theos staging, while keeping the installed filter at `layout/Library/MobileSubstrate/DynamicLibraries/BitSwag.plist`.

## Important
- The filter currently uses `com.candywriter.bitlife` as a **placeholder**. Confirm BitLife's actual `CFBundleIdentifier` before expecting injection.
- `-undefined dynamic_lookup` is a build workaround for the private `PSListController` symbols when the GitHub runner lacks the private Preferences SDK framework. It is not yet device-tested.
- The project has not been compiled or tested on-device here.
- The UI currently contains placeholder rows (`Stats — planned`, `Money — planned`, `Add Cars — planned`). Those features are not implemented yet.

Build using the repository's GitHub Actions workflow, then install the newly built package (version 0.5.0) rather than an older cached `.deb`.
