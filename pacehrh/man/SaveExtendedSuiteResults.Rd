% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pace_cadre_process.R
\name{SaveExtendedSuiteResults}
\alias{SaveExtendedSuiteResults}
\title{Compute And Save Suite Results In Extended Format}
\usage{
SaveExtendedSuiteResults(results = NULL, filepath = NULL, run = "Run-1")
}
\arguments{
\item{results}{Results structure (as returned by \code{\link[=RunExperiments]{RunExperiments()}}).}

\item{filepath}{Destination CSV file to write results. Default = NULL.}

\item{run}{Name of experiment run}
}
\value{
Data frame version of CSV file.
}
\description{
Compute And Save Suite Results In Extended Format
}
\examples{
\dontrun{
results <-
  pacehrh::RunExperiments(
    scenarioName = "MergedModel",
    trials = 20
  )

SR <- pacehrh::SaveExtendedSuiteResults(results, filepath = "_SR.csv", run = "Run-1")
CA <- pacehrh::SaveCadreAllocations(SR, filepath = "_CA.csv")
cadreOverheadTimes <- pacehrh::SaveCadreOverheadData(filepath = "_COD.csv")
summaryStats <- pacehrh::ComputeSummaryStats(SR, CA)
}
}
