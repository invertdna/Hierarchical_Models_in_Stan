data{
    int reject[12];          //setting up the input data, so Stan knows what to expect. here, integer vector called `reject`, which is 12 values long. The other parts of the data block are the same.
    int applications[12];
    int admit[12];
    int male[12];
    int dept[12];
}
parameters{
    vector[6] a;             //similarly, expressly setting up the model parameters to estimate
    real abar;
    real<lower=0> sigma;
    real b;
}
model{
    vector[12] p;
    b ~ normal( 0 , 1 );       //prior for the slope
    sigma ~ normal( 0 , 1 );   //prior for the variance of distrib for intercepts. Note that a variance can't be zero, and so here a half-normal distribution is specified by constraining the parameter sigma (in the `parameters` block) not to go below zero.
    abar ~ normal( 0 , 4 );    //prior for the mean of distrib for intercepts
    a ~ normal( abar , sigma );  //prior for the distribution of intercepts
    for ( i in 1:12 ) {     // for each set of observations, use a and b to estimate probability of admission
        p[i] = a[dept[i]] + b * male[i];
        p[i] = inv_logit(p[i]);
    }
    admit ~ binomial( applications , p );  //finally, infer probability of admission, given data
}

