#' Find and sync a copy of the latest MowerPlus database file from an iOS backup
#'
#' @md
#' @note You may need to [setup permissions](https://rud.is/b/2019/06/02/trawling-through-ios-backups-for-treasure-a-k-a-how-to-fish-for-target-files-in-ios-backups-with-r/)
#'       to be able to use this method depending on which macOS version you're on.
#' @param backup_id the giant hex string of a folder name; if unspecified will use the most
#'        recent backup (if found).
#' @param data_loc where `mowtrack.sqlite` will be sync'd
#' @param ios_backup_dir where to look for iOS backups (tries to auto-derive the value)
#' @param overwrite nuke ^^ if present (def: `TRUE`)
#' @export
#' @examples \dontrun{
#' mow_db <- src_mowerplus("28500cd31b9580aaf5815c695ebd3ea5f7455628")
#'
#' mow_db
#'
#' glimpse(tbl(mow_db, "ZMOWER"))
#'
#' glimpse(tbl(mow_db, "ZACTIVITY"))
#'
#' }
src_mowerplus <- function(backup_id, data_loc = "~/Data",
                          ios_backup_dir = platform_ios_backup_dir(),
                          overwrite = TRUE) {

  if (missing(backup_id)) {
    backup_id <- list_ios_backups(dir = ios_backup_dir)[["path"]][[1]]
  }

  # root of mobile backup dir for `backup_id`
  mb <- fs::path_real(fs::path_join(c(ios_backup_dir, backup_id)))
  stopifnot(fs::dir_exists(mb))

  data_loc <- fs::path_real(data_loc)
  stopifnot(fs::dir_exists(data_loc))

  tf <- tempfile(fileext = ".sqlite")
  on.exit(unlink(tf), add=TRUE)

  # path to the extracted sqlite file
  out_db <- fs::path_join(c(data_loc, "mowtrack.sqlite"))

  fs::file_copy(fs::path_join(c(mb, "Manifest.db")), tf, overwrite = TRUE)

  manifest_db <- src_sqlite(tf)

  fils <- tbl(manifest_db, "Files")

  filter(fils, relativePath == "Library/Application Support/MowTracking.sqlite") %>%
    pull(fileID) -> mowtrackdb_loc

  fs::file_copy(
    fs::path_join(c(mb, sprintf("%s/%s", substr(mowtrackdb_loc, 1, 2), mowtrackdb_loc))),
    fs::path_join(c(data_loc, "mowtrack.sqlite")),
    overwrite = overwrite
  )

  src_sqlite(out_db)

}
