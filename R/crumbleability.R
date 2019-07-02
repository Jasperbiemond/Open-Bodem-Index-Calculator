#' Calculate the crumbleability
#'
#' This function calculates the crumbleability. This value can be evaluated by \code{\link{eval_crumbleability}}
#' 
#' @param lutum (numeric) The percentage lutum available of the soil
#' @param om (numeric) The organic matter content of soil in percentage
#' @param ph (numeric) The pH of the soil
#' 
#' @import data.table
#' 
#' @importFrom stats approxfun
#'
#' @export
calc_crumbleability <- function(lutum, om, ph) {
  
  # Check input
  checkmate::assert_numeric(lutum, lower = 0, upper = 100, any.missing = FALSE, min.len = 1)
  checkmate::assert_numeric(om, lower = 0, upper = 100, any.missing = FALSE, min.len = 1)
  checkmate::assert_numeric(ph, lower = 0, upper = 14, any.missing = FALSE, min.len = 1)

  # Setup a table with all the information
  dt <- data.table(
    lutum = lutum,
    om = om, 
    ph = ph,
    value.lutum = NA_real_,
    cor.om = NA_real_,
    cor.ph = NA_real_,
    value = NA_real_
  )
  
  # If lutum is outside range give a min/max value
  dt[lutum < 4, value := 10]
  dt[lutum > 40, value := 1]
  
  # Calculate value.lutum
  df.lutum <- data.frame(
    lutum = c(4, 10, 17, 24, 30, 40, 100),
    value.lutum = c(10, 9, 8, 6.5, 5, 3.5, 1)
  )
  fun.lutum <- approxfun(x = df.lutum$lutum, y = df.lutum$value.lutum, rule = 2)
  dt[is.na(value), value.lutum := fun.lutum(lutum)]
    
  # Create organic matter correction function and calculate correction for om
  df.cor.om <- data.frame(
    value.lutum = c(10, 9, 8, 6.5, 5, 3.5, 1),
    cor.om = c(0, 0.06, 0.09, 0.12, 0.25, 0.35, 0.46)
  )
  fun.cor.om <- approxfun(x = df.cor.om$value.lutum, y = df.cor.om$cor.om, rule = 2)
  dt[is.na(value), cor.om := fun.cor.om(value.lutum)]
    
  # Create pH correction function and calculate correction for pH
  df.cor.ph <- data.frame(
    value.lutum = c(10, 9, 8, 6.5, 5, 3.5, 1),
    cor.ph = c(0, 0, 0.15, 0.3, 0.7, 1, 1.5)
  )
  fun.cor.ph <- approxfun(x = df.cor.ph$value.lutum, y = df.cor.ph$cor.ph, rule = 2)
  dt[is.na(value) & ph < 7, cor.ph := fun.cor.ph(value.lutum)]
  dt[is.na(value) & ph >= 7, cor.ph := 0]

  # Calculate the value
  dt[is.na(value), value := value.lutum + cor.om * om - cor.ph]
  value <- dt[, value]
  
  return(value)
}

#' Evaluate the crumbleability
#' 
#' This function evaluates the crumbleability calculated by \code{\link{calc_crumbleability}}
#' 
#' @param value.crumbleability (numeric) The value of crumbleability calculated by \code{\link{calc_crumbleability}}
#' @param crop (numeric) The crop code (gewascode) from the BRP
#' 
#' @export
eval_crumbleability <- function(value.crumbleability, crop) {
  
  # Load in the crops dataset
  
  
  # Check input
  checkmate::assert_numeric(value.crumbleability, lower = 0, upper = 10, any.missing = FALSE, min.len = 1)
  checkmate::assert_numeric(crop, lower = 0, upper = 100, any.missing = FALSE, min.len = 1)
}