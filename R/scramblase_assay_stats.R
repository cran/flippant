#' @rdname scramblase_assay_plot
#' @export
scramblase_assay_stats <- function(
  x,
  scale_to = c("model","data"),
  ppr_scale_factor = 0.65,
  force_through_origin = TRUE,
  generation_of_algorithm = c(2, 1),
  split_by_experiment = TRUE,
  r_bar = 88,
  sigma_r_bar = 28){
  UseMethod("scramblase_assay_stats",x)
}
#' @export
scramblase_assay_stats.data.frame <- function(x, ...){
  base_function_scramblase_assay_stats(x, ...)
}
#' @export
scramblase_assay_stats.character <- function(x, ...){
  parsedInputFile <- read_scramblase_input_file(x)
  withr::with_dir(
    dirname(x),
    base_function_scramblase_assay_stats(x = parsedInputFile, ...)
  )
}
base_function_scramblase_assay_stats <- function(
  x,
  scale_to = c("model","data"),
  ppr_scale_factor = 0.65,
  force_through_origin = TRUE,
  generation_of_algorithm = c(2, 1),
  split_by_experiment = TRUE,
  r_bar = 88,
  sigma_r_bar = 28){
# Check Prerequisites -----------------------------------------------------
  validatedParams <- scramblase_assay_input_validation(
    x = x,
    scale_to = scale_to,
    ppr_scale_factor = ppr_scale_factor,
    force_through_origin = force_through_origin,
    generation_of_algorithm = generation_of_algorithm,
    split_by_experiment = split_by_experiment,
    r_bar = r_bar,
    sigma_r_bar = sigma_r_bar)
  x <- validatedParams[["x"]]
  scale_to <- validatedParams[["scale_to"]]
  ppr_scale_factor <- validatedParams[["ppr_scale_factor"]]
  force_through_origin <- validatedParams[["force_through_origin"]]
  generation_of_algorithm <- validatedParams[["generation_of_algorithm"]]
  split_by_experiment <- validatedParams[["split_by_experiment"]]
  r_bar <- validatedParams[["r_bar"]]
  sigma_r_bar <- validatedParams[["sigma_r_bar"]]

# Processing --------------------------------------------------------------
  processedListFromX <- scramblase_assay_calculations(
    x = x,
    scale_to = scale_to,
    ppr_scale_factor = ppr_scale_factor,
    force_through_origin = force_through_origin,
    generation_of_algorithm = generation_of_algorithm,
    split_by_experiment = split_by_experiment,
    r_bar = r_bar,
    sigma_r_bar = sigma_r_bar)
  processedListFromX <- lapply(processedListFromX,function(y){y[["Raw"]]})

# Assemble the output -----------------------------------------
  output <- plyr::rbind.fill(processedListFromX)
  if (split_by_experiment) {
   output <- output[!duplicated(output$CombinedId),]
  } else {
    output <- output[!duplicated(output$`Experimental Series`),]
  }
  if (split_by_experiment) {
    columns <- c("Fit Constant (a)","Experimental Series","Experiment")
  } else {
    columns <- c("Fit Constant (a)","Experimental Series")
  }
  output <- output[which(names(output) %in% columns)]
  output["Fit Constant (a)"] <- signif(output["Fit Constant (a)"], digits = generation_of_algorithm * 2)
  names(output)[which(names(output) == "Fit Constant (a)")] <- "Fit Constant"
# Return ------------------------------------------------------------------
  return(output)
}