# Context expansion catalog

Reference for Phase F2.7 (NEW_FEATURE) and PRD interview branch enumeration (NEW_PROJECT Phase 3).

For each feature category below: standard branches, permissions, state handling, edge cases, privacy considerations, accessibility requirements, cross-platform notes, and observability hooks. Use as a checklist — users mark MVP / v2 / skip per branch.

---

## Image / video capture

**Primary alternatives:** camera direct, gallery picker, file upload (web), drag-drop (web/desktop)
**Permissions:** camera (iOS NSCameraUsageDescription, Android CAMERA), photo library (iOS NSPhotoLibraryUsageDescription, Android READ_MEDIA_IMAGES), microphone for video
**State handling:** capturing, preview, encoding, upload progress, retry, cancel
**Edge cases:** denied permission, low storage, large file, unsupported format, slow network, offline draft, HDR/HEIC support
**Privacy:** EXIF strip (location, device, timestamps), retention policy, deletion flow
**Accessibility:** alt-text / caption input, screen reader labels, voice description
**Cross-platform:** iOS scoped permissions (limited library), Android 13+ scoped storage, web file API differences, desktop drag-drop
**Observability:** capture_started/completed/cancelled events, upload duration metric

---

## Audio capture

**Primary alternatives:** record (microphone), upload audio file, voice memo from system
**Permissions:** microphone (iOS NSMicrophoneUsageDescription, Android RECORD_AUDIO)
**State handling:** recording (with waveform), paused, encoding, transcribing (if applicable)
**Edge cases:** denied permission, ambient noise, max duration, transcription failure, low quality
**Privacy:** transcription processing location (on-device vs cloud), retention, consent for transcript storage
**Accessibility:** visual waveform alternative for hearing-impaired, transcript display
**Cross-platform:** iOS AVAudioSession config, Android AudioRecord, web MediaRecorder API
**Observability:** record duration, transcription success rate

---

## Auth / login

**Primary alternatives:** email+password, social login (Google/Apple/Microsoft/GitHub), magic link, SSO (SAML/OIDC), biometric, passwordless (WebAuthn)
**Implicit standard expectations:** forgot password flow, email verification, remember-me, logout, account lockout after N attempts, password strength meter
**Permissions:** biometric (Face ID / Touch ID), keychain access
**State handling:** form input, validating, sending, success, error (wrong credentials, rate limited, server error)
**Edge cases:** offline (cached auth), token expiry mid-action, multi-device sign-out, account deletion
**Privacy:** session log retention, password storage (argon2/bcrypt), 2FA secret handling
**Accessibility:** error message clarity, autofill support, password manager hooks
**Cross-platform:** Apple Sign-In required if you offer social login on iOS; deep links for magic links; web cookie vs token strategy
**Observability:** login_attempt/success/fail events, MFA opt-in rate

---

## Search

**Primary alternatives:** text input, voice search, image search, barcode scan
**Implicit standard expectations:** autocomplete / typeahead, filters, sort, pagination, infinite scroll, empty state, error state, recent searches, search suggestions, "no results" experience
**Permissions:** microphone (voice search), camera (barcode/image)
**State handling:** debouncing input, loading, success with results, success empty, error, retry
**Edge cases:** very long query, special characters, multilingual, offline cached, slow backend, large result set pagination
**Privacy:** search history storage, anonymization, opt-out
**Accessibility:** announcing result count to screen reader, keyboard navigation through results
**Cross-platform:** native search bar conventions per OS, web URL state for shareable searches
**Observability:** query latency, zero-result rate, top queries (anonymized)

---

## Notifications

