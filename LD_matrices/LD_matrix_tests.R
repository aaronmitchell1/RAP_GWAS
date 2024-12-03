#Based on Chin Yang's code. heplots package didn't work for me, you can use rstatix package for boxm test, psych package for Steiger and a modified function for Jennrich.

library(rstatix)
library(psych)
library(tidyr)

cortest_jennrich <- function(R1, R2, n1 = NULL, n2 = NULL) {
    
    # Check that the input matrices R1 and R2 are in the right format
    p <- dim(R1)[2]  # Number of variables (dimensions)
    if (dim(R1)[1] != p || dim(R2)[1] != p) {
        stop("Both R1 and R2 must be square matrices (n x n).")
    }
    
    # Convert to matrices if they are not already
    if (!is.matrix(R1)) R1 <- as.matrix(R1)
    if (!is.matrix(R2)) R2 <- as.matrix(R2)
    
    # Check that R1 and R2 have the same n
    if (dim(R1)[2] != dim(R2)[2]) {
        stop("Correlation matrices R1 and R2 must have the same dimensions!")
    }
    
    # If sample sizes (n1, n2) are not provided, set them to 1
    if (is.null(n1)) n1 <- 1
    if (is.null(n2)) n2 <- 1
    
    # If the sample sizes are infinite, assume n1 == n2
    if (n1 == Inf || n2 == Inf) {
        n1 <- n2 <- max(n1, n2, na.rm = TRUE)  # Set both sample sizes to the largest value
    }
    
    # Calculate the combined correlation matrix R (using the sample sizes)
    c <- (n1 * n2) / (n1 + n2)
    R <- (n1 * R1 + n2 * R2) / (n1 + n2)
    
    # Calculate the inverse of the combined correlation matrix R
    R.inv <- solve(R)
    
    # Calculate the difference between the correlation matrices
    R.diff <- R1 - R2
    
    # Calculate Z, the standardized difference
    Z <- sqrt(c) * R.inv %*% R.diff
    
    # Calculate S, the auxiliary matrix for Jennrich
    S <- diag(p) + R %*% R.inv
    S.inv <- solve(S)
    
    # Calculate the chi-squared test statistic
    chi2 <- sum(diag(Z %*% t(Z))) / 2 - t(diag(Z)) %*% S.inv %*% diag(Z)
    chi2 <- chi2[1, 1]
    
    # Degrees of freedom for the test
    df <- p * (p - 1) / 2
    
    # Compute the p-value for the chi-squared test
    prob <- pchisq(chi2, df, lower.tail = FALSE)
    
    # Return the test statistic and p-value
    results <- list(chi2 = chi2, prob = prob, df = df)
    return(results)
}

#Steiger
cortest(cases_r2,  controls_r2, n1 = 7698, n2 = 250016)

#Jennrich
cortest_jennrich(R1 = cases_r2, R2 = controls_r2) #TBC... the p-value varies substantially when you specify case and control numbers unlike the other tests

#BoxM
#rstatix requires a different format
df <- cbind(
    ld_matrix_controls$UNPHASED_R2,
    ld_matrix_cases$UNPHASED_R2
)
df <- as.data.frame(df)
colnames(df) <- c("column_1", "column_2")
df_long <- df %>%
    pivot_longer(cols = everything(),       # Reshape all columns
                 names_to = "group",         # New variable for column names
                 values_to = "value")

df_long$group <- as.numeric(gsub("column_", "", df_long$group))

box_m(df_long[, "value"], df_long$group)
