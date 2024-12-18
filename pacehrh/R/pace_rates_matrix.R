#' Generate A Matrix Of Stochastically Varied Population Change Rates
#'
#' @param label Lookup string for the rates type
#'
#' @return Rates matrix
#'
#' @noRd
generateRatesMatrix <- function(label = NULL) {
  pars <- BVE$stochasticParams
  years <- BVE$years

  if (is.null(label)) {
    return(NULL)
  }

  if (!assertthat::is.string(label)) {
    traceMessage("Non-string label passed to generateRatesMatrix()")
    return(NULL)
  }

  rates <- BVE$populationChangeRates[[label]]

  if (is.null(rates)) {
    return(NULL)
  }

  # Grab the appropriate change rates limits range
  limits <- .getRatesLimits(label)

  m <- .generateRatesMatrix(
    pars,
    years,
    rates,
    limits,
    stochasticity = GPE$stochasticity,
    seed = NULL,
    optConstantFertility =
      ifelse(BVE$scenario$o_Fertility_decr == TRUE, FALSE, TRUE)
  )

  return(m)
}

.getRatesLimits <- function(rateTypeLabel) {
  limitsTable <- BVE$changeRateLimits

  if (is.null(limitsTable)) {
    return(c(NA_real_, NA_real_))
  }

  if (length(grep("Fertility", rateTypeLabel, ignore.case = TRUE)) == 1) {
    row <- limitsTable[limitsTable$RateCategory == "Fertility", ]
    limits <- c(row$Min, row$Max)
  } else if (length(grep("Mortality", rateTypeLabel, ignore.case = TRUE)) == 1) {
    row <- limitsTable[limitsTable$RateCategory == "Mortality", ]
    limits <- c(row$Min, row$Max)
  } else if (tolower(rateTypeLabel) == "incidence") {
    row <- limitsTable[limitsTable$RateCategory == "Incidence", ]
    limits <- c(row$Min, row$Max)
  } else {
    limits <- c(NA_real_, NA_real_)
  }

  return(limits)
}

.getMinMaxRates <- function(initRates, limits) {
  if (!is.na(limits[1])) {
    minRates <- initRates * limits[1]
  } else {
    minRates <- NULL
  }

  if (!is.na(limits[2])) {
    maxRates <- initRates * limits[2]
  } else {
    maxRates <- NULL
  }

  return(list(min = minRates, max = maxRates))
}

.applyRateLimits <- function(rates, limits) {
  if (!is.null(limits$max)) {
    rates <- pmin(limits$max, rates)
  }

  if (!is.null(limits$min)) {
    rates <- pmax(limits$min, rates)
  }

  return(rates)
}

#' Internal Function to Generate Rates Matrices
#'
#' @param pars Tibble of stochastic parameters
#' @param years Vector of covered years (e.g. 2020:2050)
#' @param rates Change rates structure
#' @param limits Min/max pair of limits for rate changes (default = `c(NA_real_, NA_real_)`)
#' @param stochasticity TBD flag (default = TRUE)
#' @param seed Random number seed (default = NULL)
#' @param optConstantFertility TBD flag (default = FALSE)
#'
#' @return Rates matrix
#'
#' @noRd
.generateRatesMatrix <-
  function(pars,
           years,
           rates,
           limits = c(NA_real_, NA_real_),
           stochasticity = TRUE,
           seed = NULL,
           optConstantFertility = FALSE) {
    # Grab the initial fertility rates, then apply stochastics
    initRates <- rates$bandedRates$initValues
    rateNames <- rates$bandedRates$labels

    # Initialize a rates matrix
    nRows <- length(initRates)
    nCols <- length(years)
    m <-
      matrix(
        nrow = nRows,
        ncol = nCols,
        dimnames = list(rateNames, as.character(years))
      )

    # Grab the change rates values (deltaRatios)
    # If fertility rate changes are turned off, assume a delta ratio of 1.
    # (The same change rate year over year, but still subject to stochastic
    # tweaks if stochasticity == TRUE.)
    deltaRatios <- rates$bandedRates$changeRates

    # TODO: Check whether this flag should apply to ALL rates, or just fertility
    if (optConstantFertility == TRUE) {
      deltaRatios[seq_along(deltaRatios)] <- 1
    }

    if (stochasticity == FALSE) {
      # Compute min and max rate caps
      rateLimits <- .getMinMaxRates(initRates, limits)
      m[, 1] <- initRates

      # Apply the same delta ratio to every year of the time series
      for (j in 2:nCols) {
        m[, j] <- .applyRateLimits(m[, j - 1] * deltaRatios, rateLimits)
      }
    } else {
      if (rates$type == "Fertility") {
        p <- pars[pars$Value == "Fertility rates", ]$p
      } else {
        p <- pars[pars$Value == "Mortality rates", ]$p
      }

      p <- p * c(-1, 1)
      initRates <-
        initRates * (1 + runif(length(initRates), p[1], p[2]))

      rateLimits <- .getMinMaxRates(initRates, limits)

      m[, 1] <- initRates

      # Grab the stochastic parameters for fertility rates deltas.

      if (rates$type == "Fertility") {
        p <- pars[pars$Value == "Annual delta fertility rates", ]$p
        q <- pars[pars$Value == "Annual delta fertility rates", ]$q
      } else {
        p <- pars[pars$Value == "Annual delta mortality rates", ]$p
        q <- pars[pars$Value == "Annual delta mortality rates", ]$q
      }

      lims <- p * q * c(-1, 1)

      # TODO: make all the rtruncnorm calls at once, build a lookup table

      # Apply stochastic tweaks to every year of the time series
      for (j in 2:nCols) {
        e <- truncnorm::rtruncnorm(
          length(deltaRatios),
          mean = 0,
          sd = p,
          a = lims[1],
          b = lims[2]
        )
        deltas <- deltaRatios * (1 + e)

        m[, j] <- .applyRateLimits(m[, j - 1] * deltas, rateLimits)
      }
    }

    return(m)
  }
