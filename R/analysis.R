run_analysis <- function(root, out) {
    d <- read.csv(file.path(root, "data/input.csv"), check.names = FALSE)
    num <- d[, vapply(d, is.numeric, logical(1)), drop = FALSE]
    C <- cor(num, use = "pairwise.complete.obs")
    write.csv(C, file.path(out, "correlations.csv"))
    rank <- data.frame(feature = names(num), correlation = C[, "Calories"])
    rank <- rank[rank$feature != "Calories" & is.finite(rank$correlation), ]
    rank$base <- gsub(" \\(% Daily Value\\)", "", rank$feature)
    rank <- rank[order(-rank$correlation), ]
    rank <- rank[!duplicated(rank$base), ]
    write.csv(rank, file.path(out, "calorie-correlations.csv"), row.names = FALSE)
    masked <- num
    counts <- integer(ncol(num))
    names(counts) <- names(num)
    for (k in names(num)) {
        q <- quantile(num[[k]], c(0.25, 0.75), na.rm = TRUE)
        bad <- !is.na(num[[k]]) & (num[[k]] < q[1] - 1.5 * diff(q) | num[[k]] > q[2] + 1.5 * 
            diff(q))
        masked[[k]][bad] <- NA
        counts[k] <- sum(bad)
    }
    imputed <- masked
    for (k in names(num)) {
        value <- mean(masked[[k]], na.rm = TRUE)
        if (!is.finite(value)) 
            stop("No values remain for imputation")
        imputed[[k]][is.na(imputed[[k]])] <- value
    }
    summaries <- data.frame(feature = names(num), original_median = vapply(num, median, numeric(1), 
        na.rm = TRUE), original_sd = vapply(num, sd, numeric(1), na.rm = TRUE), newly_masked = counts, 
        imputed_median = vapply(imputed, median, numeric(1)), imputed_sd = vapply(imputed, 
            sd, numeric(1)))
    write.csv(summaries, file.path(out, "outlier-treatment.csv"), row.names = FALSE)
    png(file.path(out, "nutrition.png"), 1200, 700)
    par(mfrow = c(1, 2), mar = c(5, 5, 4, 2))
    hist(num$Calories, col = "#438393", border = "white", main = "Supplied menu: original calories", 
        xlab = "Calories")
    plot(num$Calories, imputed$Calories, pch = 19, col = adjustcolor("#438393", 0.5), xlab = "Original calories", 
        ylab = "After IQR masking / mean imputation")
    abline(0, 1, col = 2)
    dev.off()
    list(rows = nrow(d), numeric_features = ncol(num), second_third_positive = rank$feature[which(rank$correlation > 
        0)[2:3]], negative_correlations = rank$feature[rank$correlation < 0], masked_values = sum(counts), 
        scope = "descriptive sensitivity analysis; high nutrient values can be valid and are not asserted to be errors")
}

