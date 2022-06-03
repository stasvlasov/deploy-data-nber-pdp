## assume that we start in /scripts
setwd("..")

## --------------------------------------------------------------------------------
## Load or Install Packages
## --------------------------------------------------------------------------------
## from CRAN
for(p in c('yaml'
         , 'pbapply'))
    if(!requireNamespace(p, quietly = TRUE))
        install.packages(p, repos = 'http://cloud.r-project.org')
## from GitHub
for(p in c('romRDS'))
    if (!requireNamespace(p, quietly = TRUE))
        devtools::install_github(paste0("stasvlasov/", p), upgrade = FALSE)
## -------------------------------------------------------------------------------

get_data_set_by_title <- function(data_sets_list, title) {
    for (ds in data_sets_list) {
        !is.null(ds$title) && ds$title == title && return(ds)
    }
}

get_data_set_files <- function(ds) {
    if(is.list(ds$files)) {
        sapply(ds$files, `[[`, "file")
    } else {
        ds$files
    }
}




## filter_pdpass_that_did_not_change <- function(tb) {
##     tb[is.na(tb$pdpco2),]
## }


get_patents_with_single_assignee <- function(tb) {
    tb[tb$assgnum == 1,]
}

find_name_for_org <- function(pdpass) {
    ## patents with single assignee
    dt <- data$`https://www.nber.org/~jbessen/patassg.dta.zip` |>
        get_patents_with_single_assignee()
    match <- which(dt$pdpass == pdpass)
    if(length(match) < 1) return(NA)
    patnum <- dt[match[1],]$patnum
    pat <- data$`https://s3.amazonaws.com/data.patentsview.org/download/rawassignee.tsv.zip`
    pat <- pat[pat$patent_id == patnum, ]
    if(nrow(pat) != 1) return(NA)
    else return(pat$organization)
}

romRDS::romRDS("nber_std_names"
             , {
                 ## info <- yaml::read_yaml("info.yml")
                 ## options(timeout=600)
                 ## ## default is only 60 which is not enough for large data
                 ## data <- 
                 ##     info$metacodes$data_sets |>
                 ##     get_data_set_by_title("Company:patent matching") |>
                 ##     get_data_set_files() |>
                 ##     pbapply::pbsapply(romRDS::deploy_file) |>
                 ##     pbapply::pblapply(readRDS) |>
                 ##     pbapply::pblapply(data.table::as.data.table)
                 with(data$`https://www.nber.org/~jbessen/assignee.dta.zip`
                    , {
                        data.table::data.table(
                                        std_name = standard_name
                                      , name = pdpass |>
                                            pbapply::pbsapply(find_name_for_org)
                                    )
                    })
             }
           , dir = "data/rds")
