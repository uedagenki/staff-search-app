# 📋 Staff Search App — Flutter → Pencil Design Plan

> **Design file**: `untitled.pen` · **Design System**: `sCUIU` · **Viewport**: 402 × 874, radius 32
>
> **Skill reference**: See `CLAUDE.md` for component IDs, color tokens, typography, spacing, patterns

---

## 🎯 How to use

### Design a single screen

```
Design screen [Screen Name] from Flutter code
```

### Design a whole phase (all screens in the phase)

```
Design Phase [N]
```

→ AI will read all Flutter files → design each screen → update Pen ID + ✅ → update the progress table

---

## 📊 Progress overview

| Phase | Description | Total | ✅ | ⬜ | Group ID |
|-------|--------|------|----|----|----------|
| 0 | Design System Foundation | — | — | — | — |
| 1 | Auth & Onboarding | 6 | 6 | 0 | `E1WTT` |
| 2 | Home, Discovery & Notifications | 9 | 9 | 0 | `TyKkn` |
| 3 | Profile & Settings | 7 | 7 | 0 | `Kijn1` |
| 4 | Staff Profile & Dashboard | 5 | 5 | 0 | `OX5fq` |
| 5 | Staff Content & Services | 6 | 6 | 0 | `DzmLj` |
| 6 | Booking | 7 | 7 | 0 | `4eLsX` |
| 7 | Finance & Tips | 7 | 7 | 0 | `z2Dp7` |
| 8 | Messaging & Chat | 6 | 6 | 0 | `2PCgM` |
| 9 | Company & Headhunting | 10 | 10 | 0 | `jpIms` |
| 10 | Store Management | 4 | 4 | 0 | `0xH9m` |
| 11 | Live Streaming | 12 | 7 | 5 | `cwxC0` |
| 12 | Content & Social | 6 | 0 | 6 | — |
| 13 | Points & Monetization | 3 | 3 | 0 | `b5mQy` |
| 14 | Admin | 13 | 12 | 1 | `0ROzs` |
| 15 | Support & Legal | 4 | 0 | 4 | — |
| | **TOTAL** | **105** | **89** | **16** | |

---

## 🏗️ Phase 0 — Design System Foundation

> Already done to set up the Design System: define components, color tokens, typography, patterns.
> Login, Register, Home were first designed here → now moved into Phase 1 & 2 for correct functional grouping.
> This phase is only for historical notes, **no screens need to be designed**.

---

## 🔐 Phase 1 — Auth & Onboarding

> Full flow for login, registration, account type selection, password change.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------|-------------|------|---------|-------|--------|--------|
| 1 | Login Screen | `login_screen.dart` | Sub | Form | Email/password + demo login | `74eTp` | ✅ |
| 2 | Register Screen | `register_screen.dart` | Sub | Form | Name/email/phone/password + privacy | `rqOcp` | ✅ |
| 3 | Registration Type Selection | `registration_type_selection_screen.dart` | Sub | Custom | Card selection (User/Staff/Company) | `gnGfu` | ✅ |
| 4 | Password Change | `password_change_screen.dart` | Sub | Form | Old/new/confirm password fields | `isNVH` | ✅ |
| 5 | Staff Registration | `staff/staff_registration_screen.dart` | Sub | Form | Multi-step registration form | `yoNSa` | ✅ |
| 6 | Company Signup | `company/company_signup_screen.dart` | Sub | Form | Company info + upload fields | `FAQHh` | ✅ |

---

## 🏠 Phase 2 — Home, Discovery & Notifications

> Main screen, staff discovery, search, filters, rankings, notifications.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|---------------------------|----------|------------|--------------------------------------------------|--------|--------|
| 7 | Home Screen | `home_screen.dart` | Main Tab | Main Tab | Stories + staff feed + filter | `sli1z` | ✅ |
| 8 | Staff Feed (TikTok-style) | `staff_feed_screen.dart` | Main Tab | TikTok Card | Vertical PageView, full-bleed cards | `2GZUU` | ✅ |
| 9 | Search Screen | `search_screen.dart` | Sub | List | Search bar + staff results grid | `0lv8m` | ✅ |
| 10 | Map Search | `map_search_screen.dart` | Sub | Custom | Google Map + bottom sheet results | `be2TB` | ✅ |
| 11 | Filter Settings | `filter_settings_screen.dart` | Sub | Form | Category/location/distance filters | `8kx7Y` | ✅ |
| 12 | Ranking Screen | `ranking_screen.dart` | Sub | List | Tab rankings (daily/weekly/monthly) | `8rKJn` | ✅ |
| 13 | Notifications Screen | `notifications_screen.dart` | Sub | List | Notification items + read/unread | `kWH3k` | ✅ |
| 14 | Notification List | `notification_list_screen.dart` | Sub | List | Grouped notification list | `va8Sd` | ✅ |
| 15 | Live Feed | `live_feed_screen.dart` | Sub | List | Active live streams grid | `5Jq0e` | ✅ |

---

## 👤 Phase 3 — Profile & Settings

