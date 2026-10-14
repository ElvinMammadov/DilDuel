# Privacy and compliance answers

Worked out from the app code (Firebase Auth, Cloud Firestore, AdMob with
Google's consent form, iOS tracking permission), `ios/Runner/PrivacyInfo.xcprivacy`
and the privacy manifest of the Google Mobile Ads SDK. The app has no
analytics or crash-reporting SDK of its own.

Google can change what its ads SDK collects. Before submitting, compare the
ad rows below with Google's current AdMob data-disclosure guidance.

Guests (no account) send nothing to us: bookmarks, progress and results stay
on the device. Only the ad SDK talks to a third party for them.

---

# App Store Connect

## App Privacy

- Do you or your third-party partners collect data from this app? **Yes**
- Do you or your third-party partners use data for tracking? **Yes** (the
  advertising ID, after the user allows tracking)

| Data type | Linked to user | Used for tracking | Purposes | Where it comes from |
|---|---|---|---|---|
| Email address | Yes | No | App functionality | Account sign-in |
| Name | Yes | No | App functionality | Display name from Google or Apple |
| User ID | Yes | No | App functionality | Firebase user ID |
| Other user content | Yes | No | App functionality | Bookmarks, unknown words, quiz and listening results, training progress |
| Device ID | Yes | **Yes** | Third-party advertising | AdMob |
| Advertising data | Yes | No | Third-party advertising | AdMob |
| Product interaction | Yes | No | Third-party advertising, analytics | AdMob |
| Coarse location | Yes | No | Third-party advertising, analytics | AdMob (derived from the IP address) |
| Crash data, performance data, other diagnostic data | No | No | Analytics, third-party advertising | AdMob |

The app's own manifest declares the first four rows and tracking; the ad SDK
declares the rest in its own manifest.

## Other questions

| Question | Answer |
|---|---|
| Age rating | Answer "None" or "No" to every content question. Expect 4+. |
| Export compliance | Only standard HTTPS. Already set: `ITSAppUsesNonExemptEncryption = false`. |
| Content rights | Answer truthfully. The dictionary data comes from a published book, so make sure you have the author's permission before you say you own or license the content. |
| EU trader status (DSA) | Required to distribute in the EU. Enter the name, address, phone and email from the Impressum; they are shown on the product page. |
| Account deletion | In the app: Settings, delete account. On the web: the delete-account page. |
| Sign in with Apple | Offered next to Google, as the guidelines require. |
| Review notes | See `store/listing.md`. Guest mode works, so no demo account is needed. |
| Screenshots | iPhone 6.9" (1320×2868). iPad 13" (2064×2752) only while the app supports iPad. |

---

# Google Play Console

| Section | Answer |
|---|---|
| App access | All functionality is available without logging in. |
| Ads | The app contains ads: **Yes**. |
| Advertising ID | The app uses it: **Yes**, for advertising (AdMob). |
| Content rating (IARC) | Category: reference or education. No violence, sexual content, bad language, drugs or gambling; no user-to-user communication. Expect Everyone. |
| Target audience | 13 and over. Choosing under-13 brings the Families policy and requires child-directed ad settings. |
| News, health, finance, government | None apply. |
| Account deletion URL | https://elvinmammadov.github.io/DilDuel/delete-account/ |

## Data safety

Encrypted in transit: **Yes**. Users can request deletion: **Yes** (in the app
and at the URL above). Independent security review: **No**.

| Data type | Collected | Shared | Optional | Purposes |
|---|---|---|---|---|
| Email address | Yes | No | Yes (account) | App functionality, account management |
| Name | Yes | No | Yes (account) | App functionality, account management |
| User IDs | Yes | No | Yes (account) | App functionality, account management |
| Other user-generated content (bookmarks, marked words) | Yes | No | Yes (account) | App functionality |
| Other actions (quiz and listening results, training progress) | Yes | No | Yes (account) | App functionality |
| Device or other IDs (advertising ID) | Yes | **Yes**, with Google (AdMob) | No | Advertising or marketing |
| App interactions | Yes | **Yes**, with Google (AdMob) | No | Advertising or marketing, analytics |
| Approximate location | Yes | **Yes**, with Google (AdMob) | No | Advertising or marketing |
| Crash logs and diagnostics | Yes | **Yes**, with Google (AdMob) | No | Analytics |

---

# Before you submit

- Open the privacy, delete-account and support URLs in `store/listing.md` and
  confirm they load. The repository was renamed to DilDuel, and the app links
  to `https://elvinmammadov.github.io/DilDuel/`.
- Google Play: a new personal developer account needs a closed test with 12
  testers for 14 days before production access. Check the current rule in the
  console and start this first.
- Firebase: add the Play App Signing SHA-1 and SHA-256 so Google Sign-In works
  in store builds, publish the OAuth consent screen, and deploy
  `firestore.rules`.
- AdMob: set up the consent message and, once the app is live, link it to its
  store listing. Add `app-ads.txt` to a site you control.
