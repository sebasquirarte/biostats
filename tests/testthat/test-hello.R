# tests/testthat/test-hello.R

test_that("hello function works", {
  # Test that hello() returns a character string
  result <- hello()
  expect_type(result, "character")
})

test_that("hello returns expected message", {
  # Test that hello() returns the expected message
  result <- hello()
  expect_equal(result, "Hello, World!")
})

test_that("hello function has no parameters", {
  # Test that hello() works without any arguments
  expect_error(hello(), NA)  # Should NOT error
})

test_that("hello returns single value", {
  # Test that hello() returns exactly one value
  result <- hello()
  expect_length(result, 1)
})
