#' if argument is NULL, no line output
#'
#' @keywords internal
cat0 <- function(prefix = "", x){
  if(!is.null(x)){
    cat(prefix, x, "\n")
  }
}


#' taken from utils:::format.object_size
#'
#' @keywords internal
format_object_size <- function (x, units = "b", ...)
{
  units <- match.arg(units, c("b", "auto", "Kb", "Mb", "Gb",
                              "Tb", "Pb", "B", "KB", "MB", "GB", "TB", "PB", "KiB",
                              "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"))
  if (units == "auto")
    units <- if (x >= 1024^4)
      "Tb"
  else if (x >= 1024^3)
    "Gb"
  else if (x >= 1024^2)
    "Mb"
  else if (x >= 1024)
    "Kb"
  else "b"
  switch(units, b = , B = paste(x, "bytes"), Kb = , KB = paste(round(x/1024,
                                                                     1L), "Kb"), Mb = , MB = paste(round(x/1024^2, 1L), "Mb"),
         Gb = , GB = paste(round(x/1024^3, 1L), "Gb"), Tb = ,
         TB = paste(round(x/1024^4, 1L), "Tb"), Pb = , PB = paste(round(x/1024^5,
                                                                        1L), "Pb"), KiB = paste(round(x/1024, 1L), "KiB"),
         MiB = paste(round(x/1024^2, 1L), "MiB"), GiB = paste(round(x/1024^3,
                                                                    1L), "GiB"), TiB = paste(round(x/1024^4, 1L), "TiB"),
         PiB = paste(round(x/1024^5, 1L), "PiB"), EiB = paste(round(x/1024^6,
                                                                    1L), "EiB"), ZiB = paste(round(x/1024^7, 1L), "ZiB"),
         YiB = paste(round(x/1024^8, 1L), "YiB"))
}

#' Timestamp to R date
#' @keywords internal
timestamp_to_r <- function(t){
  as.POSIXct(t, format = "%Y-%m-%dT%H:%M:%S")
}


#' A helper function that tests whether an object is either NULL _or_
#' a list of NULLs
#'
#' @keywords internal
is.NullOb <- function(x) is.null(x) | all(sapply(x, is.null))

#' Recursively step down into list, removing all such objects
#'
#' @keywords internal
rmNullObs <- function(x) {
  x <- Filter(Negate(is.NullOb), x)
  lapply(x, function(x) if (is.list(x)) rmNullObs(x) else x)
}

#' Is this a try error?
#'
#' Utility to test errors
#'
#' @param test_me an object created with try()
#'
#' @return Boolean
#'
#' @keywords internal
is.error <- function(test_me){
  inherits(test_me, "try-error")
}

#' Get the error message
#'
#' @param test_me an object that has failed is.error
#'
#' @return The error message
#'
#' @keywords internal
error.message <- function(test_me){
  if(is.error(test_me)) attr(test_me, "condition")$message
}

#' Customer message log level
#'
#' @param ... The message(s)
#' @param level The severity
#'
#' @details 0 = everything, 1 = debug, 2=normal, 3=important
#' @keywords internal
myMessage <- function(..., level = 1){


  compare_level <- getOption("googleAuthR.verbose")
  if(is.null(compare_level)) compare_level <- 1

  if(level >= compare_level){
    message(Sys.time()," -- ", ...)
  }

}

#' Substitute in a (nested) list
#'
#' @param template A template named list
#' @param replace_me A similar named list with different values to substitute
#'
#' @return The template with the values substituted.
#' @keywords internal
#' If replace_me has list names not in template, the value stays the same.
substitute.list <- function(template, replace_me){

  ## remove possible NULL entries
  template <- rmNullObs(template)
  replace_me <- rmNullObs(replace_me)

  postwalk(template, function(x) replace.kv(x,replace_me))

}

#' Walk into a list
#'
#' If passed an object such as a nested list, will apply function
#'   on inner elements that are not lists.
#'
#' @param x what to check
#' @param func Function to apply if not a list
#' @keywords internal
#' @return the function acting on x or an inner element of x
postwalk <- function(x,func){
  if(is.list(x)){
    func(lapply(x,postwalk,func))
  } else {
    func(x)
  }
}

#' Create a modified list
#'
#' @param template a (nested) list with elements to replace
#' @param replace a subset of template with same names but replacement values
#' @keywords internal
#' @return a list like template but with values replace from replace
replace.kv <- function(template,replace) {
  if(!is.list(template)) return(template)

  i <- match(names(template),names(replace))
  w <- which(!is.na(i))

  replace(template,w,replace[i[w]])

}





#' Idempotency
#'
#' A random code to ensure no repeats
#'
#' @return A random 15 digit hash
#' @keywords internal
idempotency <- function(){
  paste(sample(c(LETTERS, letters, 0:9), 15, TRUE),collapse="")
}
