% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulate_fitmodelcomparison.R
\name{simulate_fitmodelcomparison}
\alias{simulate_fitmodelcomparison}
\title{Fitting 2 simple viral infection models to influenza data}
\usage{
simulate_fitmodelcomparison(U0 = 1e+05, I0 = 0, V0 = 1, X0 = 1,
  dI = 1, dV = 2, g = 0, p = 10, k = 1e-06, a = 1e-05,
  alow = 1e-06, ahigh = 1e-04, b = 1e-05, blow = 1e-06,
  bhigh = 0.001, r = 1, rlow = 0.1, rhigh = 2, dX = 1,
  dXlow = 0.1, dXhigh = 10, modeltype = 1, iter = 100)
}
\arguments{
\item{U0}{initial number of uninfected target cells}

\item{I0}{initial number of infected target cells}

\item{V0}{initial number of infectious virions}

\item{X0}{initial level of immune response}

\item{dI}{rate at which infected cells die}

\item{dV}{rate at which infectious virus is cleared}

\item{g}{unit conversion factor}

\item{p}{rate at which infected cells produce virus}

\item{k}{rate of killing of infected cells by T-cells (model 1) or virus by Ab (model 2)}

\item{a}{activation of T-cells (model 1) or growth of antibodies (model 2)}

\item{alow}{lower bound for activation rate}

\item{ahigh}{upper bound for activation rate}

\item{b}{rate at which virus infects cells}

\item{blow}{lower bound for infection rate}

\item{bhigh}{upper bound for infection rate}

\item{r}{rate of T-cell expansion (model 1)}

\item{rlow}{lower bound for expansion rate}

\item{rhigh}{upper bound for expansion rate}

\item{dX}{rate at which antibodies decay (model 2)}

\item{dXlow}{lower bound for decay rate}

\item{dXhigh}{upper bound for decay rate}

\item{modeltype}{fitting model 1 or 2}

\item{iter}{max number of steps to be taken by optimizer}
}
\value{
The function returns a list containing the best fit timeseries,
the best fit parameters, the data and the AICc for the model.
}
\description{
This function runs a simulation of a compartment model
using a set of ordinary differential equations.
The model describes a simple viral infection system in the presence of drug treatment.
The user provides initial conditions and parameter values for the system.
The function simulates the ODE using an ODE solver from the deSolve package.
The function returns a matrix containing time-series of each variable and time.
}
\details{
Two simple compartmental ODE models mimicking acute viral infection
with T-cells (model 1) or antibodies (model 2) are fitted to data.
}
\section{Warning}{
 This function does not perform any error checking. So if
  you try to do something nonsensical (e.g. specify negative parameter or starting values),
  the code will likely abort with an error message.
}

\examples{
# To run the code with default parameters just call the function:
\dontrun{result <- simulate_fitmodelcomparison()}
# To apply different settings, provide them to the simulator function, like such:
result <- simulate_fitmodelcomparison(iter = 5)
result <- simulate_fitmodelcomparison(iter = 5, modeltype = 2)
}
\seealso{
See the Shiny app documentation corresponding to this
function for more details on this model.
}
\author{
Andreas Handel
}
