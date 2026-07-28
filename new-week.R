#' Create a new TidyTuesday week folder from template
#'
#' Usage:
#'   source("new-week.R")
#'   new_week(year = 2026, week = 31)
#'
#'   # Or create next week from today's date:
#'   source("new-week.R")
#'   new_week()

new_week <- function(
  year = format(Sys.Date(), "%Y"),
  week = as.integer(format(Sys.Date(), "%U")) + 1L,
  output_dir = NULL
) {
  # Resolve output directory
  if (is.null(output_dir)) {
    output_dir <- file.path(getwd(), year)
  }

  # Validate year folder exists
  if (!dir.exists(output_dir)) {
    stop(sprintf(
      "Year folder '%s' does not exist. Create it first.",
      output_dir
    ))
  }

  # Compute the Monday of the target week (ISO week starts Monday)
  jan1 <- as.Date(sprintf("%s-01-01", year))
  jan1_weekday <- as.integer(format(jan1, "%u"))
  iso_week1_monday <- jan1 - (jan1_weekday - 1L)
  week_monday <- iso_week1_monday + (week - 1L) * 7L
  week_sunday <- week_monday + 6L

  # Tuesday is the release date on GitHub
  week_tuesday <- week_monday + 1L

  week_str <- sprintf("%02d", week)
  week_folder <- file.path(output_dir, sprintf("W%s", week_str))

  # Check if week already exists
  if (dir.exists(week_folder)) {
    stop(sprintf("Week folder '%s' already exists.", week_folder))
  }

  # Create the week folder and data subfolder
  dir.create(week_folder, recursive = TRUE)
  dir.create(file.path(week_folder, "data"), recursive = TRUE)

  # Compute the GitHub release path (YYYY-MM-DD format)
  release_date <- format(week_tuesday, "%Y-%m-%d")

  # Query GitHub API to find the CSV filename
  api_url <- paste0(
    "https://api.github.com/repos/rfordatascience/tidytuesday/contents/data/",
    year,
    "/",
    release_date
  )
  cat("Querying GitHub API for CSV filename ... ")
  files <- tryCatch(
    jsonlite::fromJSON(api_url)$name,
    error = function(e) NULL
  )
  if (is.null(files)) {
    stop(
      "Could not query GitHub API for week data. Is this week published yet?"
    )
  }
  csv_files <- files[grepl("\\.csv$", files)]
  if (length(csv_files) == 0) {
    stop("No CSV file found for this week's data on GitHub.")
  }
  if (length(csv_files) > 1) {
    cat(
      "Warning: multiple CSVs found:",
      paste(csv_files, collapse = ", "),
      "\n"
    )
  }
  csv_filename <- csv_files[1]
  cat(paste(csv_files, collapse = ", "), "\n")

  # Generate load-data lines dynamically for all CSV files
  data_load_lines <- unlist(lapply(csv_files, function(f) {
    var_name <- gsub("\\.csv$", "", f)
    var_name <- gsub("-", "_", var_name)
    c(
      sprintf('%s <- read_csv("data/%s")', var_name, f),
      sprintf('glimpse(%s)', var_name)
    )
  }))

  # Write the QMD file
  qmd_path <- file.path(week_folder, "analysis.qmd")

  lines <- c(
    '---',
    sprintf('title: "TidyTuesday — Week %s"', week_str),
    sprintf('subtitle: "%s"', format(week_sunday, "%Y-%m-%d")),
    'author:',
    '  - name: Thomas Reinke',
    '    affiliation:',
    '      - name: Baylor University',
    '        department: Statistics Department',
    '        city: Waco',
    '        state: TX',
    '        country: US',
    '        url: https://www.baylor.edu',
    '    email: thomas_reinke1@baylor.edu',
    'date-format: "MMMM d, yyyy"',
    'format:',
    '  html:',
    '    code-tools:',
    '      source: false',
    '    page-layout: full',
    '    toc-expand: 2',
    '    anchor-sections: false',
    '    citations-hover: true',
    '    footnotes-hover: true',
    '    crossrefs-hover: true',
    '    toc-location: right',
    '    other-links:',
    '      - text: GitHub',
    '        href: https://github.com/thomasqmd',
    '        icon: github',
    '      - text: Website',
    '        href: https://thomasqmd-website.share.connect.posit.cloud/',
    '        icon: globe',
    '      - text: LinkedIn',
    '        href: https://www.linkedin.com/in/thomas-reinke1',
    '        icon: linkedin',
    'theme: [materia, ../../quarto-assets/baylor-html-theme.scss]',
    'code-fold: true',
    'code-overflow: wrap',
    'highlight-style: a11y',
    'toc: true',
    'toc-depth: 5',
    'number-sections: false',
    'number-depth: 1',
    'callout-appearance: minimal',
    'lightbox:',
    '  loop: true',
    'embed-resources: true',
    'editor:',
    '  markdown:',
    '    wrap: 72',
    '---',
    '',
    '```{r, setup}',
    '#| include: false',
    '#| message: false',
    '#| eval: true',
    'library(knitr)',
    'library(tidyverse)',
    'library(conflicted)',
    'library(janitor)',
    'library(kableExtra)',
    'library(plotly)',
    'library(patchwork)',
    'conflicted::conflict_prefer("filter", "dplyr")',
    'conflicted::conflict_prefer("select", "dplyr")',
    'conflicted::conflicts_prefer(plotly::layout)',
    'knitr::opts_chunk$set(',
    '  comment = "#>",',
    '  message = FALSE,',
    '  warning = FALSE,',
    '  cache = FALSE,',
    '  echo = TRUE,',
    '  eval = TRUE,',
    '  tidy.opts = list(width.cutoff = 100),',
    '  tidy = FALSE,',
    '  fig.align = "center"',
    ')',
    'ggplot2::theme_set(ggplot2::theme_minimal())',
    'ggplot2::theme_update(panel.grid.minor = ggplot2::element_blank())',
    '```',
    '',
    '# Week Name',
    '',
    '## Data',
    '',
    'Load the week\'s data from the `data/` folder:',
    '',
    '```{r load-data}',
    data_load_lines,
    '```',
    '',
    '## Analysis',
    '',
    'Start your analysis here.',
    ''
  )

  writeLines(lines, qmd_path)

  # Create .gitkeep in data folder
  file.create(file.path(week_folder, "data", ".gitkeep"))

  # Download all dataset CSVs from GitHub
  csv_paths <- character(length(csv_files))
  for (i in seq_along(csv_files)) {
    f <- csv_files[i]
    c_url <- paste0(
      "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/",
      year,
      "/",
      release_date,
      "/",
      f
    )
    c_path <- file.path(week_folder, "data", f)
    cat(sprintf("Downloading %s ... ", c_url))
    download.file(c_url, c_path, mode = "wb")
    cat("done\n")
    csv_paths[i] <- c_path
  }

  cat(sprintf("Created %s\n", week_folder))
  cat(sprintf("  Monday: %s\n", format(week_monday, "%Y-%m-%d")))
  cat(sprintf("  Sunday: %s\n", format(week_sunday, "%Y-%m-%d")))
  cat(sprintf("  QMD:    %s\n", qmd_path))
  cat(sprintf("  Data:   %s\n", paste(csv_paths, collapse = ", ")))

  invisible(list(
    path = week_folder,
    qmd = qmd_path,
    csv = csv_paths,
    monday = week_monday,
    sunday = week_sunday
  ))
}

cat("Loaded new_week() function. Run `new_week()` in R to create the week folder.\n")

