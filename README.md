# TidyTuesday

Weekly TidyTuesday analysis projects — a community data visualization and analysis challenge.

## Structure

```
TidyTuesday/
├── 2026/          — Current year
│   ├── W30/       — Week 30 (July 2026)
│   └── ...
```

## Year Structure

Each year folder contains week subfolders:

```
2026/
├── README.md              — Year overview with week list
├── W30/                   — Week 30
│   ├── analysis.qmd       — Quarto analysis document
│   └── data/              — Downloaded data files (not tracked in git)
├── W31/
└── ...
```

## Workflow

1. Find the week's dataset on [TidyTuesday](https://github.com/rfordatascience/tidytuesday)
2. Create a new week folder with the analysis `.qmd`
3. Download data to the `data/` subfolder (excluded from git)
4. Write your analysis and visualizations
5. Commit the `.qmd` file

## Notes

- `data/` folders are excluded from git tracking (large, re-downloadable)
- `*.html` output files are excluded from git tracking
- Use `readr::read_csv()` or `readr::read_tsv()` with paths relative to the `.qmd` file
