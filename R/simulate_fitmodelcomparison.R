##################################################################################
##fitting influenza virus load data to 2 simple ODE models
##illustrates model comparison and parameter estimation
##written by Andreas Handel, ahandel@uga.edu, last change 5/25/18

##all sub-functions are specified first

#########################################
#ode equations for model 1
model1ode <- function(t, y, parms)
{
  with(
    as.list(c(y,parms)), #lets us access variables and parameters stored in y and parms by name
    {

      dUdt = -b*V*U
      dIdt = b*V*U - dI*I - k*X*I
      dVdt = p*I - dV*V - b*V*U
      dXdt = a*V + r*X

      list(c(dUdt, dIdt, dVdt,dXdt))
    }
  ) #close with statement
} #end function specifying the ODEs

#########################################
#ode equations for model 2
model2ode <- function(t, y, parms)
{
  with(
    as.list(c(y,parms)), #lets us access variables and parameters stored in y and parms by name
    {

      dUdt = -b*V*U
      dIdt = b*V*U - dI*I
      dVdt = p*I - dV*V - k*X*V - b*V*U
      dXdt = a*V*X - dX*X

      list(c(dUdt, dIdt, dVdt, dXdt))
    }
  ) #close with statement
} #end function specifying the ODEs



###################################################################
#function that fits the ODE model to data
###################################################################
fitfunction <- function(params, mydata, Y0, timevec, modeltype, fixedpars, fitparnames)
{

   names(params) = fitparnames #for some reason nloptr strips names from parameters
   modelpars = c(params,fixedpars)
   #call ode-solver lsoda to integrate ODEs

   if (modeltype == 1)
   {
     odeout <- try(deSolve::ode(y = Y0, times = timevec, func = model1ode, parms=modelpars, atol=1e-8, rtol=1e-8));
   }
   if (modeltype == 2)
   {
     odeout <- try(deSolve::ode(y = Y0, times = timevec, func = model2ode, parms=modelpars, atol=1e-8, rtol=1e-8));
   }

    #extract values for virus load at time points where data is available
    modelpred = odeout[match(mydata$time,odeout[,"time"]),"V"];

    #since the ODE returns values on the original scale, we need to transform it into log10 units for the fitting procedure
    #due to numerical issues in the ODE model, virus might become negative, leading to problems when log-transforming.
    #Therefore, we enforce a minimum value of 1e-10 for virus load before log-transforming
    #fitfunction returns the log-transformed virus load obtained from the ODE model to the nls function
    logvirus=c(log10(pmax(1e-10,modelpred)));


    #return the objective function, the sum of squares,
    #which is being minimized by the optimizer
    return(sum((logvirus-mydata$outcome)^2))



} #end function that fits the ODE model to the data

############################################################
#the main part, which calls the fit function
############################################################

#' Fitting 2 simple viral infection models to influenza data
#'
#' @description This function runs a simulation of a compartment model
#' using a set of ordinary differential equations.
#' The model describes a simple viral infection system in the presence of drug treatment.
#' The user provides initial conditions and parameter values for the system.
#' The function simulates the ODE using an ODE solver from the deSolve package.
#' The function returns a matrix containing time-series of each variable and time.
#'
#' @param U0 initial number of uninfected target cells
#' @param I0 initial number of infected target cells
#' @param V0 initial number of infectious virions
#' @param X0 initial level of immune response
#' @param p rate at which infected cells produce virus
#' @param dI rate at which infected cells die
#' @param dV rate at which infectious virus is cleared
#' @param k rate of killing of infected cells by T-cells (model 1) or virus by Ab (model 2)
#' @param a activation of T-cells (model 1) or growth of antibodies (model 2)
#' @param alow lower bound for activation rate
#' @param ahigh upper bound for activation rate
#' @param b rate at which virus infects cells
#' @param blow lower bound for infection rate
#' @param bhigh upper bound for infection rate
#' @param r rate of T-cell expansion (model 1)
#' @param rlow lower bound for expansion rate
#' @param rhigh upper bound for expansion rate
#' @param dX rate at which antibodies decay (model 2)
#' @param dXlow lower bound for decay rate
#' @param dXhigh upper bound for decay rate
#' @param modeltype fitting model 1 or 2
#' @param iter max number of steps to be taken by optimizer
#' @return The function returns a list containing the best fit timeseries, the best fit parameters, and AICc for the model
#' @details 2 simple compartmental ODE models mimicking acute viral infection
#' with T-cells (model 1) or antibodies (model 2) are fitted to data
#' @section Warning: This function does not perform any error checking. So if
#'   you try to do something nonsensical (e.g. specify negative parameter or starting values,
#'   the code will likely abort with an error message
#' @examples
#' # To run the code with default parameters just call this function
#' result <- simulate_basicfitting()
#' # To choose parameter values other than the standard one, specify them e.g. like such
#' result <- simulate_basicfitting(U0 = 1e6, dI = 2, modeltype = 2)
#' @seealso See the shiny app documentation corresponding to this
#' function for more details on this model.
#' @author Andreas Handel
#' @export

