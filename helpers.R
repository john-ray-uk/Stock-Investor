
# This file is credited to the official 'Get Started' tutorial from the R
# Shiny App website: https://shiny.posit.co/r/getstarted/shiny-basics/lesson6/

if (!exists(".inflation")) {
  .inflation <- getSymbols('CPIAUCNS', src = 'FRED', 
                           auto.assign = FALSE)
}  

# adjusts Google finance data with the monthly consumer price index 
# values provided by the Federal Reserve of St. Louis
# historical prices are returned in present values 

adjust <- function(data) {
  
  latestcpi <- last(.inflation)[[1]]
  inf.latest <- time(last(.inflation))
  months <- split(data)               
  
  adjust_month <- function(month) {               
    date <- substr(min(time(month[1]), inf.latest), 1, 7)
    coredata(month) * latestcpi / .inflation[date][[1]]
  }
  
  adjs <- lapply(months, adjust_month)
  adj <- do.call("rbind", adjs)
  axts <- xts(adj, order.by = time(data))
  
  # restore original column names if available (very small, safe)
  orig_names <- colnames(data)
  if (!is.null(orig_names)) colnames(axts) <- orig_names
  
  # assign Volume by name (safe) — create "Volume" if no matching column name
  vol_name <- orig_names[grep("Volume$|\\.Volume$|Vol$|VO$", orig_names, ignore.case = TRUE)]
  if (length(vol_name) == 1) {
    axts[, vol_name] <- Vo(data)
  } else {
    axts$Volume <- Vo(data)
  }
  
  axts
  
}