# Focus: what iOS allows

Research notes for the design, dated 2026-11-27. Nothing described here is built or device-tested yet.

- **Confirmed:** read from Apple's documentation or from the iOS 26.5 SDK in Xcode 26.6.
- **Reported:** developer forums or blog posts. Verify on a device before relying on it.

## How an app can block other apps

App Store apps do this with Apple's Screen Time frameworks:

| Framework | Role |
|---|---|
| FamilyControls | Permission (`.individual` for your own device) and the app picker |
| ManagedSettings | Applies and removes shields |
| ManagedSettingsUI | Custom "blocked" screen |
| DeviceActivity | Runs code at scheduled times, even when the app is closed |

Guided Access needs manual setup each time, and single-app mode needs a supervised, managed device. Neither fits this app.

- The user picks the allowed apps in Apple's `FamilyActivityPicker`. The app receives opaque tokens, so it cannot read app names or preselect apps. (Reported)
- Block everything else with `store.shield.applicationCategories = .all(except: allowedTokens)`. Websites are controlled separately. (Confirmed API)
- **Risk (Reported):** exempted apps can still be shielded. An Apple engineer wrote in November 2024 that "there are known issues in this area" ([thread 766766](https://developer.apple.com/forums/thread/766766), also [750988](https://developer.apple.com/forums/thread/750988)). A fallback to try is `.specific(allCategoryTokens, except:)`.

## Accounts and entitlements

- **Confirmed:** Apple's [capability table](https://developer.apple.com/help/account/reference/supported-capabilities-ios/) marks Family Controls (development) only for the paid Apple Developer Program. A free account cannot run the blocking on a device. App Groups are available to all accounts.
- **Reported:** distribution needs a separate Family Controls entitlement, requested for each bundle ID (the app and each extension). Approval has taken weeks to months.
- **Reported:** in the Simulator, authorization cannot complete, the picker lists no apps and the monitor extension never runs ([source](https://dev.to/twillywill/the-ios-screen-time-api-in-2026-what-apples-docs-dont-tell-you-151e)). Blocking must be tested on a physical iPhone.

## The blocked screen and getting back to Focus

- **Confirmed:** `ShieldConfiguration` sets an icon, title, subtitle, buttons and colours. It can show the time remaining, read from a shared App Group.
- **Confirmed:** `ShieldActionResponse.openParentalControlsApp` exists from iOS 26.5, so the shield can offer "Return to Focus". Earlier versions can only close, or send a notification that opens the app.
- iOS shows a back link to the previous app when one app opens another. A Live Activity can show the countdown on the Lock Screen and Dynamic Island and open Focus on tap.
- An app has no way to keep itself in the foreground or to bring itself back.

## Ending a session on time

- **Confirmed:** DeviceActivity intervals must be at least 15 minutes (`intervalTooShort`).
- **Reported:** for shorter sessions, keep the end fixed and move the start earlier so the window is 15 minutes ([source](https://dev.to/ayumu_kitabayashi_8e0de96/5-timing-bugs-i-hit-building-timed-blocks-with-screen-times-deviceactivity-ios-5dnc)).
- **Reported pitfalls:** windows that cross midnight; a start equal to "now" being booked for tomorrow; stopping or restarting a monitor firing `intervalDidEnd`.
- **Design consequence:** do not depend on one callback. Also clear shields when the app becomes active, and from the shield extension once the stored end time has passed. Compare against the stored end time before clearing.

## Hardening, and its limits

- **Confirmed:** `application.denyAppRemoval` and `dateAndTime.requireAutomaticDateAndTime` can stop app deletion and clock changes during a session.
- **Reported:** `denyAppRemoval` applies to every app on the device. The user can still revoke Screen Time access in Settings. There is one report of the flag staying stuck ([thread 818905](https://developer.apple.com/forums/thread/818905)).
- So Focus can make quitting slow and visible, not impossible.

## Opening the allowed apps

| App | Link | Status |
|---|---|---|
| Messages | `sms:` | Documented by Apple |
| WhatsApp | `whatsapp://` | The app's own scheme |
| Spotify | `spotify:` | The app's own scheme |
| Default browser | an `https` address | Public behaviour |
| Phone | `mobilephone://` | Undocumented, test; App Review risk |
| Camera | `camera://` | Undocumented, may not work, test |
| Apple Music, FaceTime | to be decided | Test |

Fallbacks for Phone and Camera: a dialer inside Focus that places calls with `tel:`, and an in-app camera that saves to Photos.

## Other notes

- **Reported, conflicting:** shielding an app may also silence its notifications.
- **Reported:** shielding an app that is playing audio pauses it, so music apps must be exempt.
- Extensions run apart from the app and share state through an App Group.
- No new blocking APIs were found for iOS 27 (not verified against release notes).

## Without the paid program (the chosen route)

- **Confirmed:** free accounts get App Groups, background modes, data protection and keychain sharing, but not Family Controls, push, Time Sensitive Notifications or Siri.
- **Reported:** installs expire after 7 days, with at most 3 such apps on a phone and 10 new App IDs a week.
- **Confirmed (SDK):** on iOS 26 an App Intent with `supportedModes = [.background, .foreground(.dynamic)]` can call `continueInForeground(alwaysConfirm: false)`, so a Shortcuts action opens its app only when needed.
- **Reported:** this drives guards from an "app is opened" automation ([write-up](https://dev.to/eliguzz/building-an-open-source-one-sec-alternative-breaking-the-shortcuts-infinite-loop-thanks-to-ios-26-ka4), [repo](https://github.com/tombastianmueller03/controlyourflow), the latter not yet device-tested). The built app must contain `Metadata.appintents`. The guarded app shows briefly first.
- **Reported:** app-opened automations stopped firing after a restart on iOS 26.6 ([report](https://pcglance.com/ios-26-6-shortcuts-automation-broken/)).
- **Unverified:** whether a Live Activity extension signs and runs on a free account.
- **Reported:** the protected-data signal can indicate a lock, but may be late and needs a passcode.
- **Design evidence:** [field study of the one sec app](https://pmc.ncbi.nlm.nih.gov/articles/PMC9974409).

## Check on a real iPhone if blocking is added later

1. Phone, FaceTime, Messages, Safari, Camera, WhatsApp, Spotify and Music appear in the picker.
2. With shields on, those apps stay usable, calls come through and music keeps playing.
3. The Phone, Camera, FaceTime and Music links open the right app.
4. A 1-minute session unblocks on time while Focus is closed.
5. "Return to Focus" on the blocked screen opens Focus.
