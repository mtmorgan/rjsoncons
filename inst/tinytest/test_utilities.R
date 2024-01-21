.is_scalar_character <- rjsoncons:::.is_scalar_character

expect_true(.is_scalar_character("a"))
expect_false(.is_scalar_character(character()))
expect_false(.is_scalar_character(c("a", "b")))
expect_false(.is_scalar_character(NA_character_))
expect_false(.is_scalar_character(""))
expect_true(.is_scalar_character("", z.ok = TRUE))