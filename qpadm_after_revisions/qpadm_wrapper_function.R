automate_x_way_qpadm_semi_rotation <- function(
 all_left_pops,       # Populations that are only going to be sources.
 right_and_left_pops, # Populations that are going to be right when not in sources.
 outgroup,            # Populations that are only right. The 1st one is going to be the "1st right" population for qpadm.
 target,              # Target of qpAdm. Needs to be ONLY one.
 x_way,               # Number of sources for qpAdm.
 output_dir,          # Directory where output statistics will be put. It will be created if it doesn't exist.
 run_name,            # Name prefix of the output statistics.
 data_prefix          # Full path that leads to the prefix of EIGENSTRAT.
 ){
  if( length(target) > 1 ){
    stop( "More than one target specified" )
  }
  x_way_left <- as.list(as.data.frame(combn(
    unique(c(all_left_pops, right_and_left_pops)), x_way
  ))) # Get all unique combinations of potetnial sources.
  x_way_right <- lapply(
    x_way_left, function(x){
      c(outgroup, setdiff(right_and_left_pops, x))
    }) # Filter source populations out of "right" for each model.
  list_of_all_models <- list(
    left = x_way_left,
    right = x_way_right,
    target = as.list(rep(target, length(x_way_left)))
    ) # Each "row" of this list is a model.
  results_of_qpadm <- qpadm_multi(
    data_prefix,
    list_of_all_models,
    allsnps = T,
    full_results = T
  )
  ## Extract [target, left1...x, weights1...x, pvalue, feasible]
  relevant_summary_of_qpadm <- type.convert(as.data.frame(
    do.call(
      "rbind", lapply( results_of_qpadm, function(x){
        c(x$weights$target[1],
          x$weights$left,
          x$weights$weight,
          x$popdrop$p[1],
          x$popdrop$p_nested[1],
          x$popdrop$feasible[1])
      }))
  ), as.is = TRUE)
  colnames(relevant_summary_of_qpadm) <- c(
    "target",
    paste("left", 1:x_way, sep = "_"),
    paste("weight", 1:x_way, sep = "_"),
    "p_value", "p_nested", "feasible"
  )
  ## Filter acceptable
  good_and_feasible_models <- relevant_summary_of_qpadm %>%
    filter( p_value > 0.05, feasible == TRUE )
  ## Create names for the output
  dir.create(output_dir, recursive = TRUE)
  name_of_full_stats <- file.path(
    output_dir,
    paste0(c(run_name,target,"full_results.tsv"), collapse='_')
  )
  name_of_good_stats <- file.path(
    output_dir,
    paste0(c(run_name,target,"accepted_and_feasible.tsv"), collapse='_')
  )
  ## Write the tables
  write.table(
    relevant_summary_of_qpadm, name_of_full_stats,
    quote = F, sep = '\t', row.names = F
  )
  write.table(
    good_and_feasible_models, name_of_good_stats,
    quote = F, sep = '\t', row.names = F
  )
}
