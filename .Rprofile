# Ensure rmarkdown can find pandoc when running from terminal sessions.
if (!nzchar(Sys.getenv("RSTUDIO_PANDOC"))) {
  pandoc_dirs <- c(
    "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools",
    "C:/Program Files/Pandoc",
    file.path(Sys.getenv("LOCALAPPDATA"), "Pandoc")
  )
  for (d in pandoc_dirs) {
    if (file.exists(file.path(d, "pandoc.exe"))) {
      Sys.setenv(RSTUDIO_PANDOC = d)
      break
    }
  }
}
