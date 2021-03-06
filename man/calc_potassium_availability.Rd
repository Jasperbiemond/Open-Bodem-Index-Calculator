% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/potassium.R
\name{calc_potassium_availability}
\alias{calc_potassium_availability}
\title{Calculate the K availability}
\usage{
calc_potassium_availability(A_K_CC, A_K_CEC, A_CEC_CO, A_PH_CC, A_OS_GV,
  A_CLAY_MI, B_LU_BRP, B_BT_AK)
}
\arguments{
\item{A_K_CC}{(numeric) The plant available potassium, extracted with 0.01M CaCl2 (mg / kg),}

\item{A_K_CEC}{(numeric) The occupation of the CEC with potassium (\%)}

\item{A_CEC_CO}{(numeric) The cation exchange capacity of the soil (mmol+ / kg), analysed via Cobalt-hexamine extraction}

\item{A_PH_CC}{(numeric) The acidity of the soil, measured in 0.01M CaCl2 (-)}

\item{A_OS_GV}{(numeric) The organic matter content of the soil (\%)}

\item{A_CLAY_MI}{(numeric) The clay content of the soil (\%)}

\item{B_LU_BRP}{(numeric) The crop code (gewascode) from the BRP}

\item{B_BT_AK}{(character) The type of soil}
}
\description{
This function calculates the K availability of a soil.
}
