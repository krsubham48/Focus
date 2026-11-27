# Focus: design

Draft for approval, 2026-11-27. Items marked **(call)** were not requested. They are proposals that can be changed.

## Why

Help the user focus on work by getting less and less distracted.

## What was asked, and how it is met

| Asked | In this design |
|---|---|
| Never get in the way of calls, messages, WhatsApp, Safari, music | Nothing is blocked. Reminders stay quiet during calls and after the six shortcuts. |
| Block everything else, with a reminder of the focus time | **Changed.** No blocking (see Constraints). Reminder notifications, plus an optional app guard. |
| 1, 5, 10, 20, 30 min, 1 hr, custom | Yes |
| Countdown screen with Phone, Messages, WhatsApp, Safari, Camera, Spotify | Yes |
| Return to the countdown after using an app | One tap on the back link or the Dynamic Island. iOS does not let an app switch back by itself. |
| Override: PIN, 5 easy sums, "are you sure", PIN again; session fails | Yes |
| 10-digit PIN set at first use, changeable | Yes |
| No more than 2 hours at a stretch | Yes |
| Day-wise dashboard: times focused and total focus time | Yes |
| Local storage only, no network calls | Yes |
| Test locally first, App Store later | Yes |

## Goals and limits

**Goals**
- Start a session in two taps.
- Make drifting noticeable and quitting deliberate.
- Show honest day-by-day progress.

**Not in this version**
- Blocking other apps.
- Booking sessions for a later time.
- Accounts, sync, backup, analytics.
- iPad.
- Stopping someone who is determined to cheat (force quit, clock change, deleting the app).
- App Store submission.

**It has failed if**
- it gets in the way of a call or a WhatsApp reply,
- it reminds so often that notifications get turned off,
- history is lost when the app is reinstalled over itself,
- it makes any network request.

## Constraints

- **Free Apple ID, nothing paid.** Apple allows app blocking only for paid developer accounts.
- A free-account install stops opening after 7 days until it is reinstalled from the Mac. Developer Mode must be on.
- Time Sensitive notifications also need a paid account, so an iPhone Focus or Do Not Disturb will hold reminders back unless the Focus app is allowed in it.
- Test device: iPhone 15 on iOS 26.7.1. Tools: Xcode 26.6.
- The repository is public. No signing identifiers or personal data are committed.

## Approaches

| | What happens on drifting | Trade-off |
|---|---|---|
| A | Countdown only | Nothing to set up or break, but no reminder |
| B | Reminder notifications | No setup, but only a banner |
| **C (chosen)** | B, plus an optional app guard set up in Apple's Shortcuts app | Closest to blocking. Manual setup, the other app flashes first, can be switched off |

## Screens and behaviour

### First launch

1. One screen on what Focus does.
2. Create a 10-digit PIN and enter it twice. (This is how "verified at first use" is read.)
3. Allow notifications.
4. Optional: set up the app guard, or "Later". **(call)**

### Home

```
┌─────────────────────────────┐
│ Focus                       │
│ How long?                   │
│  1m    5m    10m    20m     │
│  30m   1h    Custom         │
│                             │
│  [    Start 20 minutes   ]  │
│                             │
│ Today: 2 sessions · 45 min  │
│  Focus     Stats   Settings │
└─────────────────────────────┘
```

- Pick a length, then Start. The last used length is preselected (20 min the first time). **(call)**
- "Custom" means choosing any length from 1 minute to 2 hours, in minutes. "Custom time scheduler" is read this way, not as booking sessions for later.
- The 2-hour limit is per session. Another session can start right after. **(call)**
- No PIN is needed to start. A running session cannot be edited or extended. **(call)**
- "Today" counts sessions and time the same way Stats does.

### Countdown (while a session runs)

```
┌─────────────────────────────┐
│        Stay focused         │
│        ╭───────────╮        │
│        │   18:42   │        │
│        ╰───────────╯        │
│       ends at 3:45 PM       │
│                             │
│  Phone  Messages  WhatsApp  │
│  Safari  Camera   Spotify   │
│                             │
│          Override           │
└─────────────────────────────┘
```

