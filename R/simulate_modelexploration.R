############################################################
##this code illustrates how to do analyze a simple model
#it runs the simple bacterial infection model for a range of parameters
#for each parameter outcomes are reported
##the resulting plots are x-y plots with a parameter of interested varied
#and the change in outcome plotted
##written by Andreas Handel (ahandel@uga.edu), last change 1/16/18
############################################################

#' Simulation to illustrate a simple use of a simple model
#'
#'
#' @description This function simulates the simple bacteria model for a range of parameters.
#' The function returns a data frame containing the parameter that has been varied and the outcomes (see details).
#'
#' @param B0 initial number of bacteria
#' @param I0 initial number/strength of immune response
#' @param g rate of bacteria growth
#' @param Bmax carrying capacity for bacteria
#' @param dB death rate of bacteria
#' @param k rate at which bacteria are killed by immune response
#' @param r rate at which immune response is induced by bacteria
#' @param dI death rate of immune response
#' @param samplepar name of parameter to be varied
#' @param pmin lower value for varied parameter
#' @param pmax upper value for varied parameter
#' @param samples number of values to run between pmin and pmax
#' @param pardist spacing of parameter values, can be either 'lin' or 'log'
#' @param tmax maximum simulation time, units depend on choice of units for your
#'   parameters
#' @return The function returns the output as a list,
#' list element 'dat' contains the data frame with results of interest.
#' The first column is called xvals and contains the values of the
#' parameter that has been varied as specified by 'samplepar'.
#' The remaining columns contain peak and steady state values of bacteria and immune response,
#' Bpeak, Ipeak, Bsteady and Isteady.
#' A final boolean variable 'nosteady' is returned for each simulation.
#' It is TRUE if the simulation did not reach steady state, otherwise FALSE.
#' @details A simple 2 compartment ODE model (the simple bacteria model introduced in the app of that name)
#' is simulated for different parameter values.
#' The user can specify which parameter is sampled, and
#' the simulation returns for each parameter sample the peak and final value for B and I.
#' Also returned is the varied parameter and an indicator if steady state was reached.
#' @section Warning: This function does not perform any error checking. So if
#'   you try to do something nonsensical (e.g. specify negative parameter values
#'   or fractions > 1), the code will likely abort with an error message.
#' @examples
#' # To run the simulation with default parameters just call the function:
#' res <- simulate_modelexploration()
#' # To choose parameter values other than the standard one, specify them, like such:
#' res <- simulate_modelexploration(dI = 0.1, r = 10, tmax = 100)
#' # You should then use the simulation result returned from the function, like this:
#' plot(res$dat[,"xvals"],res$data[,"Bpeak"],xlab='Parameter values',ylab='Peak Bacteria',type='l')
#' @seealso See the shiny app documentation corresponding to this simulator
#' function for more details on this model.
#' @author Andreas Handel
#' @export


simulate_modelexploration <- function(B0 = 10, I0 = 1, tmax = 30, g=1, Bmax=1e6, dB=1e-1, k=1e-7, r=1e-3, dI=1, samplepar='k', pmin=1e-8, pmax=1e-5, samples = 10, pardist = 'lin')
  {


    #initialize vectors that will contain the outcomes of interest
    Bpeak=rep(0,samples)
    Ipeak=rep(0,samples)
    Bsteady=rep(0,samples)
    Isteady=rep(0,samples)

    #create values for the parameter of interest to sample over
    #do equal spacing in log space
    if (pardist == 'lin') {parvec=seq(pmin,pmax,length=samples)}
    if (pardist == 'log') {parvec=10^seq(log10(pmin),log10(pmax),length=samples)}


    nosteady = rep(FALSE,samples) #indicates if steady state has not been reached
    for (n in 1:samples)
    {
        #replace value of parameter we want to vary
        if (samplepar == 'g') {g = parvec[n]}
        if (samplepar == 'Bmax') {Bmax = parvec[n]}
        if (samplepar == 'dB') {dB = parvec[n]}
        if (samplepar == 'k') {k = parvec[n]}
        if (samplepar == 'r') {r = parvec[n]}
        if (samplepar == 'dI') {dI = parvec[n]}

        #this runs the bacteria ODE model for each parameter sample
        #all other parameters remain fixed
        odeout <- simulate_basicbacteria(B0 = B0, I0 = I0, tmax = tmax, g=g, Bmax=Bmax, dB=dB, k=k, r=r, dI=dI)

        timeseries = odeout$ts

        Bpeak[n]=max(timeseries[,"Bc"]); #get the peak for B
        Ipeak[n]=max(timeseries[,"Ic"]);
        Bsteady[n] = utils::tail(timeseries[,"Bc"],1)
        Isteady[n] = utils::tail(timeseries[,"Ic"],1)

        #a quick check to make sure the system is at steady state,
        #i.e. the value for B at the final time is not more than
        #1% different than B several time steps earlier
        vl=nrow(timeseries);
        if ((abs(timeseries[vl,"Bc"]-timeseries[vl-10,"Bc"])/timeseries[vl,"Bc"])>1e-2)
        {
          nosteady[n] = TRUE
        }
    }

    result = list()
    dat = data.frame(xvals = parvec, Bpeak = Bpeak, Ipeak=Ipeak, Bsteady = Bsteady, Isteady = Isteady, nosteady = nosteady)
    result$dat = dat
    return(result)
}
