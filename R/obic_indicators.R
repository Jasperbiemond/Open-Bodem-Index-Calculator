#' Calculate the indicators for the OBI
#' 
#' This wrapper function contains the functions to calculate the indicators of agricultural fields.
#' 
#' @param dt.ppr (data.table) The table containg the data needed for OBI
#' 
#' @import data.table
#' 
#' @export
obic_indicators<- function(dt.ppr) {
  
  # Check inputs
  checkmate::assert_data_table(dt.ppr)
  
  # make local copy
  dt.ppr <- copy(dt.ppr)
  
  # define variables used within the function
  A_OS_GV = NULL
  I_C_N = I_C_P = I_C_K = I_C_MG = I_C_S = I_C_PH = I_C_CEC = I_C_CU = I_C_ZN = I_P_WRI = I_BCS = NULL
  I_P_CR = I_P_SE = I_P_MS = I_P_BC = I_P_DU = I_P_CO = I_B_DI = I_B_SF = I_B_SB = I_M = NULL
  I_P_CEC = NULL
  I_E_NGW = I_E_NSW = NULL
  B_LU_BRP = B_BT_AK = B_OV_WENR = B_LG_CBS = NULL
  D_ZN = D_CU = D_CR = NULL
  D_SE = D_NLV = D_PBI = D_PH_DELTA = D_MAN = D_P_DU = D_SLV = D_MG = D_CEC = D_AS = D_K = NULL
  D_WSI = D_P_WRI = D_PMN = D_BCS = D_NGW = D_NSW = NULL
  leaching_to = NULL
  
  # Evaluate nutrients ------------------------------------------------------
  
  # Nitrogen
  dt.ppr[, I_C_N := ind_nitrogen(D_NLV, B_LU_BRP)]
  
  # Phosphorus
  dt.ppr[, I_C_P := ind_phosphate_availability(D_PBI)]
  
  # Potassium
  dt.ppr[, I_C_K := ind_potassium(D_K,B_LU_BRP,B_BT_AK,A_OS_GV)]
  
  # Magnesium
  dt.ppr[, I_C_MG := ind_magnesium(D_MG, B_LU_BRP, B_BT_AK)]
  
  # Sulphur
  dt.ppr[, I_C_S := ind_sulpher(D_SLV, B_LU_BRP, B_BT_AK, B_LG_CBS)]
  
  # pH
  dt.ppr[, I_C_PH := ind_ph(D_PH_DELTA)]
  
  # CEC
  dt.ppr[, I_C_CEC := ind_cec(D_CEC)]
  
  # Copper
  dt.ppr[, I_C_CU := ind_copper(D_CU,B_LU_BRP)]
  
  # Zinc
  dt.ppr[, I_C_ZN := ind_zinc(D_ZN)]
  

  # Evaluate physical -------------------------------------------------------
  
  # Crumbleability
  dt.ppr[, I_P_CR := ind_crumbleability(D_CR, B_LU_BRP)]
  
  # Sealing
  dt.ppr[, I_P_SE := ind_sealing(D_SE, B_LU_BRP)]
  
  # Moisture supply
  dt.ppr[, I_P_MS := ind_waterstressindex(D_WSI)]
  
  # Bearing capacity
  dt.ppr[, I_P_BC := -999]
  
  # Dustiness
  dt.ppr[, I_P_DU := ind_winderodibility(D_P_DU)]
  
  # Compaction
  dt.ppr[, I_P_CO := ind_compaction(B_OV_WENR)]

  # Water Retention Index 1. Plant available water in topsoil
  dt.ppr[, I_P_WRI := ind_waterretention(D_P_WRI)]
  
  # aggregation stability 
  dt.ppr[, I_P_CEC := ind_aggregatestability(D_AS)]

  # Evaluate biological -----------------------------------------------------
  
  # Disease / pest resistance
  dt.ppr[, I_B_DI := ind_resistance(A_OS_GV)]
  
  # Soil life activity
  dt.ppr[, I_B_SF := ind_pmn(D_PMN)]
  
  # Soil biodiversity
  dt.ppr[, I_B_SB := -999]
  

  # Evaluate managment ------------------------------------------------------
  dt.ppr[, I_M := ind_management(D_MAN, B_LU_BRP, B_BT_AK)]
  
  dt.ppr[, I_BCS := ind_bcs(D_BCS)]
  
  # Evaluate Environmental ------------------------------------------------------
  
  # N retention groundwater
  dt.ppr[, I_E_NGW := ind_nretention(D_NGW, leaching_to = "gw")]
  
  # N retention surfacewater
  dt.ppr[, I_E_NSW := ind_nretention(D_NSW, leaching_to = "ow")]
  
  # return the updated object
  return(dt.ppr)
}
