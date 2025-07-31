data {
  int<lower=1> N;
  vector[N] y;
  int<lower=1> Nbottle;
  int<lower=1> Nsite;
  int<lower=1> bottle_idx[N];
  int<lower=1> site_idx[N];
  int<lower=1> bottle_site_idx[Nbottle];
}

parameters {
  vector[Nbottle] mu_bottle;
  vector[Nsite] mu_site;
  real log_sigma_tech;
  real log_sigma_biol;
}

model {
  for (i in 1:N){
    y[i] ~ normal(mu_bottle[bottle_idx[i]], exp(log_sigma_tech));
  }
  
  for (j in 1:Nbottle){
    mu_bottle[j] ~ normal(mu_site[bottle_site_idx[j]], exp(log_sigma_biol));
  }
  
  //priors
  mu_bottle ~ normal(0, 10);
  mu_site ~ normal(0, 10);
  log_sigma_tech ~ normal(0, 10); //exponential(1); //gamma(1,5);
  log_sigma_biol ~ normal(0, 10); //exponential(1); //gamma(1,1);
  
}

generated quantities{
  real sigma_tech;
  real sigma_biol;
 
  sigma_tech = exp(log_sigma_tech);
  sigma_biol = exp(log_sigma_biol);
  
}