> User profile, edit profile, privacy settings, notification settings, block user.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-------------------------------|------|---------|------------------------------------------|--------|--------|
| 16 | Profile Screen | `profile_screen.dart` | Main Tab | Main Tab | Avatar + stats + menu items | `tpWuw` | ✅ |
| 17 | Profile Edit | `profile_edit_screen.dart` | Sub | Form | Avatar upload + name/bio fields | `zt914` | ✅ |
| 18 | Profile Settings | `profile_settings_screen.dart` | Sub | List | Settings menu rows | `oOuBu` | ✅ |
| 19 | Privacy Settings | `privacy_settings_screen.dart` | Sub | Form | Toggle switches for privacy | `ymOBw` | ✅ |
| 20 | Notification Settings | `notification_settings_screen.dart` | Sub | Form | Toggle switches for notifications | `N0k6r` | ✅ |
| 21 | Notification Settings (New) | `notification_settings_screen_new.dart` | Sub | Form | Updated notification toggles | `HPbbA` | ✅ |
| 22 | User Block Management | `user_block_management_screen.dart` | Sub | List | Blocked users list + unblock | `qEYvB` | ✅ |

---

## 🧑‍💼 Phase 4 — Staff Profile & Dashboard

> View staff details, staff dashboard, edit staff profile.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|------------------------------------------|------|-----------|----------------------------------|--------|--------|
| 23 | Staff Detail | `staff_detail_screen.dart` | Sub | Detail | Full profile + gallery + reviews | `00M7S` | ✅ |
| 24 | Staff Profile | `staff_profile_screen.dart` | Sub | Detail | Public profile view — designed from STAFF-07 spec | `g99JQ` | ✅ |
| 25 | Staff Dashboard | `staff/staff_dashboard_screen.dart` | Main Tab | Dashboard | TabBar, stats cards, earnings | `TrDRs` | ✅ |
| 26 | Staff Profile Edit | `staff/staff_profile_edit_screen.dart` | Sub | Form | Edit bio/skills/photos | `IvtWb` | ✅ |
| 27 | Staff Management Profile | `staff/staff_management_profile_screen.dart` | Sub | Detail | Management view — designed from spec pattern | `qTixn` | ✅ |

---

## 📝 Phase 5 — Staff Content & Services

> Posts, service menu management, coupons, block user (staff side).

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-----------------------------------------------|------|---------|---------------------------------------------|--------|--------|
| 28 | Staff Posts | `staff_posts_screen.dart` | Sub | List | Grid/list of staff posts | `Yip4g` | ✅ |
| 29 | Staff Posts Management | `staff/staff_posts_management_screen.dart` | Sub | List | CRUD post management | `60Ls9` | ✅ |
| 30 | Create Post | `staff/create_post_screen.dart` | Sub | Form | Image upload + caption + tags | `NwUbN` | ✅ |
| 31 | Staff Menu Management 🆕 | `staff/staff_menu_management_screen.dart` | Sub | List | Service menu items CRUD — designed from spec (no Flutter file) | `vWqEA` | ✅ |
| 32 | Staff Coupon Management 🆕 | `staff/staff_coupon_management_screen.dart` | Sub | List | Coupon cards CRUD — designed from spec (no Flutter file) | `5i0vL` | ✅ |
| 33 | Staff Block Management 🆕 | `staff/staff_block_management_screen.dart` | Sub | List | Blocked users management — designed from spec (no Flutter file) | `kzBEL` | ✅ |

---

## 📅 Phase 6 — Booking

> Full booking flow: user booking, staff booking, booking details — combining both sides.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-------------------------------------|------|---------|--------------------------------------------------------------|--------|--------|
| 34 | User Booking | `booking/user_booking_screen.dart` | Sub | Form | Service selection, date/time picker, notes, book button | `ktDjG` | ✅ |
| 35 | User Booking List | `booking/booking_list_screen.dart` | Sub | List | 4 tabs (all/pending/confirmed/completed), booking cards | `0lXC4` | ✅ |
| 36 | Booking Detail (User) | `booking/booking_list_screen.dart` (bottom sheet) | Sub | Detail | Detail rows: ID, staff, service, date, status, notes + cancel | `ZL2Bi` | ✅ |
| 37 | Booking Detail (Staff) | `staff/booking_detail_screen.dart` | Sub | Detail | Status badge, customer info, booking info, action buttons | `coSAO` | ✅ |
| 38 | Staff Booking Management | `staff/staff_bookings_screen.dart` | Sub | List | 4 tabs with counts, booking cards + confirm/complete/cancel | `XMjWa` | ✅ |
| 39 | Staff Create Booking 🆕 | `staff/staff_create_booking_screen.dart` | Sub | Form | Customer info + service/date/time/notes form — designed from spec | `jwUqD` | ✅ |
| 40 | Create Booking (Legacy) 🆕 | `create_booking_screen.dart` | Sub | Form | Staff card, menu selection, date/time, summary + confirm — designed from spec | `OB7wo` | ✅ |

---

## 💰 Phase 7 — Finance & Tips

