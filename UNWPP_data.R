library(readr)
library(dplyr)

# In-session cache: avoids re-reading multi-GB CSVs on every function call.
.wpp_cache <- new.env(parent = emptyenv())

.find_wpp_data_dir <- function() {
  # Prefer docs/data when called from repo root, and data when called from docs.
  candidates <- c("data", "docs/data")
  required <- "WPP2024_Fertility_by_Age1.csv"

  for (dir in candidates) {
    if (file.exists(file.path(dir, required))) {
      return(normalizePath(dir, winslash = "/", mustWork = TRUE))
    }
  }

  stop(
    "Could not find WPP CSVs. Expected ", required,
    " under either 'data/' or 'docs/data/' relative to working directory: ",
    getwd()
  )
}

.load_wpp_tables <- function() {
  data_dir <- .find_wpp_data_dir()

  # Rebuild cache only if first use or data directory changed.
  if (!exists("data_dir", envir = .wpp_cache, inherits = FALSE) ||
      !identical(.wpp_cache$data_dir, data_dir)) {
    fertility_file <- file.path(data_dir, "WPP2024_Fertility_by_Age1.csv")
    male_file <- file.path(data_dir, "WPP2024_Life_Table_Complete_Medium_Male_1950-2023.csv")
    female_file <- file.path(data_dir, "WPP2024_Life_Table_Complete_Medium_Female_1950-2023.csv")
    pop_file <- file.path(data_dir, "WPP2024_Population1JanuaryBySingleAgeSex_Medium_1950-2023.csv")

    .wpp_cache$fertility <- read_csv(
      fertility_file,
      show_col_types = FALSE,
      col_select = c(Location, Time, AgeGrpStart, ASFR)
    )
    male <- read_csv(
      male_file,
      show_col_types = FALSE,
      col_select = c(Location, Sex, Time, AgeGrpStart, px)
    )
    female <- read_csv(
      female_file,
      show_col_types = FALSE,
      col_select = c(Location, Sex, Time, AgeGrpStart, px)
    )
    .wpp_cache$lifetable <- bind_rows(female, male)
    .wpp_cache$pop <- read_csv(
      pop_file,
      show_col_types = FALSE,
      col_select = c(AgeGrpStart, Location, Time, PopFemale, PopMale)
    )
    .wpp_cache$data_dir <- data_dir
  }
}

.drop_readr_attrs <- function(x) {
  attr(x, "spec") <- NULL
  attr(x, "problems") <- NULL
  x
}

# Function to load and filter UN World Population Prospects data for mortality (px) and fertility (fx)
UNWPP_data <- function(country, start_year, end_year, sex) {
  .load_wpp_tables()

  px <- .wpp_cache$lifetable %>%
    filter(
      Location == country,
      Time >= start_year,
      Time <= end_year,
      Sex == sex
    ) %>%
    rename(year = Time, age = AgeGrpStart)

  if (sex == "Male") {
    return(.drop_readr_attrs(px))
  }

  if (sex == "Female") {
    asfr <- .wpp_cache$fertility %>%
      mutate(ASFR = ASFR / 1000) %>%
      filter(Location == country, Time >= start_year, Time <= end_year) %>%
      rename(year = Time, age = AgeGrpStart, fx = ASFR)

    data <- left_join(px, asfr, by = c("Location", "year", "age")) %>%
      mutate(fx = dplyr::coalesce(fx, 0))
    return(.drop_readr_attrs(data))
  }

  stop("Invalid sex. Please specify 'Male' or 'Female'.")
}

# Function to load and filter UN World Population Prospects data for population (N)
UNWPP_pop <- function(country_name, start_year, end_year, sex) {
  .load_wpp_tables()

  if (sex == "Female") {
    wpp <- .wpp_cache$pop %>%
      select(age = AgeGrpStart, country = Location, year = Time, pop = PopFemale)
  } else if (sex == "Male") {
    wpp <- .wpp_cache$pop %>%
      select(age = AgeGrpStart, country = Location, year = Time, pop = PopMale)
  } else {
    stop("Invalid sex. Please specify 'Male' or 'Female'.")
  }

  wpp <- wpp %>%
    filter(country == country_name, year >= start_year, year <= end_year) %>%
    tidyr::pivot_wider(names_from = year, values_from = pop) %>%
    select(-age, -country) %>%
    as.matrix()

  row.names(wpp) <- 0:(nrow(wpp) - 1)
  wpp
}