- No tab bar. Stats and Settings are unreachable until the session ends.
- The screen locks as usual. The countdown also shows on the Lock Screen and in the Dynamic Island, and tapping it opens Focus. After the end time it reads "Done" until Focus is opened. **(call)**
- Force-closing Focus or restarting the phone does not change the session. Reopening shows the countdown.

### Opening the six apps

| Button | How it opens | If that fails on the phone |
|---|---|---|
| Messages | `sms:` (documented by Apple) | |
| WhatsApp | `whatsapp://` | "Not installed" message |
| Spotify | `spotify://` | "Not installed" message |
| Safari | An unofficial "open Safari" link | A search page in the default browser |
| Phone | `mobilephone://` (unofficial) | A number pad and contact picker inside Focus that places the call |
| Camera | `camera://` (unofficial) | A camera inside Focus that saves to Photos |

Fallbacks for Phone, Camera and Safari are built only if the link fails on the phone. Buttons use system symbols with the app's name, not other companies' logos. **(call)**

### Reminder notifications

When Focus goes from on screen to off screen during a session:

- Reminders arrive after about 20 seconds, again at 2 minutes, then every 5 minutes while away, until the session ends: "18 minutes left. Come back to Focus." **(call: timing)**
- No reminders if the user left through one of the six buttons, locked the phone, or has a phone or WhatsApp call in progress.
- Coming back to Focus cancels them.
- A "Focus complete" notification arrives when time is up, however the user left. **(call)**

Known limits:
- After leaving through one of the six buttons, nothing reminds you until you come back, even if you move on to another app. Only the app guard covers that.
- Reaching WhatsApp another way, such as from its notification, still brings a banner after 20 seconds. It does not stop typing.
- A call that starts after the user has already left may see a banner.
- Telling "locked" from "left" needs a phone passcode and may occasionally misfire.
- Without notification permission there are no reminders. Home then says so, with a link to Settings.

### App guard (optional)

**Setup, once, in the Shortcuts app:** Automation, add, App, choose the distracting apps, "Is Opened", "Run Immediately", turn off "Notify When Run", then add the action **Focus Guard**.

- During a session, opening a chosen app brings Focus forward with "Stay with it. 12 minutes left."
- Outside a session, nothing visible happens.
- Opening a guarded app does not fail the session. **(call)**
- The guide warns against choosing Focus or any of the six allowed apps.
- Settings shows when the guard last ran, so it is easy to tell whether it still works.
- If iOS will not let the action bring Focus forward by itself, the fallback is a three-step automation: ask Focus whether a session is running, If, then Open Focus.

