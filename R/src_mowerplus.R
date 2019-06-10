#' Find and sync a copy of the latest MowerPlus database file from an iOS backup
#'
#' @md
#' @note You may need to [setup permissions](https://rud.is/b/2019/06/02/trawling-through-ios-backups-for-treasure-a-k-a-how-to-fish-for-target-files-in-ios-backups-with-r/)
#'       to be able to use this method depending on which macOS version you're on.
#' @param backup_id the giant hex string of a folder name
#' @param data_loc where `mowtrack.sqlite` will be sync'd
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
src_mowerplus <- function(backup_id, data_loc = "~/Data", overwrite = TRUE) {

  # root of mobile backup dir for `backup_id`
  mb <- path.expand(file.path("~/Library/Application Support/MobileSync/Backup", backup_id))
  stopifnot(dir.exists(mb))

  data_loc <- path.expand(data_loc)
  stopifnot(dir.exists(data_loc))

  tf <- tempfile(fileext = ".sqlite")
  on.exit(unlink(tf), add=TRUE)

  # path to the extracted sqlite file
  out_db <- file.path(data_loc, "mowtrack.sqlite")

  file.copy(file.path(mb, "Manifest.db"), tf, overwrite = TRUE)

  manifest_db <- src_sqlite(tf)

  fils <- tbl(manifest_db, "Files")

  filter(fils, relativePath == "Library/Application Support/MowTracking.sqlite") %>%
    pull(fileID) -> mowtrackdb_loc

  file.copy(
    file.path(mb, sprintf("%s/%s", substr(mowtrackdb_loc, 1, 2), mowtrackdb_loc)),
    file.path(data_loc, "mowtrack.sqlite"),
    overwrite = overwrite
  )

  src_sqlite(out_db)

}
