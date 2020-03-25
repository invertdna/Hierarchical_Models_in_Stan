# Hierarchical Models in Stan

A set of exercises for my future self and for anyone else who needs to remember (1) how to do hierarchical models, and (2) how to do this in Stan.

This work draws from Richard McElreath's outstanding book Statistical Rethinking (2nd edition, 2020), and uses some associated code he provides on his github site. 

Because Stan is a whole different language (albeit a simple one), there's a learning curve to it, even beyond the normal difficulties of learning to think in distributions. Accordingly, this demonstration uses two different R interfaces for Stan (McElreath's `ulam()` and the Stan project's own `rstanarm`, in addition to the baseline Stan code itself). It compares the inputs and outputs of each of these. 

This demonstration works through two examples: a binomial example (UC Berkeley Admissions) and a linear regression (plant CO2 uptake). The second example is brief, building on the first and just using `rstanarm`. 