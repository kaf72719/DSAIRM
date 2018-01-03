############################################################
##a simple model for a simple bacteria infection model, implemented as discrete time model
##written by Andreas Handel (ahandel@uga.edu), last change 12/6/17
############################################################


#' Simulation of a basic model with bacteria and an immune response
#' illustrating a simple within-host predator-prey model
#'
#' @description This function runs a simulation of a basic 2 compartment model
#' using discrete time steps
#' The user provides initial conditions and parameter values for the system.
#' The function simulates the model by advancing from start to end time in discrete time steps
#' The function returns a matrix containing time-series of each variable and time.
#'
#' @param B0 initial number of bacteria
#' @param I0 initial number/strength of immune response
#' @param g rate of bacteria growth
#' @param Bmax carrying capacity for bacteria
#' @param dB death rate of bacteria
#' @param k rate at which bacteria are killed by immune response
#' @param r rate at which immune response is induced by bacteria
#' @param dI death rate of immune response
#'
#' @param tmax maximum simulation time, units depend on choice of units for your
#'   parameters
#' @param dt time step for simulation, units depend on choice of units for your
#'   parameters
#' @return The function returns the output as a matrix,
#' with one column per compartment/variable. The first column is time.
#' @details A simple 2 compartment model is simulated as a discrete time model.
#' @section Warning: This function does not perform any error checking. So if
#'   you try to do something nonsensical (e.g. specify negative parameter values
#'   or fractions > 1), the code will likely abort with an error message
#' @examples
#' # To run the simulation with default parameters just call this function
#' result <- simulate_basicbacteria_discrete()
#' # To choose parameter values other than the standard one, specify them e.g. like such
#' result <- simulate_basicbacteria_discrete(B0 = 100, I0 = 10, tmax = 100, g = 10)
#' # You should then use the simulation result returned from the function, e.g. like this:
#' plot(result[,1],result[,2],xlab='Time',ylab='Bacteria Number',type='l')
#' @seealso See the shiny app documentation that uses this simulator
#' function for more details on this model.
#' @author Andreas Handel
#' @export

simulate_basicbacteria_discrete <- function(B0 = 10, I0 = 1, tmax = 30, g=1, Bmax=1e6, dB=1e-1, k=1e-7, r=1e-3, dI=1, dt=0.01)
{
  #vector of times for which solution is returned (not that internal timestep of the integrator is different)
  timevec = seq(0, tmax, dt);

  #data frame to store results
  result=data.frame(time = timevec, B = rep(0,length(timevec)), I = rep(0,length(timevec)))

  #this loop simulates the model
  ct=1; #a counter to index matrix
  B=B0; I=I0;
  result[ct,]=c(0,B,I) #starting values
  for (t in timevec)
  {
    Bp = B + dt*(g*B*(1-B/Bmax)- dB*B - k*B*I) #compute the changes in bacteria numbers
    Ip = I + dt*(r*B*I-dI*I) #compute the changes for the immune response
    ct=ct+1 #advance counter
    result[ct,]=c(t,Bp,Ip) #save results
    B = Bp; I = Ip; #assign new values to old ones to update system
  }

  #The output is a matrix returned by the function
  return(as.matrix(result))
}