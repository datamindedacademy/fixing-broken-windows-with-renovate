# Fixing broken windows with Renovate: the slide deck

The course slides, written in [Slidev](https://sli.dev) with the Dataminded theme. The deck
follows the modules in [`../session/`](../session/) one to one.

```bash
cd slides
npm install        # once
npm run dev        # live preview on localhost:3030, press "p" for presenter mode
npm run export     # writes Fixing-broken-windows-with-Renovate.pdf (needs playwright-chromium)
npm run build      # static site in dist/
```

## Layout

| Path | What it is |
| --- | --- |
| `slides.md` | Entry: headmatter, cover slide and `src:` includes |
| `parts/` | One file per course module (`00-intro.md` … `09-rolling-out.md`). Speaker notes live in HTML comments. |
| `style.css` | Deck-wide helpers: agenda fit, `dm-table`, exercise cards, `tight-code` / `small-code`, `footnote` |
| `theme/` | Vendored `slidev-theme-dataminded`, copied from the `containerization_with_docker` course deck |

Restart the dev server after adding a file under `parts/` or editing `style.css`: Slidev
resolves `src:` includes and loads `style.css` at startup only.

## Conventions

Same as the other Data Minded Academy decks:

- Two-tone headings: wrap the accent words in `<span class="dm-accent">...</span>`.
- Content slides use `layout: default` with a `label:` (`5 · Automerge`) that stays constant per section.
- Dividers use `layout: section`. Exercise pointers use `layout: statement` with the `ex-grid`
  cards, naming the exact file in `../session/`.
- No em dashes. Bold marks a single term, not a whole claim.
- Slides render at 980x552. Anything taller silently overflows the PDF: check the export after
  adding a long code block. Use `tight-code` or split the slide.
- Version numbers on the slides (Renovate `44.210.2`, action tags, example update targets) drift
  daily. Re-check them against a fresh dry run before each session.

The theme's component catalogue (`theme-preview.md`) lives in the
`containerization_with_docker` repo; it isn't duplicated here.
