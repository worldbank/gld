## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "# "
)

library(jsonify)

## -----------------------------------------------------------------------------
## scalar -> single array
to_json( 1 )
to_json( "a" )

## scalar (unboxed) -> single value
to_json( 1, unbox = TRUE )
to_json( "a", unbox = TRUE )

## vector -> array
to_json( 1:4 )
to_json( letters[1:4] )

## named vector - array (of the elements)
to_json( c("a" = 1, "b" = 2) )

## matrix -> array of arrays (by row)
to_json( matrix(1:4, ncol = 2) )
to_json( matrix(letters[1:4], ncol = 2))

## matrix -> array of arrays (by column)
to_json( matrix(1:4, ncol = 2), by = "column" )
to_json( matrix(letters[1:4], ncol = 2 ), by = "column" )

## -----------------------------------------------------------------------------
to_json( list( 1:2, c("a","b") )  )

## -----------------------------------------------------------------------------
## List of vectors -> object with named arrays
to_json( list( x = 1:2 ) )

## -----------------------------------------------------------------------------
to_json( list( x = 1:2, y = list( letters[1:2] ) ) )

## -----------------------------------------------------------------------------
## data.frame -> array of objects (by row) 
to_json( data.frame( x = 1:2, y = 3:4) )
to_json( data.frame( x = c("a","b"), y = c("c","d")))

## -----------------------------------------------------------------------------
## data.frame -> object of arrays (by column)
to_json( data.frame( x = 1:2, y = 3:4), by = "column" )
to_json( data.frame( x = c("a","b"), y = c("c","d") ), by = "column" )

## -----------------------------------------------------------------------------
## data.frame where one colun is a list
df <- data.frame( id = 1, val = I(list( x = 1:2 ) ) )
to_json( df )

## -----------------------------------------------------------------------------
## which we see is made up of
to_json( data.frame( id = 1 ) )
## and
to_json( list( x = 1:2 ) )

## -----------------------------------------------------------------------------
to_json( df, by = "column" )

## -----------------------------------------------------------------------------

df <- data.frame( id = 1, val = I(list(c(0,0))))
df
to_json( df )

df <- data.frame( id = 1:2, val = I(list( x = 1:2, y = 3:4 ) ) )
df
to_json( df )

df <- data.frame( id = 1:2, val = I(list( x = 1:2, y = 3:6 ) ), val2 = I(list( a = "a", b = c("b","c") ) ) )
df
pretty_json( df )

df <- data.frame( id = 1:2, val = I(list( x = 1:2, y = 3:6 ) ), val2 = I(list( a = "a", b = c("b","c") ) ), val3 = I(list( l = list( 1:3, l2 = c("a","b")), 1)) )
df
pretty_json( df )


## -----------------------------------------------------------------------------
## scalar / vector
js <- '[1,2,3]'
from_json( js )

## matrix
js <- '[[1,2],[3,4],[5,6]]'
from_json( js )

## data.frame
js <- '[{"x":1,"y":"a"},{"x":2,"y":"b"}]'
from_json( js )

## -----------------------------------------------------------------------------
js <- '[{"x":1},{"y":2}]'
from_json( js )

## -----------------------------------------------------------------------------
js <- '[{"x":1},{"y":2}]'
from_json( js, fill_na = TRUE )

