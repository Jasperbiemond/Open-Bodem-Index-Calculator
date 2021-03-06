#' Calculate the availability of the metal Cu
#' 
#' This function calculates the availability of Cu for plant uptake
#' 
#' @param A_CU_CC (numeric) The plant available Cu content, extracted with 0.01M CaCl2 (ug / kg)
#' @param A_CLAY_MI (numeric) The clay content of the soil (\%)
#' @param A_OS_GV (numeric) The organic matter content of the soil (\%)
#' @param A_K_CC (numeric) The plant available potassium, extracted with 0.01M CaCl2 (mg / kg),
#' @param A_MN_CC (numeric) The plant available Mn content, extracted with 0.01M CaCl2 (ug / kg)
#' @param B_LU_BRP (numeric) The crop code (gewascode) from the BRP
#' 
#' @import data.table
#' 
#' @export
calc_copper_availability <- function(A_CU_CC, A_OS_GV, A_MN_CC,A_CLAY_MI,A_K_CC,
                                     B_LU_BRP) {
  
  id = crop_code = crop_n = crop_category = NULL
  
  # Load in the datasets
  crops.obic <- as.data.table(OBIC::crops.obic)
  setkey(crops.obic, crop_code)
  
  # Check input
  arg.length <- max(length(A_CU_CC),length(A_OS_GV), length(A_MN_CC),
                    length(A_CLAY_MI),length(A_K_CC), length(B_LU_BRP))
  checkmate::assert_numeric(A_CU_CC, lower = 0, upper = 500, any.missing = FALSE, len = arg.length)
  checkmate::assert_numeric(A_OS_GV, lower = 0, upper = 100, any.missing = FALSE, len = arg.length)
  checkmate::assert_numeric(A_MN_CC, lower = 0, upper = 250000, any.missing = FALSE, len = arg.length)
  checkmate::assert_numeric(A_CLAY_MI, lower = 0, upper = 100, any.missing = FALSE, len = arg.length)
  checkmate::assert_numeric(A_K_CC, lower = 0, upper = 800, any.missing = FALSE, len = arg.length)
  checkmate::assert_numeric(B_LU_BRP, any.missing = FALSE, min.len = 1, len = arg.length)
  checkmate::assert_subset(B_LU_BRP, choices = unique(crops.obic$crop_code), empty.ok = FALSE)

  # Collect data in a table
  dt <- data.table(
    id = 1:arg.length,
    A_CU_CC = A_CU_CC,
    A_OS_GV = A_OS_GV, 
    A_MN_CC = A_MN_CC,
    A_CLAY_MI = A_CLAY_MI,
    A_K_CC = A_K_CC,
    B_LU_BRP = B_LU_BRP,
    value = NA_real_
  )
  dt <- merge(dt, crops.obic[, list(crop_code, crop_category)], by.x = "B_LU_BRP", by.y = "crop_code")

  # Calculate Cu-availability for maize and arable crops (mail Romkens, 2018)
  dt[crop_category =='akkerbouw', value := 10^(0.948 + 0.188 * log10(A_CU_CC*0.001*0.1))]
  dt[crop_category =='mais', value := 10^(0.948 + 0.188 * log10(A_CU_CC*0.001*0.1))]
  
  # Calculate Cu-availability for nature (not done yet)
  dt[crop_category =='natuur', value := 0]
  
  # Calculate Cu-availability for grassland (following estimated Cu-HNO3, in mg/kg)
  dt[crop_category =='grasland', value := exp(1.85 + 0.1255 * log(A_CU_CC) + 0.01796 * A_OS_GV +
                                          0.0481 * log(A_MN_CC) -0.06222 * A_CLAY_MI + 
                                          0.01372 * A_CLAY_MI * log(A_CU_CC) -0.1479 * log(A_K_CC))]
  
  # Extract relevant variable and return
  setorder(dt, id)
  value <- dt[, value]
  
  return(value)
}