> Staff income, withdrawals, revenue dashboard — combining tips (send/receive/history).

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-------------------------------------------|------|-----------|--------------------------------------------------------|--------|--------|
| 41 | Earnings Screen | `staff/earnings_screen.dart` | Sub | Dashboard | Charts + earnings breakdown | `Z7h5L` | ✅ |
| 42 | Revenue Dashboard 🆕 | `staff/revenue_dashboard_screen.dart` | Sub | Dashboard | TabBar, revenue stats, charts — designed from spec (no Flutter file) | `o7Kyb` | ✅ |
| 43 | Staff Payout 🆕 | `staff/staff_payout_screen.dart` | Sub | Form | Bank info + payout request — designed from spec (no Flutter file) | `mfg4M` | ✅ |
| 44 | Staff Tips | `staff/staff_tips_screen.dart` | Sub | List | Tip transactions list (staff side) | `S8VeT` | ✅ |
| 45 | Withdrawal | `staff/withdrawal_screen.dart` | Sub | Form | Amount + bank selection | `td97S` | ✅ |
| 46 | Send Tip | `send_tip_screen.dart` | Sub | Form | Quick amount buttons + form (user side) | `A7aVn` | ✅ |
| 47 | Tip History | `tip_history_screen.dart` | Sub | List | Tip transactions + total (user side) | `rwEGK` | ✅ |

---

## 💬 Phase 8 — Messaging & Chat

> Messaging: chat list, chat room, create message — for both user and staff sides.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|------------------|---------------------------|----------|--------|-------------------------------------------|--------|--------|
| 48 | Messages Screen | `messages_screen.dart` | Main Tab | Main Tab | Chat list + search + unread count | `GFRhe` | ✅ |
| 49 | Chat Screen | `chat_screen.dart` | Sub | Chat | Messages + input bar + attachments | `1SZ3U` | ✅ |
| 50 | User Chat | `user_chat_screen.dart` | Sub | Chat | User-side chat view | `n1Zeo` | ✅ |
| 51 | Create Message | `create_message_screen.dart` | Sub | Form | Select recipient + compose | `hSr6q` | ✅ |
| 52 | Staff Messages | `staff_messages_screen.dart` | Sub | List | Staff inbox list | `C1xm6` | ✅ |
| 53 | Staff Chat | `staff_chat_screen.dart` | Sub | Chat | Staff-side chat view | `3cqhk` | ✅ |

---

## 🏢 Phase 9 — Company & Headhunting

> Company management, headhunting recruitment, send/receive offers — combining company side and staff/user receiving offers.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-----------------------------------------------|------|---------|--------------------------------------------------------|--------|--------|
| 54 | Company Management 🆕 | `company/company_management_screen.dart` | Sub | Dashboard | Company stats + staff overview — designed from spec (no Flutter file) | `o3mgQ` | ✅ |
| 55 | Company Registration 🆕 | `company/company_registration_screen.dart` | Sub | Form | Multi-step company form — designed from spec (no Flutter file) | `HTOTZ` | ✅ |
| 56 | Company Offers 🆕 | `company/company_offers_screen.dart` | Sub | List | Sent/received offers list — designed from spec (no Flutter file) | `AGpPz` | ✅ |
| 57 | Company Staff Management 🆕 | `company/company_staff_management_screen.dart` | Sub | List | Staff roster + status — designed from spec (no Flutter file) | `uVY0u` | ✅ |
| 58 | Send Headhunting Offer 🆕 | `company/send_headhunting_offer_screen.dart` | Sub | Form | Offer details + send — designed from spec (no Flutter file) | `ofETL` | ✅ |
| 59 | Send Store Staff Offer 🆕 | `company/send_store_staff_offer_screen.dart` | Sub | Form | Store position offer form — designed from spec (no Flutter file) | `qINr4` | ✅ |
| 60 | Store Staff Offers List 🆕 | `company/store_staff_offers_list_screen.dart` | Sub | List | Offers per store — designed from spec (no Flutter file) | `LX173` | ✅ |
| 61 | Staff Received Offers 🆕 | `staff_received_offers_screen.dart` | Sub | List | Offer cards + accept/reject (staff side) — designed from spec (no Flutter file) | `lsuDg` | ✅ |
| 62 | Headhunt | `headhunt_screen.dart` | Sub | List | Offers list + empty state (user side) | `itF9Q` | ✅ |
| 63 | Integrated Headhunting 🆕 | `integrated_headhunting_screen.dart` | Sub | Content | Company/registration status display — designed from spec (no Flutter file) | `El9Hf` | ✅ |

---

## 🏪 Phase 10 — Store Management

> Store management: list, create new, edit, view detail.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|------------|-------------------------------------------|------|---------|-----------------------------------------------|--------|--------|
| 64 | Store List | `store_management/store_list_screen.dart` | Sub | List | Store cards + add new 🆕 | `Poejs` | ✅ |
| 65 | Store Signup | `store_management/store_signup_screen.dart` | Sub | Form | Store info + location form 🆕 | `gULB3` | ✅ |
| 66 | Store Edit | `store_management/store_edit_screen.dart` | Sub | Form | Edit store details 🆕 | `uOIRZ` | ✅ |
| 67 | Store Detail | `store_detail_screen.dart` | Sub | Detail | Store info + staff + map | `TxMB0` | ✅ |

---

## 🎥 Phase 11 — Live Streaming

> ⚠️ **Fullscreen screens**: No AppBar/BottomNav. Use `layout: none` + absolute positioning for overlays. Ignore `_stub.dart` files.

