#' Convert timestampes from Apple "CoreData" format to something usable
#'
#' @md
#' @param x timestamps in Apple "CoreData" format(dates or times)
#' @param tz passed on to the convertion to a `POSIXct` object. Def: `NULL`.
#' @export
from_coredata_ts <- function(x, tz = NULL) {
  .POSIXct(ifelse(
    test = floor(log10(x)) >= 10, # If you're still using R in 2317 then good on ya and edit this
    yes = as.POSIXct(x/10e8, origin = "2001-01-01"), # nanoseconds coredata
    no = as.POSIXct(x, origin = "2001-01-01") # seconds coredata
  ), tz = tz)
}


os_type <- function() {
  .Platform$OS.type
}

detect_os <- function() {
  ostype <- os_type()
  sysname <- Sys.info()["sysname"]
  if (ostype == "windows") {
    "windows"
  } else if (sysname == "Darwin") {
    "macos"
  } else {
    stop("You will need to manually specify the backup location on this platform.", call.=FALSE)
  }
}
