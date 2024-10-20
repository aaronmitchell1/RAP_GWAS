#Modified version of miami_plot function from Andrew Elmore's GeneHackman pipeline to make a Miami plot on local machine and save to miami_plot_file.
#Works on GWAS processed using the standardise_gwases pipeline.

range = 500000
library(qqman)

miami_plot <- function(first_gwas, second_gwas, miami_plot_file, title = "Comparing GWASes", chr = NA, bp = NA, range = NA) {
  
  show_specific_region <- !is.na(chr) & !is.na(bp) & !is.na(range)

  #Select the required columns
  manhattan_columns <- c("SNP", "CHR", "BP", "P")
  
  #Ensuring both datasets have the required columns
  first_gwas <- first_gwas[manhattan_columns]
  second_gwas <- second_gwas[manhattan_columns]

  #Remove NAs
  first_gwas <- first_gwas[complete.cases(first_gwas), ]
  second_gwas <- second_gwas[complete.cases(second_gwas), ]

  #Plot dimensions
  png_width <- 1500
  png_height <- 800
  top_ylim <- max(-log10(second_gwas$P))
  x_range <- NULL
  x_lab <- ""

  if (show_specific_region) {
    png_width <- 900
    x_range <- c(bp - floor(range/2), bp + floor(range/2))
    x_lab <- paste("Chromosome", chr)

    #Format datasets for the specified region
    first_gwas <- gwas_region(first_gwas, chr, bp, range)
    second_gwas <- gwas_region(second_gwas, chr, bp, range)
    top_ylim <- max(-log10(second_gwas$P))
  } else {
    #Identify shared chromosomes and subset
    first_chrs <- sort(unique(first_gwas$CHR))
    second_chrs <- sort(unique(second_gwas$CHR))
    shared_chrs <- sort(intersect(first_chrs, second_chrs))
    
    #Correct subset only if different chromosomes covered
    if (!(all(shared_chrs %in% first_chrs) && all(shared_chrs %in% second_chrs))) {
      first_gwas <- subset(first_gwas, CHR %in% shared_chrs)
      second_gwas <- subset(second_gwas, CHR %in% shared_chrs)
    }
  }
  
  message(paste("Number of rows for each GWAS: ", nrow(first_gwas), nrow(second_gwas)))

  #Create Miami plot
  grDevices::png(miami_plot_file, width = png_width, height = png_height)
  graphics::par(mfrow = c(2, 1))
  graphics::par(mar = c(0, 5, 3, 3))

  if (show_specific_region) {
    qqman::manhattan(first_gwas, main = title, xlim = x_range)
  } else {
    qqman::manhattan(first_gwas, main = title)
  }

  graphics::par(mar = c(5, 5, 3, 3))
  if (show_specific_region) {
    qqman::manhattan(second_gwas, ylim = c(top_ylim, 0), xlim = x_range, xlab = x_lab, xaxt = "n")
  } else {
    qqman::manhattan(second_gwas, ylim = c(top_ylim, 0), xlab = x_lab, xaxt = "n")
  }

  grDevices::dev.off()
}

miami_plot(first_gwas, second_GWAS, "miami_plot.png", title = "GWAS Comparison")