> Full live streaming: live list, watch live, go live, battle, league, story, gift.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------|----------------------------------------|------|------------|-------------------------------------------------|--------|--------|
| 68 | Live List | `live_list_screen.dart` | Sub | List | Dark-bg AppBar, ListView live staff | `syvoH` | ✅ |
| 69 | Live Stream | `live_stream_screen.dart` | Full | Fullscreen | VideoPlayer, no AppBar, full-screen | `kXloL` | ✅ |
| 70 | Live Stream List | `live_stream_list_screen.dart` | Sub | List | Active streams + start broadcast button | `vUg05` | ✅ |
| 71 | Live Broadcaster | `live_broadcaster_screen.dart` | Full | Fullscreen | Agora RTC, broadcast controls overlay | `E7sP4` | ✅ |
| 72 | Live Viewer | `live_viewer_screen.dart` | Full | Fullscreen | Agora RTC, comments + gift panel | `rZBuo` | ✅ |
| 73 | Live Shard | `live_shard_screen.dart` | Sub | Detail | Balance card, shard history | — | ⬜ ⚠️ No Flutter file |
| 74 | Live Collab Battle | `live_collab_battle_screen.dart` | Full | Fullscreen | Timer battle system, dual video view | — | ⬜ ⚠️ No Flutter file |
| 75 | Live League | `live_league_screen.dart` | Sub | Content | TabController 2 tabs, league rankings | — | ⬜ ⚠️ No Flutter file |
| 76 | TikTok Live Stream | `live_stream/tiktok_live_stream_screen.dart` | Full | TikTok Card | Full-screen video + comments + gifts | — | ⬜ ⚠️ No Flutter file |
| 77 | Story Viewer | `story_viewer_screen.dart` | Full | Fullscreen | Vertical PageView, progress bars | `SrCKt` | ✅ |
| 78 | Create Collab | `create_collab_screen.dart` | Sub | Form | Radio mode selection + inputs | — | ⬜ ⚠️ No Flutter file |
| 79 | TikTok Gift | `tiktok_gift_screen.dart` | Sub | Custom | TabController gift categories, grid | `warCw` | ✅ |

---

## 📝 Phase 12 — Content & Social

> View posts, following/followers, favorites, saved posts, reviews.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|--------------|---------------------------|------|---------|--------------------------------------------------------|--------|--------|
| 80 | Post Detail | `post_detail_screen.dart` | Sub | Detail | Dark bg, CachedNetworkImage + actions | `qcc97` | ✅ |
| 81 | Following | `following_screen.dart` | Sub | List | TabController 2 tabs (following/followers) | `EngIT` | ✅ |
| 82 | Favorites | `favorites_screen.dart` | Sub | List | Staff grid/list + favorite toggle | `xlToi` | ✅ |
| 83 | Saved Posts | `saved_posts_screen.dart` | Sub | List | 🆕 No Flutter file — designed from spec | `BZncY` | ✅ |
| 84 | My Reviews | `my_reviews_screen.dart` | Sub | List | Reviews list + delete actions | `VKCOM` | ✅ |
| 85 | Write Review | `write_review_screen.dart` | Sub | Form | RatingBar + TextFields + submit | `zxeDi` | ✅ |

---

## 🪙 Phase 13 — Points & Monetization

> Charge points, earn points, buy point packages.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|--------------|----------------------------|------|---------|--------------------------------------------------|--------|--------|
| 86 | Point Charge | `point_charge_screen.dart` | Sub | Form | Balance display + package grid | `F1FI3` | ✅ |
| 87 | Point Earn | `point_earn_screen.dart` | Sub | Content | Check-in card, ad counter, sections | `8cyR5` | ✅ |
| 88 | Point Purchase | `point_purchase_screen.dart` | Sub | Form | Balance + package grid + purchase | `GbxJa` | ✅ |

---

## 🛡️ Phase 14 — Admin

> ⚠️ **Admin screens**: May require a larger viewport (desktop) depending on UI. Evaluate when designing each screen.

> Full admin panel: dashboard, user/staff/company management, moderation, reports.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|----------------------------|----------------------------------------------|----------|-----------|-----------------------------------------------------------|--------|--------|
| 89 | Admin Dashboard | `admin/admin_dashboard_screen.dart` | Main Tab | Dashboard | TabBar nav, stats cards, sections | `7qd1X` | ✅ |
| 90 | Admin Login | `admin/admin_login_screen.dart` | Sub | Form | Email/password + submit | `Xihsl` | ✅ |
| 91 | Admin Push Notification | `admin/admin_push_notification_screen.dart` | Sub | Form | Title/body + target selector + send | `oLZAx` | ✅ |
| 92 | Admin Support Chat | `admin/admin_support_chat_screen.dart` | Sub | List | Ticket list + filter + status badges | `Pc8XL` | ✅ |
| 93 | Company Store Mgmt | `admin/company_store_management_screen.dart` | Sub | List | TabController 2 tabs + search | `fxRzu` | ✅ |
| 94 | Content Moderation (Admin) | `admin/content_moderation_screen.dart` | Sub | List | Content items + approve/reject | `gKJyB` | ✅ |
| 95 | Content Moderation (Screen) | `screens/admin/content_moderation_screen.dart` | Sub | List | Review moderation with NG word detection | `3WBCV` | ✅ |
| 96 | Live Revenue Mgmt | `admin/live_revenue_management_screen.dart` | Sub | Dashboard | TabController 3 tabs, top staff/fans | `wvlTF` | ✅ |
| 97 | Reports | `admin/reports_screen.dart` | Sub | Content | Stats display + export CSV/PDF | `WutHB` | ✅ |
| 98 | SNS Management | `admin/sns_management_screen.dart` | Sub | Dashboard | TabController 4 tabs, stats overview | `RKFTw` | ✅ |
| 99 | Staff Mgmt (Admin) | `admin/staff_management_screen.dart` | Sub | List | Staff list + filter + status management | `DilPJ` | ✅ |
| 100 | Users Management | `admin/users_management_screen.dart` | Sub | List | User list + filter + profile cards | `TADKf` | ✅ |
| 101 | Booking Debug | `booking_system_debug_screen.dart` | Sub | Custom | Debug UI — skipped (no Flutter file) | — | ⏭️ |

