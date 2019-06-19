#' Catchall Functions for All Things 'John Deere'
#'
#' Initially a convenience package to access 'John Deere' 'MowerPlus' databases from
#' 'iOS' backups but perpaps will be something more all-encompassing.
#'
#' Ref:
#'
#' - <https://rud.is/b/2019/06/02/trawling-through-ios-backups-for-treasure-a-k-a-how-to-fish-for-target-files-in-ios-backups-with-r/>
#' - <https://rud.is/b/2019/06/09/wrapping-up-exploration-of-john-deeres-mowerplus-database/>
#'
#'
#' - URL: <https://gitlab.com/hrbrmstr/deere>
#' - BugReports: <https://gitlab.com/hrbrmstr/deere/issues>
#'
#' @md
#' @name deere
#' @keywords internal
#' @author Bob Rudis (bob@@rud.is)
#' @import tibble
#' @importFrom fs dir_info file_copy path_real path_join dir_info dir_exists
#' @importFrom dplyr tbl src_sqlite desc arrange filter mutate select pull
"_PACKAGE"
