# BitSwag — classic tweak preferences

This project includes a PreferenceLoader pane that should appear in iOS Settings as **BitSwag**, with an **Enable BitSwag** switch.

## Build with GitHub Actions
1. Create a GitHub repository named `BitSwag`.
2. Upload the contents of this folder, including `.github/workflows/build.yml`.
3. Enable Actions if prompted, then run **Build BitSwag**.
4. Download the `BitSwag-deb` artifact.

## Disable behavior
The tweak checks `Enabled` in the `com.bitswag.tweak` preferences domain when BitLife starts. Turn it off in Settings, force-close BitLife, then reopen it. This does not unload injected code from a process that is already running.

## Current limitations
This is a starter project, not a verified release. The package has not been built/tested here. Verify BitLife's actual bundle identifier from `Info.plist`; `com.candywriter.bitlife` is only the current assumed filter. The UI is a placeholder; game-stat changes and dealership integration are not implemented.