---

## 📜 Phase 15 — Support & Legal

> Support, support chat, policies, terms.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|----------------|-------------------------------|------|---------|------------------------------------------------|--------|--------|
| 102 | Help & Support | `help_support_screen.dart` | Sub | Content | Card links to support options | — | ⬜ |
| 103 | Support Chat | `support_chat_screen.dart` | Sub | Chat | Messages list + text input + auto-reply | — | ⬜ |
| 104 | Privacy Policy | `privacy_policy_screen.dart` | Sub | Content | Scrollable policy sections | — | ⬜ |
| 105 | Terms & Guidelines | `terms/terms_and_guidelines_screen.dart` | Sub | Content | Sidebar + main content (desktop-like) | — | ⬜ |

---

## 🔑 Quick Reference — Pattern → How to build

> See full details in `CLAUDE.md` → Design Patterns section

| Pattern | Header used | Bottom Nav | Main content |
|---------|-------------|------------|----------------|
| **Form** | Page Header (`7WceB`) | ❌ | Inputs + buttons, gap 14, padding [8,24,32,24] |
| **Main Tab** | App Header (`BV8WU`) | ✅ `uvJfu` | Content area `fill_container` |
| **TikTok Card** | ❌ (overlay) | ❌ | Full-bleed image + Frosted Glass Panel |
| **List** | Page Header (`7WceB`) | ❌ | ListView items, show 2–3 samples |
| **Detail** | Page Header (`7WceB`) | ❌ | Info sections + action buttons |
| **Dashboard** | Page Header / App Header | Depends | Stats cards + charts + sections |
| **Chat** | Page Header (`7WceB`) | ❌ | Messages list + bottom input bar |
| **Content** | Page Header (`7WceB`) | ❌ | Scrollable text/sections |
| **Fullscreen** | ❌ (overlay controls) | ❌ | `layout: none`, absolute positioning |
| **Custom** | Depends on code | Depends | Read Flutter code to decide |

### Every screen starts with

```
0. Title text label ABOVE screen   ← y:-24, DM Sans 14px 600, $text-secondary
1. Status Bar (ref: ldWqh)         ← always present
2. Header (`BV8WU` or `7WceB`)     ← except Fullscreen
3. Content area                    ← depends on pattern
4. Bottom Nav (ref: `uvJfu`)       ← only for Main Tab screens
```

### Reusable Component IDs

| Component | ID | Children IDs | Usage |
|-----------|-----|-------------|-------|
| Status Bar | `ldWqh` | — | Every screen |
| Page Header | `7WceB` | `X8N7G` (title) | Sub screens |
| App Header | `BV8WU` | — | Main Tab screens |
| Bottom Nav | `uvJfu` | `TilAD`/`8P449` (active tabs) | Main Tab screens |
| Text Input | `5s7lH` | `eNhXM` (label), `EmHTZ` (icon), `Pi7hj` (placeholder) | Forms |
| Primary Button | `GEzdp` | `cjFos` (icon), `7eYyB` (label) | CTAs |
| Outline Button | `ryVY1` | `gePVo` (icon), `1qxCz` (label) | Secondary actions |
| Toggle On | `vBsZB` | `yZAka` (dot) | Settings toggles |
| Toggle Off | `DgPzr` | `Wb6nS` (dot) | Settings toggles |
| Toggle Row | `u1Yy9` | `FhFRE` (icon), `ZMwx7` (label), `YsnOQ` (toggle ref) | Simple toggle rows |
| Toggle Row v2 | `57W3c` | `Oj6at` (icon), `DsAGp` (title), `RzHvC` (subtitle), `r5KTK` (toggle ref) | Toggle rows with subtitle |
| Menu Row | `LXBAI` | `bLCvS` (icon), `m1coJ` (label), `jksYF` (chevron) | Navigation lists |
| Section Header | `7I80j` | `xFJu0` (title) | Section dividers |
| Tab Switcher | `IBKG4` | `bZQNd`/`Y2hFU` (tabs) | Tab views |
| Frosted Glass | `aFGSi` | — | TikTok overlay |

### Spacing Rules

| Element | Horizontal Padding | Notes |
|---------|-------------------|-------|
| Content wrappers | **20** | Cards, sections, forms — match Flutter `horizontal: 20` |
| Component internals | **20** | Menu Row, Toggle Row, Section Header — auto via component |
| Card internal padding | **16** | Inside gradient cards (tip, gifter, staff) |

### Color Tokens, Typography, Spacing → see Design System `sCUIU`

### ⚠️ Component Padding Rules — CRITICAL

> Components like Section Header, Toggle Row, Menu Row have **built-in LR padding = 20px**. NEVER put them inside a parent that also has LR padding — this causes **double padding (40px)**.