**Primary alternatives:** push (FCM/APNs), in-app banner, email, SMS, badge count, system tray (desktop)
**Implicit standard expectations:** per-event opt-in/out, quiet hours, grouping, deep link on tap, sound + vibration prefs, notification history
**Permissions:** notification permission flow (Android 13+ requires runtime), critical alerts (iOS), system tray (desktop)
**State handling:** scheduled, delivered, displayed, tapped, dismissed
**Edge cases:** permission denied (graceful degrade), token rotation, foreground vs background delivery, doze mode (Android), Focus mode (iOS)
**Privacy:** content visibility on lock screen (hide sensitive), data minimization in payload
**Accessibility:** verbose announcement option for screen reader, alternative for vibration-only users
**Cross-platform:** APNs payload format vs FCM, web Push API, desktop notification API, OS-level deep link routing
**Observability:** delivery rate, open rate, opt-out rate per notification type

---

## User profile

**Primary alternatives:** view, edit, public profile vs private
**Implicit standard expectations:** avatar upload, password change, email change (with re-verify), phone change, delete account, export data (GDPR), connected social accounts management, session/device list
**Permissions:** photo library (avatar upload)
**State handling:** loading, edit mode, saving, success, error
**Edge cases:** unique-name conflict, email change race condition (old + new both confirmed), deletion grace period, data export size (large user histories)
**Privacy:** GDPR right to deletion (full vs soft delete), export format (machine-readable), retention after deletion
**Accessibility:** form field labels, error messages tied to fields
**Cross-platform:** OAuth disconnection complexity (provider-specific)
**Observability:** profile_completed_percentage, deletion requests, export requests

---

## Comments / replies

**Primary alternatives:** flat list, threaded, hybrid
**Implicit standard expectations:** write + reply + edit + delete + report, mention (@user), emoji reactions, media attachments, pagination, sort (newest/oldest/popular), draft auto-save
**Permissions:** photo library (attachments)
**State handling:** drafting, posting, posted, edited indicator, deleted (tombstone), reported (moderation queue)
**Edge cases:** banned user attempting to post, deleted thread parent, replied-to comment deleted, very long thread, race condition on edit
**Privacy:** moderation log access, soft delete vs hard delete, edit history visibility
**Accessibility:** announce new comments to screen reader, focus management on submit
**Cross-platform:** real-time delivery (WebSocket vs polling), notification on reply
**Observability:** comment volume, reply depth, report-to-resolution time

---

## Cart / checkout

**Primary alternatives:** persistent cart, guest cart, saved-for-later, wishlist
**Implicit standard expectations:** add + quantity + remove + clear, coupon / promo code, total calculation (subtotal + tax + shipping + discount), address management, address validation, multiple payment methods, order review, order confirmation, abandoned cart recovery email
**Permissions:** none typically
**State handling:** validating, applying coupon, calculating, ready, processing payment, success, fail (retry)
**Edge cases:** item went out of stock during checkout, price changed, currency conversion, abandoned mid-flow restoration
**Privacy:** PCI compliance (card data), address storage, billing/shipping separation
**Accessibility:** error messages near fields, total recalculation announcement
**Cross-platform:** Apple Pay / Google Pay integration, browser autofill, web vs native cart sync
**Observability:** cart_abandoned event with stage, coupon application rate

---

## Payment

**Primary alternatives:** Stripe, PayPal, Braintree, regional providers, crypto, ACH/SEPA
**Implicit standard expectations:** card vault, recurring subscription, refund flow, receipt generation + email, payment history, retry on failed payment (dunning), tax / VAT calculation, multi-currency
**Permissions:** none typically
**State handling:** initialized, awaiting 3DS, processing, succeeded, failed, refunded
**Edge cases:** 3DS challenge, insufficient funds, expired card, declined, partial refund, chargeback, currency conversion timing
**Privacy:** PCI compliance — never log card data, tokenization, encrypted vault
**Accessibility:** clear error messages for declined transactions
**Cross-platform:** Apple Pay / Google Pay native, webhook signature verification, idempotency keys
**Observability:** payment_attempted/succeeded/failed, decline reason breakdown, refund rate

---

## Map / location

