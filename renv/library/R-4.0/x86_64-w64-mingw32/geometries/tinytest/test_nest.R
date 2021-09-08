
m <- matrix(1:4, ncol = 2)
l1 <- list( m )
l2 <- list( l1 )
l3 <- list( l2 )
l4 <- list( l3 )
l5 <- list( l4 )


expect_equal( geometries:::rcpp_nest( l1, 1 ), l1 )
expect_equal( geometries:::rcpp_nest( l1, 2 ), l2 )
expect_equal( geometries:::rcpp_nest( l1, 3 ), l3 )
expect_equal( geometries:::rcpp_nest( l1, 4 ), l4 )
expect_equal( geometries:::rcpp_nest( l1, 5 ), l5 )

expect_equal( geometries:::rcpp_nest( l5, 1 ), l1 )
expect_equal( geometries:::rcpp_nest( l5, 2 ), l2 )
expect_equal( geometries:::rcpp_nest( l5, 3 ), l3 )
expect_equal( geometries:::rcpp_nest( l5, 4 ), l4 )
expect_equal( geometries:::rcpp_nest( l5, 5 ), l5 )

## representative of a POLYGON
l <- list(m, m)

## representative of converting to a MULTIPOLYGON
res <- geometries:::rcpp_nest( l, 2 )
expect_true( length( res ) == 1 )
expect_true( length( res[[1]] ) == 2 )

res <- geometries:::rcpp_nest( l, 1 )
expect_equal( l, res )

expect_error( geometries:::rcpp_nest( l, 0 ), "geometries - error trying to unnest the object" )

## representative of converting to LINESTRINGs
# geometries:::rcpp_nest( l, 1 )
# DOes this make sense?
# LINESTRING is a MATRIX
# so it's nesting is 0
# But if there are more than one, we can't unnest to 2 matrices, because that's not a SEXP
# so it has to be at least a list of matrices
# same with POINTs and MULTIPOINTs


## TODO
# ## list of shapes (like a sfc)
# ## Needs to iterate over the list and nest/unnest each shape individually
# l <- list(
#   l1,
#   l2
# )
#
# expect_equal( geometries:::rcpp_nest(l, 3), list( list( l )  ) )