| Scenario | Parent padding | Component padding | Result | Fix |
|----------|---------------|-------------------|--------|-----|
| Settings/List screen (all components) | `padding: 0` | Built-in 20px | ✅ 20px | No fix needed — follow Phase 3 pattern |
| Form screen (mix of components + inputs) | `padding: 20` | Built-in 20px | ❌ 40px | Override component: `padding: [16, 0, 8, 0]` |
| Detail screen (sections with custom content) | `padding: 0` on section | Built-in 20px | ✅ 20px | Wrap custom content in `padding: [0, 20, 16, 20]` frame |

**Rules:**
1. **Settings/List screens** (all Section Header + Toggle Row + Menu Row): Parent content frame has **NO padding**. Each component handles its own 20px LR padding.
2. **Form screens** (Section Header mixed with Text Input): Parent has `padding: 20` for inputs. Override Section Header instances with `padding: [16, 0, 8, 0]` to remove LR.
3. **Detail screens** (Section Header + custom cards): Parent section has **NO padding**. Section Header uses built-in padding. Wrap custom content (cards, stat rows) in a frame with `padding: [0, 20, 16, 20]`.
4. **Reference screen**: Privacy Settings (`ymOBw`) is the gold standard — content frame has NO padding, all components self-pad.

### ⚠️ Phase Label Rules

> Every phase group MUST have a title label placed ABOVE the group on the canvas.

| Property | Value |
|----------|-------|
| Font | `Bricolage Grotesque` |
| Size | `28` |
| Weight | `700` |
| Fill | `#FFFFFF` |
| Position | ~50px above group (same x, y = group.y - 50) |
| Name | `phase{N}Label` |
| Format | `{emoji} Phase {N} — {Phase Name}` |

**Examples:** `OXtmK` (Phase 8), `OOrSB` (Phase 9), `bGp9G` (Phase 10)

### ⚠️ Icon Rules

| Context | Icon Font Family | Why |
|---------|-----------------|-----|
| Flutter `Icons.*` mapping | `Material Symbols Rounded` | Filled icons, matches Flutter Material |
| Star ratings | `Material Symbols Rounded` star | Filled ★ not outline ☆ |
| UI actions (chevron, plus, search) | `lucide` | Clean line icons for UI chrome |
| **NEVER** | `lucide` star | Shows as outline ☆, visually wrong for ratings |

### ⚠️ Stat Card Rules

| Card Type | Use | Wrong | Right |
|-----------|-----|-------|-------|
| Dashboard stats | Flat white + border | ❌ Plain cards | ✅ Gradient cards (see CLAUDE.md 2.5) |
| Store/staff stats | Gradient with white text | ❌ `fill: "$surface"` | ✅ `fill: {type:"gradient",...}` |
| Color by context | Match semantic meaning | — | Green=staff, Amber=rating, Blue=booking/jobs |

---

## ⚠️ Flutter Fidelity Rules — MUST follow for every screen

> These rules are mandatory. Every screen design MUST pass all checks before marking ✅.

### Step 1: Read Flutter code FIRST

- **Always** read the full Flutter file before designing or modifying a screen
- Extract EVERY UI element: text content, font sizes, font weights, colors, icons, padding, spacing
- Do NOT guess or approximate — use exact values from the code

### Step 2: Match Flutter exactly

| Property | Rule |
|----------|------|
| **Font sizes** | Use exact `fontSize` from Flutter (e.g., 24px means 24, not 22) |
| **Font weights** | Map Flutter `FontWeight.bold` → `"700"`, `w500` → `"500"`, etc. |
| **Icons** | Use `Material Symbols Rounded` for Flutter `Icons.*`. Use lucide only if Material Symbols doesn't have the icon |
| **Icon sizes** | Match Flutter `size:` parameter exactly (e.g., 24px, 28px) |
| **Colors** | Use design system variables (`$text-primary`, `$green`, etc.) that map to the Flutter color. Never hardcode hex unless no variable exists |
| **Spacing/Gap** | Match `SizedBox` height/width values. Match `EdgeInsets` padding values |
| **Content** | Include ALL text exactly as in Flutter, including emoji (e.g., "4.8⭐" not "4.8") |

### Step 3: Widget mapping

| Flutter Widget | Pencil Implementation |
|---------------|----------------------|
| `Card(elevation: N)` | Frame with `fill: "$white"`, `cornerRadius: 12`, `effect: {type: "shadow", shadowType: "outer", offset: {x: 0, y: 1}, blur: 3, color: "#00000026"}` |
| `Container(color.withAlpha(0.1), border)` | Frame with `fill: "<color>1A"`, `stroke: {fill: "<color>", thickness: 1}`, `cornerRadius: 12` |
| `AppBar` | Use Page Header (`7WceB`) for Sub screens, App Header (`BV8WU`) for Main Tab. If custom header needed, MUST have horizontal padding >= 16px |
| `Switch` | Use Toggle On/Off (`vBsZB`/`DgPzr`) |
| `BottomNavigationBar` | Use Bottom Nav (`uvJfu`) — override labels/icons to match screen context (staff vs customer) |
| `ListView` / `SingleChildScrollView` | Scrollable frame with `clip: true`, `height: "fill_container"` |

### Step 4: Bottom Nav context

- **Customer screens**: ホーム, 配信, 検索, MSG, MY (default `uvJfu`)
- **Staff screens**: ダッシュ, 投稿, 予約, チップ, プロフ (override via descendants)
- NEVER use customer nav on staff screens or vice versa

