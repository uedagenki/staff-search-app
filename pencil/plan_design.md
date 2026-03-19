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
| 5 | Staff Content & Services | 6 | 0 | 6 | — |
| 6 | Booking | 7 | 0 | 7 | — |
| 7 | Finance & Tips | 7 | 0 | 7 | — |
| 8 | Messaging & Chat | 6 | 0 | 6 | — |
| 9 | Company & Headhunting | 10 | 0 | 10 | — |
| 10 | Store Management | 4 | 0 | 4 | — |
| 11 | Live Streaming | 12 | 0 | 12 | — |
| 12 | Content & Social | 6 | 0 | 6 | — |
| 13 | Points & Monetization | 3 | 0 | 3 | — |
| 14 | Admin | 13 | 0 | 13 | — |
| 15 | Support & Legal | 4 | 0 | 4 | — |
| | **TOTAL** | **105** | **27** | **78** | |

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
| 28 | Staff Posts | `staff_posts_screen.dart` | Sub | List | Grid/list of staff posts | — | ⬜ |
| 29 | Staff Posts Management | `staff/staff_posts_management_screen.dart` | Sub | List | CRUD post management | — | ⬜ |
| 30 | Create Post | `staff/create_post_screen.dart` | Sub | Form | Image upload + caption + tags | — | ⬜ |
| 31 | Staff Menu Management | `staff/staff_menu_management_screen.dart` | Sub | List | Service menu items CRUD | — | ⬜ |
| 32 | Staff Coupon Management | `staff/staff_coupon_management_screen.dart` | Sub | List | Coupon cards CRUD | — | ⬜ |
| 33 | Staff Block Management | `staff/staff_block_management_screen.dart` | Sub | List | Blocked users management | — | ⬜ |

---

## 📅 Phase 6 — Booking

> Full booking flow: user booking, staff booking, booking details — combining both sides.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-------------------------------------|------|---------|--------------------------------------------------------------|--------|--------|
| 34 | User Booking | `booking/user_booking_screen.dart` | Sub | List | TabController 3 tabs (upcoming/completed/cancelled) | — | ⬜ |
| 35 | User Booking List | `booking/user_booking_list_screen.dart` | Sub | List | TableCalendar + booking list | — | ⬜ |
| 36 | Booking Detail (User) | `booking/booking_detail_screen.dart` | Sub | Detail | Status card, info sections | — | ⬜ |
| 37 | Booking Detail (Staff) | `staff/booking_detail_screen.dart` | Sub | Detail | Status management, booking info | — | ⬜ |
| 38 | Staff Booking Management | `staff/staff_booking_management_screen.dart` | Sub | List | Booking schedule + status | — | ⬜ |
| 39 | Staff Create Booking | `staff/staff_create_booking_screen.dart` | Sub | Form | Date/time/service form | — | ⬜ |
| 40 | Create Booking (Legacy) | `create_booking_screen.dart` | Sub | Form | Date/time pickers, menu selection | — | ⬜ |

---

## 💰 Phase 7 — Finance & Tips

> Staff income, withdrawals, revenue dashboard — combining tips (send/receive/history).

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-------------------------------------------|------|-----------|--------------------------------------------------------|--------|--------|
| 41 | Earnings Screen | `staff/earnings_screen.dart` | Sub | Dashboard | Charts + earnings breakdown | — | ⬜ |
| 42 | Revenue Dashboard | `staff/revenue_dashboard_screen.dart` | Sub | Dashboard | TabBar, revenue stats, charts | — | ⬜ |
| 43 | Staff Payout | `staff/staff_payout_screen.dart` | Sub | Form | Bank info + payout request | — | ⬜ |
| 44 | Staff Tips | `staff/staff_tips_screen.dart` | Sub | List | Tip transactions list (staff side) | — | ⬜ |
| 45 | Withdrawal | `staff/withdrawal_screen.dart` | Sub | Form | Amount + bank selection | — | ⬜ |
| 46 | Send Tip | `send_tip_screen.dart` | Sub | Form | Quick amount buttons + form (user side) | — | ⬜ |
| 47 | Tip History | `tip_history_screen.dart` | Sub | List | Tip transactions + total (user side) | — | ⬜ |

---

## 💬 Phase 8 — Messaging & Chat