simulate_basicfitting <- function(U0 = 1e5, I0 = 0, V0 = 1, X0 = 1, dI = 1, dV = 2, p = 10, k = 1e-6, a = 1e-5, alow = 1e-6, ahigh = 1e-4, b = 1e-5, blow = 1e-6, bhigh = 1e-3, r = 1,  rlow = 0.1, rhigh = 2, dX = 1, dXlow = 0.1, dXhigh = 10, modeltype = 1, iter = 100)
{

  #will contain final result
  output <- list()

  #some settings for ode solver and optimizer
  #those are hardcoded here, could in principle be rewritten to allow user to pass it into function
  atolv=1e-8; rtolv=1e-8; #accuracy settings for the ODE solver routine
  maxsteps = iter #number of steps/iterations for algorithm

  #load data
  #This data is from Hayden et al 1996 JAMA
  #We only use some of the data here
  filename = system.file("extdata", "hayden96data.csv", package = "DSAIRM")
  alldata=read.csv(filename)
  mydata = dplyr::filter(alldata, Condition == 'notx')
  mydata = dplyr::rename(mydata, time = DaysPI, outcome = LogVirusLoad)
  mydata =  dplyr::select(mydata, time, outcome)

  Y0 = c(U = U0, I = I0, V = V0, X = X0);  #combine initial conditions into a vector
  timevec = seq(0, max(mydata$time), 0.1); #vector of times for which solution is returned (not that internal timestep of the integrator is different)

  #combining fixed parameters into a parameter vector
  fixedpars = c(dI=dI,dV=dV,p=p,k=k);

  if (modeltype == 1)
  {
    par_ini = as.numeric(c(a=a, r=r, b=b))
    lb = as.numeric(c(alow, rlow, blow))
    ub = as.numeric(c(ahigh, rhigh, bhigh))
    fitparnames = c('a','r','b')
  }

  if (modeltype == 2)
  {
    par_ini = as.numeric(c(a=a, dX=dX, b=b))
    lb = as.numeric(c(alow, dXlow, blow))
    ub = as.numeric(c(ahigh, dXhigh, bhigh))
    fitparnames = c('a','dX','b')
  }


  #this line runs the simulation, i.e. integrates the differential equations describing the infection process
  #the result is saved in the odeoutput matrix, with the 1st column the time, all other column the model variables
  #in the order they are passed into Y0 (which needs to agree with the order in virusode)
  bestfit = nloptr::nloptr(x0=par_ini, eval_f=fitfunction,lb=lb,ub=ub,opts=list("algorithm"="NLOPT_LN_NELDERMEAD",xtol_rel=1e-10,maxeval=maxsteps,print_level=0), mydata=mydata, Y0 = Y0, timevec = timevec, modeltype=modeltype, fixedpars=fixedpars,fitparnames=fitparnames)


  #extract best fit parameter values and from the result returned by the optimizer
  params = bestfit$solution
  names(params) = fitparnames #for some reason nloptr strips names from parameters
  modelpars = c(params,fixedpars)


  #time-series for best fit model
  if (modeltype == 1)
  {
    odeout <- try(deSolve::ode(y = Y0, times = timevec, func = model1ode, parms=modelpars, atol=1e-8, rtol=1e-8));
  }
  if (modeltype == 2)
  {
    odeout <- try(deSolve::ode(y = Y0, times = timevec, func = model2ode, parms=modelpars, atol=1e-8, rtol=1e-8));
  }

    #compute sum of square residuals (SSR) for initial guess and final solution
  modelpred = odeout[match(mydata$time,odeout[,"time"]),"V"];

  logvirus=c(log10(pmax(1e-10,modelpred)));
  ssrfinal=(sum((logvirus-mydata$outcome)^2))

  #compute AICc
  N=length(mydata$outcome) #number of datapoints
  K=length(par_ini); #fitted parameters for model 1
  AICc=N*log(ssrfinal/N)+2*(K+1)+(2*(K+1)*(K+2))/(N-K)

  #list structure that contains all output
  output$timeseries = odeout
  output$bestpars = params
  output$AICc = AICc
  output$data = mydata
  output$SSR = ssrfinal

  #The output produced by the fitting routine
  return(output)
}