### Step 5: Design system compliance

- All text colors → use `$text-primary`, `$text-secondary`, `$text-tertiary`
- All backgrounds → use `$bg`, `$surface`, `$white`, `$surface-elevated`
- All borders → use `$border`, `$border-light`, `$border-subtle`
- Brand colors → use `$primary`, `$accent`, `$green`, `$purple`, `$indigo`, `$orange`
- Status colors → use `$success`, `$error`, `$warning`
- Hardcoded hex only for: gradient stops, alpha-blended fills (e.g., `#2196F31A`), or colors not in the token set

### Step 6: Verify

- Take screenshot after completing each screen
- Compare visually against Flutter code structure
- Check: all content present? Font sizes correct? Icons correct? Colors from design system? Padding not zero?

---

## 🔀 Changes vs old plan (v2 → v3)

| Change | Details |
|----------|---------|
| Phase 0 → reference only | Login/Register/Home moved to Phase 1 & 2 by function |
| Split old Phase 4 (14 screens) | → Phase 4 (Staff Profile, 5), Phase 5 (Content & Services, 6), move Booking & Offers out |
| Merge Booking | Staff Booking (old Phase 4) + User Booking (old Phase 8) + Create Booking Legacy (old Phase 10) → Phase 6 |
| Merge Tips | Staff Tips (old Phase 5) + Send Tip & Tip History (old Phase 10) → Phase 7 Finance & Tips |
| Split Company & Store | Company + Headhunting Offers → Phase 9; Store → Phase 10 |
| Headhunting merged with Company | Staff Received Offers, Headhunt, Integrated Headhunting (old Phase 4/10) → Phase 9 |
| Phase 12 Content & Social | Only pure content: Posts, Following, Favorites, Saved Posts, Reviews |
| Total phases | 14 → 16 (Phase 0–15), but Phase 0 has no screens |

---

## 📈 Changelog