**Primary alternatives:** map provider (Mapbox / Google Maps / Apple Maps / OpenStreetMap), embedded map vs full-screen, pin / polygon / route
**Implicit standard expectations:** current location, search location, reverse geocode (coords → address), forward geocode (address → coords), route navigation, distance/time estimate, clustering for many pins, offline tiles
**Permissions:** location (foreground / background / always), iOS NSLocationWhenInUseUsageDescription
**State handling:** locating, located, denied, error, loading tiles, route calculating
**Edge cases:** location denied, indoor (poor GPS), location spoofing, battery drain
**Privacy:** location history storage opt-in, anonymization, retention policy
**Accessibility:** alternative non-map list view, screen reader friendly route descriptions
**Cross-platform:** iOS CoreLocation, Android FusedLocationProvider, web Geolocation API, map provider quotas/cost
**Observability:** location_accuracy_quality, route_completion_rate

---

## File upload

**Primary alternatives:** single file, multiple files, drag-drop, directory upload, cloud picker (Google Drive / Dropbox)
**Implicit standard expectations:** progress bar, cancel, retry, resume (chunked upload), size limit, format validation, virus scan (server-side), thumbnail preview (images/PDFs)
**Permissions:** storage access (Android), files access (iOS scoped)
**State handling:** selecting, validating, uploading, processing, success, error
**Edge cases:** file too large, unsupported format, malware detected, network interruption (resume), duplicate filename, disk full
**Privacy:** content scan disclosure, retention, deletion flow, encrypted storage
**Accessibility:** progress percentage announcements, focus return after picker close
**Cross-platform:** iOS Files app integration, Android Storage Access Framework, web File API + drag-drop, desktop native picker
**Observability:** upload_started/completed/failed, average upload size, failure reason breakdown

---

## Form

**Primary alternatives:** single page, multi-step wizard, conditional fields, auto-fill
**Implicit standard expectations:** field validation (live + on-submit), error messages near fields, save draft (auto-save), submit + loading + success/error, accessibility labels, prefill from URL/previous data, "are you sure?" on close with unsaved
**Permissions:** none typically (depends on inputs — e.g., camera for photo field)
**State handling:** draft, validating, submitting, success, error, recovering
**Edge cases:** offline submit (queue), session timeout mid-form, browser back button, paste large text into field
**Privacy:** PII handling, autofill safety
**Accessibility:** label associations, error announcements (ARIA live), tab order, keyboard nav
**Cross-platform:** mobile keyboard appropriate (numeric/email/url), web autofill hints, password manager integration
**Observability:** form_started/completed/abandoned, abandonment step

---

## Settings

**Primary alternatives:** categorized list, search-within-settings, simple/advanced toggle
**Implicit standard expectations:** theme (light/dark/auto), language/locale, notification prefs, privacy controls, account section, about/version, help, log out, delete account, sync across devices
**Permissions:** depends on toggled feature
**State handling:** saving (debounced), saved indicator, sync conflict resolution
**Edge cases:** offline settings change (queue sync), sync conflict, downgrade theme (color blind mode)
**Privacy:** settings sync across devices opt-in
**Accessibility:** high contrast, font size, reduce motion, screen reader categories
**Cross-platform:** OS theme inheritance, locale auto-detect, system dynamic type
**Observability:** which settings changed most, theme adoption breakdown

---

## Social sharing

**Primary alternatives:** native share sheet, per-platform (X, FB, WhatsApp, email, SMS, copy link), QR code, deep link
**Implicit standard expectations:** preview card (OG meta tags), tracking parameters, share count display, share-to-app deep link
**Permissions:** depends on target platform
**State handling:** opening sheet, sharing, success/cancel
**Edge cases:** target app not installed (fallback), broken deep link, share to platform that strips params
**Privacy:** tracking param consent, anonymized share metrics
**Accessibility:** screen reader friendly share sheet labels
**Cross-platform:** UIActivityViewController vs ACTION_SEND vs Web Share API
**Observability:** share_initiated/completed per target, conversion from shared link

