# Juan's Work Board

A kanban-style work tracker that runs in any modern browser and installs as an app on Windows and Android (it is a PWA, so one build serves both).

## What it does

- Columns you can rename, reorder, add and remove (default: Backlog, To do, In progress, Waiting on others, Done). A column can have a card limit, and any column can be marked as a finish column.
- Cards with a ticket number (T-001), owner, priority, due date, tags, notes and a checklist.
- Drag cards between columns. On a phone, drag with the ⠿ handle on the card; on a computer, drag the whole card.
- Summary chips for overdue, due in 7 days, urgent and finished this week. Click one to filter.
- Search and filter by person or priority. Keyboard: `N` new card, `/` search.
- Works offline once installed.

## Where the data lives

- **Online version** (the claude.ai link): the board is stored in the artifact's own database and syncs live across every device signed in to your claude.ai account. One document holds the board settings (`board/meta`) and each card is its own document (`cards/<id>`). If someone is later given edit access to the link, they work on the same board.
- **Self-hosted copy** (`index.html` on your own host): falls back to saving in that browser only. Board settings has Copy backup / Save backup file to move it between devices.

The same `src/app.html` runs both ways: it uses the online database when it opens inside claude.ai and local storage anywhere else.

## Files

| File | Purpose |
| --- | --- |
| `src/app.html` | The whole app (markup, styles, script). Edit this. |
| `build.sh` | Wraps `src/app.html` into `index.html` with the install metadata. Run `sh build.sh` after edits. |
| `index.html` | The installable app page. |
| `manifest.webmanifest`, `icons/` | App name and icons for install. |
| `sw.js` | Offline cache. |

## Installing it on Windows and Android

Browsers only offer "Install" for a page served over HTTPS, so the folder has to be hosted somewhere first. Free static hosts that work: GitHub Pages, Netlify, Cloudflare Pages. Upload this folder as-is, then:

- **Windows (Edge or Chrome):** open the link, then the install icon in the address bar (or menu, Apps, Install this site as an app). It gets a Start menu entry and its own window.
- **Android (Chrome):** open the link, then menu, Add to Home screen, Install.

Each device keeps its own copy of the board until a shared version exists.

## Making it shared for multiple people

The data model already has people, owners and per-card timestamps, so cards carry over. A shared board needs three more things:

1. **Sign-in**, so each person has an account (email link or Google/Microsoft login).
2. **A shared database** that holds the board instead of each browser, with live updates so a moved card shows for everyone.
3. **Access rules**, for example who can edit, and whether some people only see their own cards.

The lowest-effort route is a hosted backend such as Supabase or Firebase, both with free tiers that cover a small team. The app would swap its `save()`/`load()` calls for that database and add a sign-in screen. Hosting the app itself stays on a free static host.
