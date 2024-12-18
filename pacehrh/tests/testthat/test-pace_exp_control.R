library(pacehrh)

withr::local_dir("..")

test_that("Experiment control: missing tables", {
  testthat::expect_equal(pacehrh:::GPE$inputExcelFile, "./config/model_inputs.xlsx")

  e <- pacehrh:::GPE
  local_vars("inputExcelFile", envir = e)
  local_vars("globalConfigLoaded", envir = e)
  local_vars("scenarios", envir = e)

  # Clear out the BVE environment
  e$scenarios <- NULL
  rm(list = ls(name = pacehrh:::BVE, all.names = TRUE), pos = pacehrh:::BVE)

  # Set input file, and cheat the system into thinking the global configuration
  # is already loaded
  pacehrh::SetInputExcelFile("./simple_config/model_inputs.xlsx")
  e$globalConfigLoaded <- TRUE

  # Attempt to run experiments without any required initialization. Two warnings
  # should be raised.
  scenario <- "BasicModel"
  testthat::expect_snapshot(results <- pacehrh::RunExperiments(scenarioName = scenario, trials = 5))
  testthat::expect_true(is.null(results))
})

test_that("Experiment control: bad scenarios", {
  testthat::expect_equal(pacehrh:::GPE$inputExcelFile, "./config/model_inputs.xlsx")

  e <- pacehrh:::GPE
  local_vars("inputExcelFile", envir = e)
  local_vars("globalConfigLoaded", envir = e)
  local_vars("scenarios", envir = e)

  # Set input file, and cheat the system into thinking the global configuration
  # is already loaded
  pacehrh::SetInputExcelFile("./simple_config/model_inputs.xlsx")
  e$globalConfigLoaded <- TRUE

  pacehrh::InitializePopulation()
  pacehrh::InitializeScenarios()
  pacehrh::InitializeSeasonality()
  pacehrh::InitializeStochasticParameters()
  pacehrh::InitializeCadreRoles()

  testthat::expect_true(!is.null(e$scenarios))

  out <- SaveBaseSettings(scenarioName = "")
  testthat::expect_true(is.null(out))

  out <- SaveBaseSettings(scenarioName = NULL)
  testthat::expect_true(is.null(out))

  out <- SaveBaseSettings(scenarioName = "not-a-scenario")
  testthat::expect_true(is.null(out))
})

# Test that the correct sheets are read, based on the sheet names in the
# scenarios record.

test_that("Experiment control: basic read from Excel", {
  testthat::expect_equal(pacehrh:::GPE$inputExcelFile, "./config/model_inputs.xlsx")

  gpe <- pacehrh:::GPE
  bve <- pacehrh:::BVE
  local_vars("inputExcelFile", envir = gpe)
  local_vars("globalConfigLoaded", envir = gpe)

  local_vars("initialPopulation", envir = bve)
  local_vars("populationLabels", envir = bve)
  local_vars("scenarios", envir = gpe)
  local_vars("seasonalityCurves", envir = bve)
  local_vars("seasonalityOffsets", envir = bve)
  local_vars("cadreRoles", envir = bve)

  # Set input file, and cheat the system into thinking the global configuration
  # is already loaded
  pacehrh::SetInputExcelFile("./simple_config/model_inputs.xlsx")
  gpe$globalConfigLoaded <- TRUE
  gpe$scenarios <- NULL

  pacehrh::InitializePopulation()
  pacehrh::InitializeScenarios()
  pacehrh::InitializeSeasonality()
  pacehrh::InitializeStochasticParameters()
  pacehrh::InitializeCadreRoles()

  testthat::expect_true(!is.null(gpe$scenarios))

  scenarioName <- "TEST_CustomSheets_1"
  assertthat::assert_that(scenarioName %in% gpe$scenarios$UniqueID)

  result <- pacehrh::SaveBaseSettings(scenarioName)

  testthat::expect_true(!is.null(result))
  testthat::expect_true(result$UniqueID == scenarioName)
})
