library(tidyverse)
library(lme4)
library(rstan)
  options(mc.cores = parallel::detectCores())
library(shinystan)

####simulate some data
######################
  # Create unique bottle identifiers (since bottle 1 in site A ≠ bottle 1 in site B)
  df$bottle_id <- paste(df$site, df$bottle, sep = "_")
  
  # Simulate some data with the nested structure
  set.seed(123)
  site_means <- c(A = 5, B = 6, C = 7)
  for(site in c("A", "B", "C")) {
    bottles_in_site <- unique(df$bottle_id[df$site == site])
    bottle_means <- rnorm(3, mean = site_means[site], sd = 0.5)  # bottle variation
    
    for(i in 1:3) {
      bottle <- bottles_in_site[i]
      df$y[df$bottle_id == bottle] <- rnorm(3, mean = bottle_means[i], sd = 0.2)  # rep variation
    }
  }

    #visualize
    df %>% 
      ggplot(aes(x = bottle_id, y = y, color = site)) +
        geom_point()
    
####The easier way: use a hierarchical (i.e., mixed-effects) model that already exists
###############################################################################    
    
    #our observations, y, are drawn from a normal distribution 
    #with a different mean for each bottle-site combination
    #and a separate site-level effect 
    m1 <- lmer(y ~ 1 +     #a grand mean (intercept)
                 (1 | site/bottle), #and a different offset (intercept) for each bottle, nested within each site
               data = df)
    
    #site-level means:
    intercept <- fixef(m1)["(Intercept)"] #grand mean
    bottle_effects <- ranef(m1)$`bottle:site`[,"(Intercept)"]
    site_effects <- ranef(m1)$`site`[,"(Intercept)"]
    bottle_means <- intercept + bottle_effects
    site_means <- intercept + site_effects
    
    #show standard deviations at each hierarchical level
    VarCorr(m1) #NOTE: here, Residual standard deviation is the SD among technical replicates (within bottle),
    #bottle:site is the SD among bottles within site; site is the SD among sites
    
    #visualize: observations vs predictions
    df %>% 
      mutate(prediction = predict(m1)) %>% 
      ggplot(aes(x = bottle, y = y, color = site)) +
        geom_point() +
        facet_grid(~site) +
        geom_point(aes(x = bottle, y = prediction), color = "black", size = 3)
    
    
        
####The harder way: code your own model from scratch, in a language called stan
###############################################################################    
    #create a list to load the data into stan    
    stanData <- list(
      N = length(df$y),
      y = df$y,  
      Nbottle = length(unique(df$bottle_id)),
      Nsite = length(unique(df$site)),
      bottle_idx = match(df$bottle_id, unique(df$bottle_id)),
      site_idx = match(df$site, unique(df$site)),
      bottle_site_idx = match(df %>% dplyr::select(site, bottle_id) %>% distinct() %>% pull(site),
                              unique(df$site))
    )
    
    # Define the MCMC, and run
    N_CHAIN = 3
    Warm = 1000
    Iter = 3000
    #Treedepth = 12
    #Adapt_delta = 0.80
    
    
    stanMod = stan(file = "mean_means.stan" ,data = stanData,
                   verbose = FALSE, chains = N_CHAIN, thin = 2,
                   warmup = Warm, iter = Warm + Iter,
                   control = list(max_treedepth=Treedepth,
                                  stepsize=0.01,
                                  adapt_delta=Adapt_delta,
                                  metric="diag_e"),
                   refresh = 10,
                   boost_lib = NULL
                   
    )
    
    #plot results
    plot(stanMod, par = "mu_site") #plot the site-level means
    plot(stanMod, par = "mu_bottle") #plot the bottle-level means
    plot(stanMod, par = "sigma_tech") #plot the PCR-level standard deviation (among reactions, within bottles)
    plot(stanMod, par = "sigma_biol") #plot the site-level standard deviation (among bottles, within sites)
    




