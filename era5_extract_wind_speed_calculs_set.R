rm(list = ls())

# to look inside nc
library(ncdf4) 
library(raster)
library(lubridate)

south_lat <- c(40, 55)
south_long <- c(35, 50)

res_dir_name <- "./"

re_dir <- "./"
re_coords_fl <- "coords_example.csv"

data_dir_name <- "./"

var_name <- c("v100", "u100")

# functions --------------------------------------------------------------------
extract_ts <- function(u_stack, v_stack, x, y) {
    u_ts <- extract(x = u_stack, y = cbind(x, y))
    v_ts <- extract(x = v_stack, y = cbind(x, y))
    srfw_ts <- sqrt((u_ts[1,])^2 + v_ts[1,]^2)
    return(srfw_ts)
}

# read RES coordinates ---------------------------------------------------------
re_coords_df <- read.csv(file.path(re_dir, re_coords_fl), 
    sep = "", dec = ".", header = FALSE, comment.char = "#",
    stringsAsFactors = FALSE)
colnames(re_coords_df) <- c("power", "lat", "long")
print(str(re_coords_df))

in_south_bool <- (re_coords_df$lat > min(south_lat) & re_coords_df$lat < max(south_lat)) &
    (re_coords_df$long > min(south_long) & re_coords_df$long < max(south_long))
south_re_df <- re_coords_df[in_south_bool,]
print(south_re_df) 

wind_gen_ids <- paste("a", seq(along.with=south_re_df[, 1]), sep="_")
south_re_df[, "wind_gen_id"] <- wind_gen_ids

write.table(south_re_df, file=paste0("wind_power_plants_info.csv"), 
    quote=FALSE, sep=";", row.names=FALSE) 

for ( year_to_calcul in 1992:2018[1] ) {

    data_file_name <- paste0("era_wind_ru_south_", year_to_calcul, ".nc")

    # check nc data ------------------------------------------------------------
    nc_fl <- nc_open(file.path(data_dir_name, data_file_name))
    
    glob_attr <- ncatt_get(nc_fl, varid=0, attname = NA, verbose = TRUE)
    
    print(glob_attr)
    print(nc_fl)
    
    nc_close(nc_fl)
    
    # quick look with raster ---------------------------------------------------
    nc_raster_u <- brick(file.path(data_dir_name, data_file_name), 
        varname = var_name[1])
    print(nc_raster_u)
    
    # as there is not vars with > 1 parameters
    if ( length(var_name) > 1 ) {
        nc_raster_v <- brick(file.path(data_dir_name, data_file_name), 
            varname = var_name[2])
        print(nc_raster_v)
    }
    
    data_unit <- nc_raster_u@data@unit
    nc_time <- getZ(nc_raster_u)
    
    if ( all(is.na(ymd_hms(nc_time))) ){
        data_year <- unique(year(ymd(nc_time))) 
    } else {
        data_year <- unique(year(ymd_hms(nc_time)))
    }
    
    wsrf_stack_u <- stack(nc_raster_u)

    if ( length(var_name) > 1 ) {
        wsrf_stack_v <- stack(nc_raster_v)
    }
    
    # extract time-series ------------------------------------------------------
    print(paste0("Start data extraction. Processed year: ", year_to_calcul))
    t_extract_start <- Sys.time()
    srfw_list_ts <- lapply(
        FUN=function(i){
        extract_ts(u_stack=wsrf_stack_u, 
            v_stack=wsrf_stack_v, 
            x=south_re_df[i, "long"], 
            y=south_re_df[i, "lat"])
    },
        X = seq(along.with=south_re_df[,1])     
    )
    t_extract_finish <- Sys.time()
    print("Time series extracted on the whole points set for")
    print(t_extract_finish - t_extract_start)
    
    srfw_df <- data.frame(
        Date=nc_time, 
        as.data.frame(srfw_list_ts, col.names=wind_gen_ids),
        stringsAsFactors=FALSE
    )
    write.table(srfw_df, 
        file=paste0("one_point_test_wind_speed_10m_", data_year, ".csv"), 
        quote=FALSE, sep=";", row.names=FALSE)
}