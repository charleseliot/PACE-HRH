% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pace_population_predict.R
\name{ComputePopulationProjection}
\alias{ComputePopulationProjection}
\title{Compute A Population Projection}
\usage{
ComputePopulationProjection(
  initialPopulation,
  populationChangeRates,
  years,
  normalize = NULL,
  growthFlag = TRUE
)
}
\arguments{
\item{initialPopulation}{Population structure}

\item{populationChangeRates}{Population change rates (both fertility and mortality)}

\item{years}{Vector of years to model}

\item{normalize}{Whether or not to normalize the initial population
default = NULL, meaning don't normalize. A numeric value means normalize
to that value.}

\item{growthFlag}{If FALSE, normalize each year to the same population as
the initial year (default = TRUE)}
}
\value{
Demographics time-series
}
\description{
Use an initial population pyramid and population change rates
to predict future population pyramids.
}
\examples{
\dontrun{
library(pacehrh)
pacehrh::Trace(TRUE)

pacehrh::InitializePopulation()
pacehrh::InitializeScenarios()
pacehrh::InitializeStochasticParameters()
pacehrh::InitializeSeasonality()

scenario <- "ScenarioName"

set.seed(54321)

scenarioData <- SaveBaseSettings(scenario)
ConfigureExperimentValues()

exp <- pacehrh:::EXP
gpe <- pacehrh:::GPE

population <- ComputePopulationProjection(
  exp$initialPopulation,
  exp$populationChangeRates,
  gpe$years,
  normalize = scenarioData$BaselinePop,
  growthFlag = scenarioData$o_PopGrowth
)
}
}