A study of a similar app, [one sec](https://pmc.ncbi.nlm.nih.gov/articles/PMC9974409), found that interrupting an app launch with a pause and an easy way to back out cut openings by 57% over six weeks. That is why the guard screen shows one calm message and no "continue anyway" button.

### Override

1. Enter the PIN.
2. Solve five sums.
3. "Are you sure? 12 minutes left." Choose Keep focusing or Yes.
4. Enter the PIN again. The session is recorded as failed and Home appears.

- Sums are addition and subtraction with numbers from 1 to 20, never with a negative answer. A wrong answer gives a new sum, and five correct answers are needed. **(call)**
- Cancel at any step returns to the countdown. The next try starts again. **(call)**
- The countdown keeps running. If it reaches zero during these steps, the session counts as completed.
- A wrong PIN can be retried, with no lockout. **(call)**
- This is the only way to fail a session.

### Session end

"Done. You focused for 20 minutes." with Start another and Close. If Focus was closed when time ran out, this appears the next time it opens.

### Stats

```
┌─────────────────────────────┐
│ Stats                       │
│  ‹      23 – 29 Nov      ›  │
│ 4 h 20 min · 9 sessions     │
│                             │
│  60 ┤       █               │
│  30 ┤   █   █       █       │
│   0 ┼───█───█───█───█────── │
│     M   T   W   T   F  S  S │
│                             │
│ Thu 26  3 sessions · 1 h 10 │
│ Wed 25  2 sessions · 40 min │
│         1 quit early        │
└─────────────────────────────┘
```

- One week at a time, with arrows for earlier and later weeks. The week starts on the phone's first weekday. **(call)**
- Bars show minutes focused per day, in one colour. Tapping a bar shows that day's numbers. The list below is the same data in text.
- **"Sessions" and focus time count completed sessions only.** Sessions ended by override are listed separately as "quit early" and add no time. **(call)**
- A session belongs to the day it started. **(call)**
- History is kept indefinitely.

### Settings

- Change PIN: current PIN, then the new one twice.
- Forgot PIN: confirm with Face ID or the phone passcode, then set a new one. Only possible when no session is running. Without this, the only fix would be deleting the app and losing history. Not offered if the phone has no passcode. **(call)**
- Reminders: whether notifications are allowed, and a note about Do Not Disturb.
- App guard: the setup guide and when it last ran.
- A line stating that everything stays on the phone.

## Look and feel (call)

Quiet and plain: large rounded countdown digits, one accent colour for the ring, main button and chart, light and dark appearance, no badges, streaks or decorative animation. A focus app should not be something to play with. Text scales with the system setting, VoiceOver reads the countdown and bars, and touch targets are large.

## Data and privacy

- One JSON file in the app's private storage: finished sessions (start, planned length, end, completed or failed), the running session, the last used length, and when the guard last ran. Written atomically, and an unreadable file is set aside, not overwritten.
- The PIN is stored only as a salted, slow hash in the Keychain. A fresh install always asks for a new PIN.
- No network code and no third-party libraries.

## How it is built (call)

- Swift and SwiftUI, iPhone only, portrait.
- Minimum iOS 26.0. It is the only version that can be tested here, and the guard needs it. It can be lowered before an App Store release.
- Bundle identifier `io.github.krsubham48.focus`.
- Two targets: the app, and a small widget extension for the Lock Screen countdown. If the free account cannot sign or run the extension, it is dropped and nothing else changes.
- The Focus Guard action lives in the app target, so no App Group is needed.
- Session rules, storage, PIN, sums, reminder rules, app links and stats are separate units that can be tested without the screens.
- The countdown is always computed from the stored end time.
- Lock and call detection use public iOS APIs (the protected-data signal and CallKit's call observer).
- The guard can start the app in the background, so startup must not assume a visible screen.

## Testing

- Unit tests: session start, finish, fail and restore; length limits; PIN; sums; which reminders get scheduled; day totals around midnight and time zone changes; storage.
- UI tests in the Simulator: first launch, a full session, the override flow, stats. A debug-only switch shortens time.
- On the iPhone, early in the build, because only a real phone can answer:
  1. Which links open Phone, Camera, Safari and Messages.
  2. Whether locking the phone stays quiet.
  3. Whether the guard brings Focus forward without asking, and still works after a restart.
  4. Whether the Lock Screen countdown runs on a free account.
- Before calling it stable: calls (phone and WhatsApp) during a session, a 2-hour session, and a reinstall that keeps history.

## Steps only the owner can do

- Sign in to Xcode with an Apple ID (Xcode, Settings, Accounts).
- Turn on Developer Mode on the iPhone, and connect it to the Mac.
- On first run, trust the developer certificate on the phone.
- Reinstall from Xcode every 7 days.
- Set up the guard automation, if wanted.

## Later, not now

- Real blocking, which needs the paid Apple Developer Program and Apple's approval. See the [research notes](../../research/2026-11-27-ios-blocking-feasibility.md).
- App Store: the paid program, a unique name ("Focus" is likely taken), and a review of the unofficial links.

## Left to the builder

Exact wording, colours and icon, animation details, type and file names, how the Xcode project is generated, and the test framework.
