script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])

root <- normalizePath(file.path(dirname(script), ".."))

source(file.path(root, "R/analysis.R"))

out <- file.path(root, "results")

dir.create(out, showWarnings = FALSE)

r <- run_analysis(root, out)

jsonlite::write_json(r, file.path(out, "metrics.json"), pretty = TRUE, auto_unbox = TRUE, 
    digits = 12, na = "null")

print(r)