#' Calculate the availability of the metal Zinc
#' 
#' This function calculates the availability of Zn for plant uptake
#' 
#' @param A_ZN_CC The plant available Zn content, extracted with 0.01M CaCl2 (mg / kg)
#' @param B_LU_BRP (numeric) The crop code (gewascode) from the BRP
#' @param B_BT_AK (character) The type of soil
#' @param A_PH_CC (numeric) The acidity of the soil, determined in 0.01M CaCl2 (-)
#' 
#' @import data.table
#' 
#' @export
calc_zinc_availability <- function(A_ZN_CC, B_LU_BRP, B_BT_AK, A_PH_CC) {
  
  id = crop_code = soiltype = soiltype.n = crop_n = crop_category = NULL
  
  # Load in the datasets
  crops.obic <- as.data.table(OBIC::crops.obic)
  setkey(crops.obic, crop_code)
  soils.obic <- as.data.table(OBIC::soils.obic)
  setkey(soils.obic, soiltype)
  
  # Check input
  arg.length <- max(length(A_ZN_CC), length(B_LU_BRP), length(B_BT_AK))
  checkmate::assert_numeric(A_ZN_CC, lower = 0, upper = 10000, any.missing = FALSE, len = arg.length)
  checkmate::assert_numeric(A_PH_CC, lower = 3, upper = 10, any.missing = FALSE, len = arg.length)
  checkmate::assert_numeric(B_LU_BRP, any.missing = FALSE, min.len = 1, len = arg.length)
  checkmate::assert_subset(B_LU_BRP, choices = unique(crops.obic$crop_code), empty.ok = FALSE)
  checkmate::assert_character(B_BT_AK, any.missing = FALSE, min.len = 1, len = arg.length)
  checkmate::assert_subset(B_BT_AK, choices = unique(soils.obic$soiltype), empty.ok = FALSE)
  
  # Collect data in a table
  dt <- data.table(
    id = 1:arg.length,
    A_ZN_CC = A_ZN_CC,
    A_PH_CC = A_PH_CC,
    B_LU_BRP = B_LU_BRP,
    B_BT_AK = B_BT_AK,
    value = NA_real_
  )
  dt <- merge(dt, crops.obic[, list(crop_code, crop_category)], by.x = "B_LU_BRP", by.y = "crop_code")
  dt <- merge(dt, soils.obic[, list(soiltype, soiltype.n)], by.x = "B_BT_AK", by.y = "soiltype")
  
  # Calculate Zn-availability
  dt[crop_category =='akkerbouw', value := 10^(0.88 + 0.56 * log10(A_ZN_CC*0.001) + 0.13 * A_PH_CC)]
  dt[crop_category =='mais', value := 10^(0.88 + 0.56 * log10(A_ZN_CC*0.001) + 0.13 * A_PH_CC)]
  dt[crop_category =='natuur', value := 0]
  dt[crop_category =='grasland', value := 10^(-1.04 + 0.67 * log10(A_ZN_CC*0.001) + 0.5 * A_PH_CC)]

  # Too high values for Zn-availability are prevented
  dt[value > 250, value := 250]
  
  # Extract relevant variable and return
  setorder(dt, id)
  value <- dt[, value]
  
  return(value)
}

#' Calculate the indicator for Cu-availability
#' 
#' This function calculates the indicator for the the Cu availability in soil by using the Cu-index as calculated by \code{\link{calc_copper_availability}}
#' 
#' @param D_CU (numeric) The value of Cu-index  calculated by \code{\link{calc_copper_availability}}
#' @param B_LU_BRP (numeric) The crop code (gewascode) from the BRP
#' 
#' @export
ind_copper <- function(D_CU,B_LU_BRP) {
  
  id = crop_code = crop_n = crop_category = NULL
  
  # Load in the datasets
  crops.obic <- as.data.table(OBIC::crops.obic)
  setkey(crops.obic, crop_code)
  
  # Check inputs
  arg.length <- max(length(D_CU),length(B_LU_BRP))
  checkmate::assert_numeric(D_CU, lower = 0, upper = 50, any.missing = FALSE)
  checkmate::assert_numeric(B_LU_BRP, any.missing = FALSE, min.len = 1, len = arg.length)
  checkmate::assert_subset(B_LU_BRP, choices = unique(crops.obic$crop_code), empty.ok = FALSE)
  
  # Collect data in a table
  dt <- data.table(
    id = 1:arg.length,
    D_CU = D_CU,
    B_LU_BRP = B_LU_BRP,
    value = NA_real_
  )
  
  # merge with crop
  dt <- merge(dt, crops.obic[, list(crop_code, crop_category)], by.x = "B_LU_BRP", by.y = "crop_code")
  
  # Evaluate the copper availability given estimated Cu-content of crop
  dt[, value := evaluate_parabolic(D_CU, x.top = 5)]
  
  # Evaluate the copper availability given fertilizer research (need to be updated)
  dt[crop_category =='grasland', value := evaluate_logistic(D_CU, b = 0.7, x0 = 5.3, v = 1.2)]
  
  # order output and extract index
  setorder(dt, id)
  value <- dt[, value]
  
  # return output
  return(value)
}


#' Calculate the indicator for Zn-availability
#' 
#' This function calculates the indicator for the the Zn availability in soil by using the Zn-index as calculated by \code{\link{calc_zinc_availability}}
#' 
#' @param D_ZN (numeric) The value of Zn-index  calculated by \code{\link{calc_zinc_availability}}
#' 
#' @export
ind_zinc <- function(D_ZN) {
  
  # Check inputs
  checkmate::assert_numeric(D_ZN, lower = 0 , upper = 250, any.missing = FALSE)
  
  # Evaluate the Zn
  value <- OBIC::evaluate_parabolic(D_ZN, x.top = 100)
  
  # return output
  return(value)
}