> Messaging: chat list, chat room, create message — for both user and staff sides.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|------------------|---------------------------|----------|--------|-------------------------------------------|--------|--------|
| 48 | Messages Screen | `messages_screen.dart` | Main Tab | Main Tab | Chat list + search + unread count | — | ⬜ |
| 49 | Chat Screen | `chat_screen.dart` | Sub | Chat | Messages + input bar + attachments | — | ⬜ |
| 50 | User Chat | `user_chat_screen.dart` | Sub | Chat | User-side chat view | — | ⬜ |
| 51 | Create Message | `create_message_screen.dart` | Sub | Form | Select recipient + compose | — | ⬜ |
| 52 | Staff Messages | `staff_messages_screen.dart` | Sub | List | Staff inbox list | — | ⬜ |
| 53 | Staff Chat | `staff_chat_screen.dart` | Sub | Chat | Staff-side chat view | — | ⬜ |

---

## 🏢 Phase 9 — Company & Headhunting

> Company management, headhunting recruitment, send/receive offers — combining company side and staff/user receiving offers.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------------|-----------------------------------------------|------|---------|--------------------------------------------------------|--------|--------|
| 54 | Company Management | `company/company_management_screen.dart` | Sub | Dashboard | Company stats + staff overview | — | ⬜ |
| 55 | Company Registration | `company/company_registration_screen.dart` | Sub | Form | Multi-step company form | — | ⬜ |
| 56 | Company Offers | `company/company_offers_screen.dart` | Sub | List | Sent/received offers list | — | ⬜ |
| 57 | Company Staff Management | `company/company_staff_management_screen.dart` | Sub | List | Staff roster + status | — | ⬜ |
| 58 | Send Headhunting Offer | `company/send_headhunting_offer_screen.dart` | Sub | Form | Offer details + send | — | ⬜ |
| 59 | Send Store Staff Offer | `company/send_store_staff_offer_screen.dart` | Sub | Form | Store position offer form | — | ⬜ |
| 60 | Store Staff Offers List | `company/store_staff_offers_list_screen.dart` | Sub | List | Offers per store | — | ⬜ |
| 61 | Staff Received Offers | `staff_received_offers_screen.dart` | Sub | List | Offer cards + accept/reject (staff side) | — | ⬜ |
| 62 | Headhunt | `headhunt_screen.dart` | Sub | List | Offers list + empty state (user side) | — | ⬜ |
| 63 | Integrated Headhunting | `integrated_headhunting_screen.dart` | Sub | Content | Company/registration status display | — | ⬜ |

---

## 🏪 Phase 10 — Store Management

> Store management: list, create new, edit, view detail.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|------------|-------------------------------------------|------|---------|-----------------------------------------------|--------|--------|
| 64 | Store List | `store_management/store_list_screen.dart` | Sub | List | Store cards + add new | — | ⬜ |
| 65 | Store Signup | `store_management/store_signup_screen.dart` | Sub | Form | Store info + location form | — | ⬜ |
| 66 | Store Edit | `store_management/store_edit_screen.dart` | Sub | Form | Edit store details | — | ⬜ |
| 67 | Store Detail | `store_detail_screen.dart` | Sub | Detail | Store info + staff + map | — | ⬜ |

---

## 🎥 Phase 11 — Live Streaming

> ⚠️ **Fullscreen screens**: No AppBar/BottomNav. Use `layout: none` + absolute positioning for overlays. Ignore `_stub.dart` files.

> Full live streaming: live list, watch live, go live, battle, league, story, gift.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|---------------------|----------------------------------------|------|------------|-------------------------------------------------|--------|--------|
| 68 | Live List | `live_list_screen.dart` | Sub | List | Dark-bg AppBar, ListView live staff | — | ⬜ |
| 69 | Live Stream | `live_stream_screen.dart` | Full | Fullscreen | VideoPlayer, no AppBar, full-screen | — | ⬜ |
| 70 | Live Stream List | `live_stream_list_screen.dart` | Sub | List | Active streams + start broadcast button | — | ⬜ |
| 71 | Live Broadcaster | `live_broadcaster_screen.dart` | Full | Fullscreen | Agora RTC, broadcast controls overlay | — | ⬜ |
| 72 | Live Viewer | `live_viewer_screen.dart` | Full | Fullscreen | Agora RTC, comments + gift panel | — | ⬜ |
| 73 | Live Shard | `live_shard_screen.dart` | Sub | Detail | Balance card, shard history | — | ⬜ |
| 74 | Live Collab Battle | `live_collab_battle_screen.dart` | Full | Fullscreen | Timer battle system, dual video view | — | ⬜ |
| 75 | Live League | `live_league_screen.dart` | Sub | Content | TabController 2 tabs, league rankings | — | ⬜ |
| 76 | TikTok Live Stream | `live_stream/tiktok_live_stream_screen.dart` | Full | TikTok Card | Full-screen video + comments + gifts | — | ⬜ |
| 77 | Story Viewer | `story_viewer_screen.dart` | Full | Fullscreen | Vertical PageView, progress bars | — | ⬜ |
| 78 | Create Collab | `create_collab_screen.dart` | Sub | Form | Radio mode selection + inputs | — | ⬜ |
| 79 | TikTok Gift | `tiktok_gift_screen.dart` | Sub | Custom | TabController gift categories, grid | — | ⬜ |

