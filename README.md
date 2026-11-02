# FeedOnly

A personal iPhone app that shows Instagram without Reels, Explore, suggested posts or ads.
It works like SocialLite: it loads instagram.com in a web view and injects
[`Resources/filter.js`](Resources/filter.js) into every page.

| Instagram feature | In FeedOnly |
| --- | --- |
| Reels tab (`/reels/`) | Hidden; opening it sends you to your feed |
| A reel someone sent you | Opens as a single post |
| Explore grid, hashtags, locations | Redirected to the search box |
| "Suggested for you", sponsored posts, posts after "Suggested posts" | Hidden |
| Feed, stories, DMs, profiles, search, notifications | Unchanged |
| Links to the real Instagram app (`instagram://`) | Blocked |

To also hide videos posted by accounts you follow, set `HIDE_FEED_VIDEOS = true` in `filter.js`.

## Try the filter first (5 minutes, no build)

1. Install the free **Userscripts** app from the App Store and enable it in
   Settings › Apps › Safari › Extensions (allow it on instagram.com).
2. Copy `Resources/filter.js` into the Userscripts folder.
3. Open instagram.com in Safari and log in.

If that feels right, build the app below so it has its own icon and session.

## Build and install the app (no Mac needed)

You need a GitHub account, a free Apple ID and a Windows PC with a USB cable.

1. **Build in the cloud.** Push this folder to a GitHub repository (private is fine).
   The *Build IPA* workflow runs on a macOS runner; when it finishes, download the
   `FeedOnly` artifact from the run page and unzip it to get `FeedOnly.ipa`.
2. **Install Sideloadly** on Windows (sideloadly.io) together with iTunes and iCloud
   from Apple's website (not the Microsoft Store versions).
3. **Plug in the iPhone**, open Sideloadly, drop `FeedOnly.ipa` into it, enter your
   Apple ID and press Start. Sideloadly signs the app with your Apple ID.
4. **On the iPhone:**
   - Settings › Privacy & Security › Developer Mode › On (the phone restarts).
   - Settings › General › VPN & Device Management › trust your Apple ID.
5. Open FeedOnly and log in to Instagram.

### Keeping it working

- With a free Apple ID the app expires after **7 days**. Re-run Sideloadly, or turn on
  its auto-refresh (the PC must be on and on the same Wi-Fi). A paid Apple Developer
  account ($99/year) makes it last a year.
- Delete the real Instagram app, or give it a 1-minute limit in Screen Time,
  so you are not tempted back.
- If Instagram changes its website and something reappears, update `filter.js`,
  push, and reinstall.

## Building on a Mac instead

```bash
brew install xcodegen
xcodegen generate
open FeedOnly.xcodeproj
```

Pick your Apple ID team under Signing & Capabilities and run it on your iPhone.

## Known limits

- Everything Instagram's website can't do, FeedOnly can't either. Posting stories and
  some editing tools work better in the real app.
- No push notifications.
- Hiding suggested posts relies on the labels Instagram shows, in English or French.
  If your Instagram is in another language, add its labels at the top of `filter.js`.
