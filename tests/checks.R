source("R/analysis.R")

out <- tempfile()

dir.create(out)

r <- run_analysis(normalizePath("."), out)

stopifnot(r$rows > 200, r$numeric_features == 21, r$masked_values > 0)

z <- read.csv(file.path(out, "outlier-treatment.csv"))

stopifnot(all(z$newly_masked >= 0), all(is.finite(z$imputed_sd)))

cat("Validation passed\n")