---

## 📝 Phase 12 — Content & Social

> View posts, following/followers, favorites, saved posts, reviews.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|--------------|---------------------------|------|---------|--------------------------------------------------------|--------|--------|
| 80 | Post Detail | `post_detail_screen.dart` | Sub | Detail | Dark bg, CachedNetworkImage + actions | — | ⬜ |
| 81 | Following | `following_screen.dart` | Sub | List | TabController 2 tabs (following/followers) | — | ⬜ |
| 82 | Favorites | `favorites_screen.dart` | Sub | List | Staff grid/list + favorite toggle | — | ⬜ |
| 83 | Saved Posts | `saved_posts_screen.dart` | Sub | List | Saved items, load on demand | — | ⬜ |
| 84 | My Reviews | `my_reviews_screen.dart` | Sub | List | Reviews list + delete actions | — | ⬜ |
| 85 | Write Review | `write_review_screen.dart` | Sub | Form | RatingBar + TextFields + submit | — | ⬜ |

---

## 🪙 Phase 13 — Points & Monetization

> Charge points, earn points, buy point packages.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|--------------|----------------------------|------|---------|--------------------------------------------------|--------|--------|
| 86 | Point Charge | `point_charge_screen.dart` | Sub | Form | Balance display + package grid | — | ⬜ |
| 87 | Point Earn | `point_earn_screen.dart` | Sub | Content | Check-in card, ad counter, sections | — | ⬜ |
| 88 | Point Purchase | `point_purchase_screen.dart` | Sub | Form | Balance + package grid + purchase | — | ⬜ |

---

## 🛡️ Phase 14 — Admin

> ⚠️ **Admin screens**: May require a larger viewport (desktop) depending on UI. Evaluate when designing each screen.

> Full admin panel: dashboard, user/staff/company management, moderation, reports.

| # | Screen | Flutter File | Type | Pattern | Notes | Pen ID | Status |
|---|----------------------------|----------------------------------------------|----------|-----------|-----------------------------------------------------------|--------|--------|
| 89 | Admin Dashboard | `admin/admin_dashboard_screen.dart` | Main Tab | Dashboard | TabBar nav, stats cards, sections | — | ⬜ |
| 90 | Admin Login | `admin/admin_login_screen.dart` | Sub | Form | Email/password + submit | — | ⬜ |
| 91 | Admin Push Notification | `admin/admin_push_notification_screen.dart` | Sub | Form | Title/body + target selector + send | — | ⬜ |
| 92 | Admin Support Chat | `admin/admin_support_chat_screen.dart` | Sub | List | Ticket list + filter + status badges | — | ⬜ |
| 93 | Company Store Mgmt | `admin/company_store_management_screen.dart` | Sub | List | TabController 2 tabs + search | — | ⬜ |
| 94 | Content Moderation (Admin) | `admin/content_moderation_screen.dart` | Sub | List | Content items + approve/reject | — | ⬜ |
| 95 | Content Moderation (Screen) | `screens/admin/content_moderation_screen.dart` | Sub | List | May duplicate #94 — confirm when designing | — | ⬜ |
| 96 | Live Revenue Mgmt | `admin/live_revenue_management_screen.dart` | Sub | Dashboard | TabController 3 tabs, top staff/fans | — | ⬜ |
| 97 | Reports | `admin/reports_screen.dart` | Sub | Content | Stats display + export CSV/PDF | — | ⬜ |
| 98 | SNS Management | `admin/sns_management_screen.dart` | Sub | Dashboard | TabController 4 tabs, stats overview | — | ⬜ |
| 99 | Staff Mgmt (Admin) | `admin/staff_management_screen.dart` | Sub | List | Staff list + filter + status management | — | ⬜ |
| 100 | Users Management | `admin/users_management_screen.dart` | Sub | List | User list + filter + profile cards | — | ⬜ |
| 101 | Booking Debug | `booking_system_debug_screen.dart` | Sub | Custom | Debug UI — can be skipped | — | ⬜ |

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
