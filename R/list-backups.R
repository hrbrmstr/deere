#' List iOS backups available on this system
#'
#' @param dir backup dir (will attempt to be auto-derived)
#' @export
#' @examples
#' list_ios_backups()
list_ios_backups <- function(dir = platform_ios_backup_dir()) {

  fs::dir_info(platform_ios_backup_dir(), type = "directory") %>%
    mutate(path = basename(path)) %>%
    arrange(desc(modification_time)) %>%
    select(path, modification_time, size)

}

#' @rdname list_ios_backups
#' @export
platform_ios_backup_dir <- function() {

  os <- detect_os()

  switch(
    os,
    windows = "~/AppData/Roaming/Apple Computer/MobileSync/Backup",
    macos = "~/Library/Application Support/MobileSync/Backup"
  )

}



