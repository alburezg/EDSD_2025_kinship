# Changelog for EDSD Kinship 2026 Refresh

Date: 2026-02-27

## Scope

- Refresh course materials from prior year to 2026 delivery.
- Update course-facing dates/schedule/instructor information.
- Keep citation years/keys and WPP2024 data references unchanged.

## T0 Baseline

- Created and pushed baseline snapshot commit before refresh work:
  - `chore: baseline snapshot before 2026 refresh`

## T1 Renames (25-26 scheme)

- Renamed directories:
  - `slides/EDSD24-25_1_intro` -> `slides/EDSD25-26_1_intro`
  - `slides/EDSD24-25_2_formal_models` -> `slides/EDSD25-26_2_formal_models`
  - `slides/EDSD24-25_3_formal_models2` -> `slides/EDSD25-26_3_formal_models2`
  - `slides/EDSD_2024-25_kinship` -> `slides/EDSD_2025-26_kinship`
- Renamed syllabus source:
  - `syllabus/EDSD_2024-25_kinship.tex` -> `syllabus/EDSD_2025-26_kinship.tex`

## T2 Content Updates

- Updated course-facing dates to 2026 schedule:
  - Session days: Monday-Thursday, March 2-5, 2026.
  - Monday start at 09:30.
  - In-person session window: 09:00-12:30.
- Updated slide deck date stamps:
  - Intro: `2 Mar 2026`
  - Formal models: `3 Mar 2026`
  - Extensions: `4 Mar 2026`
- Removed Amanda from course-facing instructor/contact text.
- Updated course links:
  - GitHub org/repo links to `alburezg/EDSD_2025_kinship`
  - Website links to `https://alburezg.github.io/EDSD_2025_kinship/`
- Updated assignment submission contact/date in syllabus/docs:
  - `alburezgutierrez@demogr.mpg.de`
  - Deadline text: Friday, March 6.

## T3 Builds

- Built syllabus PDF from `syllabus/EDSD_2025-26_kinship.tex`.
- Built slide PDFs from:
  - `slides/EDSD25-26_1_intro/main.tex`
  - `slides/EDSD25-26_2_formal_models/main.tex`
  - `slides/EDSD25-26_3_formal_models2/main.tex`
  - `slides/EDSD_2025-26_kinship/main.tex`
- Copied deliverables to:
  - `EDSD_2025_26_kinship_syllabus.pdf`
  - `slides/EDSD25_26_1_intro.pdf`
  - `slides/EDSD25_26_2_formal_models.pdf`
  - `slides/EDSD25_26_3_formal_models2.pdf`
  - `slides/EDSD_2025-26_kinship__main.pdf`

## T4 Cleanup

- Removed tracked LaTeX intermediate files from `slides/` and `syllabus/`.
- Added LaTeX intermediate patterns to `.gitignore`.

## Build Note (Docs)

- `docs/index.Rmd` was updated, but local re-render is blocked because `pandoc` is not installed in this environment.
- Existing `docs/index.html` remains in repo.

## T8 GitHub Pages Note

- Repository is set to publish from `master` + `/docs` (manual GitHub settings step if not already enabled in repo settings).

