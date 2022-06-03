args <- commandArgs(trailingOnly = TRUE)
## usage:
## system("Rscript ./scripts/mdpt-download-and-make-rds.r 5 sdf 6")
## [1] "5"   "sdf" "6"

## --------------------------------------------------------------------------------
## Load or Install Packages
## --------------------------------------------------------------------------------
for(p in c('yaml'))
    if(!requireNamespace(p, quietly = TRUE))
        install.packages(p, repos = 'http://cloud.r-project.org')

for(p in c('romRDS'))
    if (!requireNamespace(p, quietly = TRUE))
        devtools::install_github(paste0("stasvlasov/", p), upgrade = FALSE)
## -------------------------------------------------------------------------------

## --------------------------------------------------------------------------------
## Deploy
## --------------------------------------------------------------------------------
info <- yaml::read_yaml("info.yml")

options(timeout=600)
## default is only 60 which is not enough for large data
info$metacodes$data_sets |>
    lapply(`[[`, "files") |>
    lapply(\(files) { if(is.list(files)) sapply(files, `[[`, "file") else files}) |>
    unlist() |>
    sapply(romRDS::deploy_file)


## get docs
