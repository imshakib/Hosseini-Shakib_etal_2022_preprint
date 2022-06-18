##==============================================================================
## sobol_functions.R
##
## Original codes by Calvin Whealton, Cornell University
## https://github.com/calvinwhealton/SensitivityAnalysisPlots
## and
## Perry Oddo, Penn State
##
## Modified (condensed - codes are almost entirely unchanged) for brevity by
## Tony Wong (twong@psu.edu). The only code that was changed is the plotting
## routine 'plotRadCon'; Tony added
## (1) inputs for the first-, total- and second-order % values used for legend
## (2) generate labels for first-, total- and second-order in legend
## (3) write legend in black ink instead of gray
## (4) include '%' sign and cut legend labels off at the decimal (whole numbers
##     only)
##
## Tony also modified the 'sig' test for significance to test for confidence
## interval bounds of the same sign (otherwise, 0 is in CI for sensitivity
## index) and greater than 1%.
##
## Some functions were added by Vivek Srikrishnan (vivek@psu.edu),
## such as sobol_func_eval, sobol_func_wrap, and co2_yr. map_range and
## sample_value are based on Tony Wong's workflow.
##=============================================================================

library(parallel)

#####################################################
# (Tony-modified) -- function for testing significance of S1 and ST
# functions assume the confidence are for already defined type I error
stat_sig_s1st <- function(df
                          ,greater = 0.01
                          ,method='sig'
                          ,sigCri = 'either'){
  
  # initializing columns for the statistical significance of indices
  df$s1_sig <- 0
  df$st_sig <- 0
  df$sig <- 0
  
  # testing for statistical significance
  if(method == 'sig'){
    # testing for statistical significance using the confidence intervals
    df$s1_sig[which((s1st$S1) - s1st$S1_conf > 0)] <- 1
    df$st_sig[which((s1st$ST) - s1st$ST_conf > 0)] <- 1
  }
  else if(method == 'gtr'){
    # finding indicies that are greater than the specified values
    df$s1_sig[which((s1st$S1) > greater)] <- 1
    df$st_sig[which((s1st$ST) > greater)] <- 1
  } else if(method == 'con') {
    df$s1_sig[which(s1st$S1_conf_low * s1st$S1_conf_high > 0)] <- 1
    df$st_sig[which(s1st$ST_conf_low * s1st$ST_conf_high > 0)] <- 1
  } else if(method == 'congtr'){
    df$s1_sig[which(s1st$S1_conf_low * s1st$S1_conf_high > 0 &
                      (s1st$S1) > greater)] <- 1
    df$st_sig[which(s1st$ST_conf_low * s1st$ST_conf_high > 0 &
                      (s1st$ST) > greater)] <- 1
  } else {
    print('Not a valid parameter for method')
  }
  
  # determining whether the parameter is significant
  if(sigCri == 'either'){
    for(i in 1:nrow(df)){
      df$sig[i] <- max(df$s1_sig[i],df$st_sig[i])
    }
  }
  else if(sigCri == 'S1'){
    df$sig <- df$s1_sig
  }
  else if(sigCri == 'ST'){
    df$sig <- df$st_sig
  }
  else{
    print('Not a valid parameter for SigCri')
  }
  
  # returned dataframe will have columns for the test of statistical significance
  return(df)
}

#####################################################
# function to test statistical significance of S2 indices
stat_sig_s2 <- function(dfs2
                        ,dfs2Conf_low
                        ,dfs2Conf_high
                        ,method='sig'
                        ,greater = 0.01
                        ){
  
  # initializing matrix to return values
  s2_sig <- matrix(0,nrow(s2),ncol(s2))
  
  # testing for statistical significance
  if(method == 'sig'){
    # testing for statistical significance using the confidence intervals
    s2_sig[which((s2) - s2_conf > 0)] <- 1
  }
  else if(method == 'gtr'){
    # finding indices that are greater than the specified values
    s2_sig[which((dfs2Conf_low) > greater)] <- 1
  }
  else if(method == 'con'){
    s2_sig[which(dfs2Conf_low * dfs2Conf_high > 0)] <- 1
  }
  else if(method == 'congtr'){
    s2_sig[which(dfs2Conf_low * dfs2Conf_high > 0 &
                   (s2) > greater)] <- 1
  }
  else{
    print('Not a valid parameter for method')
  }
  
  # returned data frame will have columns for the test of statistical significance
  return(s2_sig)
}


upper.diag <- function(x){
  m<-(-1+sqrt(1+8*length(x)))/2
  X<-lower.tri(matrix(NA,m,m),diag=TRUE)
  X[X==TRUE]<-x
  X[upper.tri(X, diag = FALSE)] <- NaN
  t(X)
}

