
[![Travis-CI Build
Status](https://travis-ci.org/hrbrmstr/deere.svg?branch=master)](https://travis-ci.org/hrbrmstr/deere)
[![Coverage
Status](https://codecov.io/gh/hrbrmstr/deere/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/deere)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/deere)](https://cran.r-project.org/package=deere)

# deere

Catchall Functions for All Things ‘John Deere’

## Description

Initially a convenience package to access ‘John Deere’ ‘MowerPlus’
databases from ‘iOS’ backups but perpaps will be something more
all-encompassing.

Ref:

  - <https://rud.is/b/2019/06/02/trawling-through-ios-backups-for-treasure-a-k-a-how-to-fish-for-target-files-in-ios-backups-with-r/>
  - <https://rud.is/b/2019/06/09/wrapping-up-exploration-of-john-deeres-mowerplus-database/>

## What’s Inside The Tin

The following functions are implemented:

## Installation

``` r
devtools::install_git("https://git.sr.ht/~hrbrmstr/deere.git")
# or
devtools::install_git("https://git.rud.is/hrbrmstr/deere.git")
# or
devtools::install_gitlab("hrbrmstr/deere")
# or
devtools::install_bitbucket("hrbrmstr/deere")
# or
devtools::install_github("hrbrmstr/deere")
```

## Usage

``` r
library(deere)
library(hrbrthemes)
library(tidyverse)

# current version
packageVersion("deere")
## [1] '0.1.0'
```

### Sample from a recent mow

``` r
mow_db <- src_mowerplus("28500cd31b9580aaf5815c695ebd3ea5f7455628")

mow_db
## src:  sqlite 3.22.0 [/Users/hrbrmstr/Data/mowtrack.sqlite]
## tbls: Z_METADATA, Z_MODELCACHE, Z_PRIMARYKEY, ZACTIVITY, ZDEALER, ZMOWALERT, ZMOWER, ZMOWLOCATION, ZSMARTCONNECTOR,
##   ZUSER

glimpse(tbl(mow_db, "ZMOWER"))
## Observations: ??
## Variables: 23
## Database: sqlite 3.22.0 [/Users/hrbrmstr/Data/mowtrack.sqlite]
## $ Z_PK                      <int> 1
## $ Z_ENT                     <int> 7
## $ Z_OPT                     <int> 11
## $ ZDECKSIZEINCHES           <int> 48
## $ ZDISMISSEDFULLSERVICETASK <int> 0
## $ ZDISMISSEDPERIODICTASK    <int> 0
## $ ZSMARTCONNECTOR           <int> NA
## $ ZUSER                     <int> 1
## $ ZBATTERYCHARGE            <dbl> NA
## $ ZENGINEHOURS              <dbl> 3.474705
## $ ZFULLSERVICEPERFORMED     <dbl> NA
## $ ZHMCLASTSEEN              <dbl> NA
## $ ZHMCOFFSET                <dbl> 0
## $ ZPERIODICSERVICEPERFORMED <dbl> NA
## $ ZSCLASTCONNECTED          <dbl> NA
## $ ZGENERICTYPE              <chr> NA
## $ ZHMCIDENTIFIER            <chr> NA
## $ ZMODEL                    <chr> "E140"
## $ ZSCPIN                    <chr> NA
## $ ZSCPERIPHERALID           <chr> NA
## $ ZSERIALNUMBER             <chr> "1GXE140EKKK116940"
## $ ZSERIES                   <chr> "E100"
## $ ZSCDATADICTIONARY         <blob> <NA>

glimpse(tbl(mow_db, "ZACTIVITY"))
## Observations: ??
## Variables: 20
## Database: sqlite 3.22.0 [/Users/hrbrmstr/Data/mowtrack.sqlite]
## $ Z_PK           <int> 1, 2
## $ Z_ENT          <int> 3, 3
## $ Z_OPT          <int> 124, 93
## $ ZMONTH         <int> 6, 6
## $ ZYEAR          <int> 2019, 2019
## $ ZMOWER         <int> 1, 1
## $ ZUSER          <int> 1, 1
## $ ZISCOMPLETE    <int> 1, 1
## $ ZISMISSEDMOW   <int> 0, 0
## $ ZLASTLOCATION  <int> 7016, 12548
## $ ZCREATEDAT     <dbl> 581100260, 581778616
## $ ZENGINEHOURS   <dbl> NA, NA
## $ ZAREACOVERED   <dbl> 3.761875, 2.286811
## $ ZAVERAGESPEED  <dbl> 3.727754, 2.894269
## $ ZDISTANCEMOWED <dbl> 7.758894, 4.716564
## $ ZMOWINGTIME    <dbl> 6960.000, 5548.939
## $ ZNOTES         <chr> "First mow!", NA
## $ ZINTERVALNAME  <chr> NA, NA
## $ ZTYPE          <chr> NA, NA
## $ ZUUID          <blob> blob[238 B], blob[238 B]

tbl(mow_db, "ZACTIVITY")%>%
  collect() -> activity

activity %>% 
  select(
    mow_date = ZCREATEDAT, 
    area_covered = ZAREACOVERED, 
    avg_speed = ZAVERAGESPEED, 
    distance = ZDISTANCEMOWED, 
    duration = ZMOWINGTIME
  ) %>% 
  arrange(mow_date) %>% 
  mutate(
    duration = duration / 60 / 60, # hours
    mow_date = format(from_coredata_ts(mow_date), "%b %d"), # factors make better bars
    mow_date = factor(mow_date, levels = unique(mow_date)) # when there are just 2-of-em
  ) %>% 
  gather(measure, value, -mow_date) %>% 
  ggplot(aes(mow_date, value)) +
  geom_col(aes(fill = measure), width = 0.5, show.legend = FALSE) +
  scale_y_comma() +
  scale_fill_ipsum() +
  facet_wrap(~measure, scales = "free") +
  theme_ipsum_rc(grid="Y")
```

<img src="README_files/figure-gfm/mow-1.png" width="672" />

``` r

zloc <- tbl(mow_db, "ZMOWLOCATION")


zloc %>% 
  select(
    id = ZSESSION,
    zorder = ZORDER,
    lat = ZLATITUDE,
    lng = ZLONGITUDE,
    speed = ZSPEED,
    ts = ZTIMESTAMP
  ) %>% 
  collect() %>% 
  mutate(
    id = factor(id),
    ts = from_coredata_ts(ts)
  ) -> sessions

ggplot(sessions, aes(id, speed)) +
  ggbeeswarm::geom_quasirandom(
    aes(fill = id), show.legend = FALSE,
    shape = 21, size = 2, color = "white", stroke = 0.75
  ) +
  scale_fill_ipsum() +
  labs(x = "Mowing Session", y = "MPH", title = "Mowing Speed Comparison (mph)") +
  theme_ipsum_rc(grid="Y")
```

<img src="README_files/figure-gfm/mow-2.png" width="672" />

``` r

arrange(sessions, ts) %>% 
  ggplot(aes(lng, lat)) +
  geom_path(
    aes(color = id, group = id), show.legend = FALSE,
    size = 1, alpha = 1/2
  ) +
  scale_color_ipsum() +
  coord_quickmap() +
  facet_wrap(~id) +
  labs(title = "Mowing Path Comparison") +
  theme_ipsum_rc(grid="Y") +
  ggthemes::theme_map()
```

<img src="README_files/figure-gfm/mow-3.png" width="672" />

## deere Metrics

| Lang | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
| :--- | -------: | ---: | --: | ---: | ----------: | ---: | -------: | ---: |
| Rmd  |        1 | 0.17 |  74 | 0.69 |          31 | 0.69 |       39 | 0.45 |
| R    |        5 | 0.83 |  33 | 0.31 |          14 | 0.31 |       48 | 0.55 |

## Code of Conduct

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