| Date | Action | Details |
|------|--------|---------|
| 2026-03-13 | Create plan | Initialize `plan_design.md` with 105 screens, 14 phases |
| 2026-03-13 | Update v2 | Add Type/Pattern/Notes columns, Quick Reference Pattern table, `CLAUDE.md` link |
| 2026-03-14 | Update v3 | Reorganize phases by function: split Staff, merge Booking, merge Tips, split Company/Store |
| — | Login Screen | ✅ Pen ID: `74eTp` |
| — | Register Screen | ✅ Pen ID: `rqOcp` |
| — | Home Screen | ✅ Pen ID: `sli1z` |
| 2026-03-17 | Phase 1 complete | ✅ Group ID: `E1WTT` — Registration Type Selection (`gnGfu`), Password Change (`isNVH`), Staff Registration (`yoNSa`), Company Signup (`FAQHh`) |
| 2026-03-17 | Phase 2 complete | ✅ Group ID: `TyKkn` — Staff Feed (`2GZUU`), Search (`0lv8m`), Map Search (`be2TB`), Filter Settings (`8kx7Y`), Ranking (`8rKJn`), Notifications (`kWH3k`), Notification List (`va8Sd`), Live Feed (`5Jq0e`) |
| 2026-03-18 | Phase 3 complete | ✅ Group ID: `Kijn1` — Profile (`tpWuw`), Profile Edit (`zt914`), Profile Settings (`oOuBu`), Privacy Settings (`ymOBw`), Notification Settings (`N0k6r`), Notification Settings New (`HPbbA`), User Block Management (`qEYvB`) |
| 2026-03-18 | New components | Added Toggle On (`vBsZB`), Toggle Off (`DgPzr`), Toggle Row (`u1Yy9`), Menu Row (`LXBAI`), Section Header (`7I80j`) to Design System |
| 2026-03-18 | Refactor Phase 3 | Replaced manual toggle switches, menu items, section headers with reusable components across all 7 screens |
| 2026-03-18 | Toggle Row v2 | Added `57W3c` — Toggle Row with subtitle support (icon + title + subtitle + toggle) |
| 2026-03-18 | Content fidelity fix | Privacy Settings: added missing ギフト履歴, 検索・発見, データ管理 sections. Notification screens: added subtitles to all toggles |
| 2026-03-18 | Padding standardize | All content LR padding = 20px (match Flutter `horizontal: 20`). Updated all components + screens |
| 2026-03-18 | Phase 4 complete | ✅ All 5 screens: Staff Detail (`00M7S`), Staff Dashboard (`TrDRs`), Staff Profile Edit (`IvtWb`), Staff Profile (`g99JQ`), Staff Management Profile (`qTixn`). Group ID: `OX5fq`. #24 and #27 designed from STAFF-07 spec — gradient avatar ring, portfolio grid, stats row, menu rows with component refs |
| 2026-03-18 | Phase 4 (partial) | ✅ Staff Detail (`rSnrr`), Staff Dashboard (`YiWll`), Staff Profile Edit (`Ek3Mz`). Rebuilt with correct design system (Bricolage Grotesque/DM Sans fonts, gradient cards, component refs). 2 screens skipped — Flutter files not found |
| 2026-03-18 | Phase 4 redesign | ✅ Redesigned all 3 screens from scratch: Staff Detail (`WPuU7`), Staff Dashboard (`459L5`), Staff Profile Edit (`NfE2P`). Group ID: `2BzaU`. Hero image with gradient overlay, gradient stat cards, review section with rating bars, quick action buttons with colored borders |
| 2026-03-19 | Staff Dashboard fix (`LqIKs`) | Fixed Flutter fidelity: stat cards (gradient → white + shadow), action buttons (Menu Row → colored bg + border), bottom nav (customer → staff), font sizes (22→24, 15→16, 12→14), icon sizes/families (lucide → Material Symbols Rounded), rating "4.8⭐", design system variables throughout, header padding |
| 2026-03-19 | Flutter Fidelity Rules | Added mandatory "⚠️ Flutter Fidelity Rules" section to plan — 6-step checklist: read Flutter first, match exactly, widget mapping, bottom nav context, design system compliance, verify with screenshot |
| 2026-03-19 | Phase 5 complete | ✅ All 6 screens. Group ID: `DzmLj`. Staff Posts (`Yip4g`), Staff Posts Management (`60Ls9`), Create Post (`NwUbN`) — from Flutter code. Staff Menu Management 🆕(`vWqEA`), Staff Coupon Management 🆕(`5i0vL`), Staff Block Management 🆕(`kzBEL`) — designed from spec (no Flutter file, marked NEW on canvas) |
| 2026-03-19 | Phase 6 complete | ✅ All 7 screens. Group ID: `4eLsX`. User Booking (`ktDjG`), User Booking List (`0lXC4`), Booking Detail User (`ZL2Bi`), Booking Detail Staff (`coSAO`), Staff Booking Management (`XMjWa`) — from Flutter code. Staff Create Booking 🆕(`jwUqD`), Create Booking Legacy 🆕(`OB7wo`) — designed from spec (no Flutter file) |
| 2026-03-19 | Phase 7 complete | ✅ All 7 screens. Group ID: `z2Dp7`. Earnings (`Z7h5L`), Staff Tips (`S8VeT`), Withdrawal (`td97S`), Send Tip (`A7aVn`), Tip History (`rwEGK`) — from Flutter code. Revenue Dashboard 🆕(`o7Kyb`), Staff Payout 🆕(`mfg4M`) — designed from spec (no Flutter file) |
| 2026-03-19 | Phase 8 complete | ✅ All 6 screens. Group ID: `2PCgM`. Messages Screen (`GFRhe`) — Main Tab with MSG active, 4 message tiles with read/unread states. Chat Screen (`1SZ3U`), User Chat (`n1Zeo`) — chat bubbles with read receipts + videocam/call. Create Message (`hSr6q`) — staff info + textarea + quick chips. Staff Messages (`C1xm6`) — 5 chat rooms with online dots + unread badges. Staff Chat (`3cqhk`) — grey bg, date separators, sender names, white bubbles with shadow |
| 2026-03-19 | Phase 9 complete | ✅ All 10 screens. Group ID: `jpIms`. Headhunt (`itF9Q`) — from Flutter code, offer cards with company/position/salary/location, action buttons. 9 screens designed from spec 🆕: Company Management (`o3mgQ`) — dashboard with 7 stat cards + 6 quick actions. Company Registration (`HTOTZ`) — step progress bar + form fields. Company Offers (`AGpPz`) — 4-tab filter + offer cards with status badges. Company Staff Management (`uVY0u`) — search + staff roster with online status. Send Headhunting Offer (`ofETL`) — staff card + form. Send Store Staff Offer (`qINr4`) — store card + form. Store Staff Offers List (`LX173`) — store info + offer cards. Staff Received Offers (`lsuDg`) — offer cards with accept/reject buttons. Integrated Headhunting (`El9Hf`) — verified status card + menu rows + plan info |
| 2026-03-23 | Phase 10 complete | ✅ All 4 screens. Group ID: `0xH9m`. Store Detail (`TxMB0`) — from Flutter code, gradient header with store icon/name/company/stats, 3 staff cards with photo/online badge/job badge/rating/followers/experience/distance, store info stat cards. 3 screens designed from spec 🆕: Store List (`Poejs`) — add button + 3 store cards with image/category badge/rating/address/staff count. Store Signup (`gULB3`) — image upload + 5 form fields + business hours + submit button. Store Edit (`uOIRZ`) — pre-filled image + 5 form fields + business hours + save button |
| 2026-03-23 | Phase 12 complete | ✅ All 6 screens. Group ID: `7Cwd5`. Rebuilt with design system compliance: gradient stat cards, circular avatars with primary border, Material Symbols Rounded filled stars, Outline Button component refs, proper 20px padding. Post Detail (`qcc97`) — dark bg, hero image, Material Symbols action row (favorite/mode_comment/bookmark), like count, caption, timestamp. Following (`EngIT`) — Tab Switcher with customized labels (フォロー中 5/フォロワー 128), blue gradient stats card, 3 staff cards with circular avatars + Outline Button refs. Favorites (`xlToi`) — coral gradient header with heart icon, 2 staff cards with 90x90 image + online badge + filled stars + location. Saved Posts 🆕(`BZncY`) — green gradient header, 3x2 post grid. My Reviews (`VKCOM`) — blue + amber gradient stat cards (投稿数/平均評価), 2 review cards with circular avatars + filled stars + delete + schedule icon. Write Review (`zxeDi`) — circular avatar staff card, 5 large filled stars + 非常に満足 text, textarea with border-subtle, Primary Button component ref |