---

## Chat / messaging

**Primary alternatives:** 1:1, group, channels, threads
**Implicit standard expectations:** text + emoji + media + voice + file, reactions, threading, mentions, presence (online/typing), read receipts, delivery receipts, message edit, delete, pin, search, history pagination, push notification, mute, archive, block, report
**Permissions:** notifications, mic (voice), camera (media), photo library
**State handling:** drafting, sending, sent, delivered, read, failed (retry), edited, deleted
**Edge cases:** offline send queue, race condition on edit, very long message, message in deleted thread, blocked sender, encrypted vs plain
**Privacy:** end-to-end encryption optional, retention policy, deletion semantics (for both / for me)
**Accessibility:** screen reader announces new messages, voice message transcription
**Cross-platform:** real-time protocol (WebSocket, XMPP, Matrix), push delivery, message ordering across devices
**Observability:** delivery latency, edit/delete rate, voice vs text ratio

---

## Calendar / scheduling

**Primary alternatives:** date picker, datetime picker, recurring event, multi-day event, time-zone aware
**Implicit standard expectations:** invitees, location, reminders, attachments, RSVP, busy/free, conflict detection, time-zone display, recurring exception handling
**Permissions:** calendar (iOS NSCalendarsUsageDescription, Android READ_CALENDAR/WRITE_CALENDAR)
**State handling:** drafting, saving, syncing
**Edge cases:** time zone change mid-event, DST transition, recurring event with exception, declined attendee, location change
**Privacy:** calendar sync scope (read-only vs read-write), event detail visibility
**Accessibility:** date picker keyboard nav, screen reader date announcement
**Cross-platform:** EventKit (iOS), CalendarContract (Android), CalDAV, Google Calendar API
**Observability:** event_created, RSVP response rate

---

## Analytics / charts

**Primary alternatives:** line / bar / pie / heatmap / scatter / funnel
**Implicit standard expectations:** time range selector, filter, sort, drilldown, export (CSV/PNG), compare to previous period, real-time vs cached, no-data state, loading skeleton
**Permissions:** none typically
**State handling:** loading, refreshed, error, exporting
**Edge cases:** empty data range, very wide range (downsample), missing data points (interpolate vs gap), data still computing
**Privacy:** aggregation level (no individual identification), retention
**Accessibility:** data table fallback for screen reader, color-blind safe palette, keyboard nav for drilldown
**Cross-platform:** chart library choice (recharts, victory, fl_chart), web canvas vs SVG performance
**Observability:** chart_view, export_used

---

## Onboarding

**Primary alternatives:** carousel walkthrough, interactive tutorial, sample data, video, skip option
**Implicit standard expectations:** progressive disclosure, skip + return, tooltips on key features, welcome banner, sample / demo mode, account creation prompt at right moment
**Permissions:** none directly
**State handling:** step N/total, complete, skipped, returning user
**Edge cases:** user skips entirely, user gets stuck (offer help), user returns after long absence
**Privacy:** opt-in to product analytics during onboarding
**Accessibility:** screen reader tour of key elements, keyboard nav, skip-to-content
**Cross-platform:** in-app overlay vs full-screen, web modal vs guided tour
**Observability:** onboarding_step_completed, drop-off step, completion rate, time-to-aha

---

## Adding new categories

When the agent encounters a feature that doesn't match any catalog entry, it should:
1. Infer the closest category from keywords
2. Construct branches using the standard sections (Primary / Permissions / State / Edge / Privacy / A11y / Cross-platform / Observability)
3. Surface the constructed branches to the user for review
4. Suggest adding the new category to this catalog via a PR (community contribution)

## See also

- Phase F2.7 (NEW_FEATURE) in `agent/project-init.md`
- PRD interview branch enumeration (NEW_PROJECT Phase 3)
- [docs/PHASES.md](PHASES.md) for the full phase pipeline
