#' Contents of Complete Works of William Shakespeare (dataframe)
#'
#' A dataframe containing the full text of all of the complete works of William
#' Shakespeare, as provided by Project Gutenberg.
#'
#' @format A data frame with 166340 rows and 4 variables:
#' \describe{
#'   \item{name}{short (or common) name of the work}
#'   \item{content}{the full contents of the work. Each line is ~70 characters}
#'   \item{full_name}{the complete name of the work, as listed}
#'   \item{genre}{whether the work is poetry, history, comedy, or tragedy}
#' }
#' @source \url{http://www.gutenberg.org/files/100/100-0.txt}
"all_works_df"

#' Contents of Complete Works of William Shakespeare (list)
#'
#' A list containing the full text of all of the complete works of William
#' Shakespeare, as provided by Project Gutenberg.
#'
#' @format A list with 44 elements, each one containing a character vector
#' containing the full text of a work, given in the element name.
#' @source \url{http://www.gutenberg.org/files/100/100-0.txt}
"all_works_list"

#' Project Gutenberg preface to Shakespeare's Complete Works
#'
#' A character vector containing all text before the beginning of the actual
#' text of the work.
#'
#' @format A character vector of length 45.
#'
#' @source \url{http://www.gutenberg.org/files/100/100-0.txt}
"intro"

#' Project Gutenberg ending to Shakespeare's Complete Works
#'
#' A character vector containing all text after the end of the text.
#'
#' @format A character vector of length 416. Contains the license.
#'
#' @source \url{http://www.gutenberg.org/files/100/100-0.txt}
"outro"

#' Text of A Lover's Complaint
#'
#' A character vector containing the complete text of A Lover's Complaint by
#' William Shakespeare.
#'
#' @format A character vector of length 383. Each line is <= 70 characters.
#'
#' @source \url{http://www.gutenberg.org/files/100/100-0.txt}
#'
"a_lovers_complaint"

#' Text of A Midsummer Night's Dream
#'
#' A character vector containing the complete text of A Midsummer Night's Dream
#' by William Shakespeare. Each line is <= 70 characters.
#'
#' @format A character vector of length 3460.
#'
#' @source \url{http://www.gutenberg.org/files/100/100-0.txt}
#'
"a_midsummer_nights_dream"
