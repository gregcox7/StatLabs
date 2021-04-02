# (APPENDIX) Appendix {-}

# R Code Reference {#coderef}



## Binomial distribution

For the following examples, I am using the following labeled values so you can see the kind of result R will give you.


```r
this_prob <- 0.3
this_size <- 10

given_value <- 5

upper_value <- 9
lower_value <- 3

given_probability <- 0.2
```

To use these bits of code yourself, just replace the label with the appropriate number or assign a new value under the same label (e.g., `this_prob <- 0.941`).

### Probability of observing an outcome exactly equal to a given value


```r
dbinom(x = given_value, prob = this_prob, size = this_size)
```

```
## [1] 0.1029193
```

### Probability of observing a value less than or equal to a given value


```r
pbinom(q = given_value, prob = this_prob, size = this_size)
```

```
## [1] 0.952651
```

### Probability of observing a value greater than a given value


```r
1 - pbinom(q = given_value, prob = this_prob, size = this_size)
```

```
## [1] 0.04734899
```

### Probability of observing a value inside an interval between an upper and lower value


```r
pbinom(q = upper_value, prob = this_prob, size = this_size) - pbinom(q = lower_value, prob = this_prob, size = this_size)
```

```
## [1] 0.3503834
```

### Probability of observing a value outside an interval between an upper and lower value


```r
1 - (pbinom(q = upper_value, prob = this_prob, size = this_size) - pbinom(q = lower_value, prob = this_prob, size = this_size))
```

```
## [1] 0.6496166
```

or


```r
1 - pbinom(q = upper_value, prob = this_prob, size = this_size) + pbinom(q = lower_value, prob = this_prob, size = this_size)
```

```
## [1] 0.6496166
```

### The value for which there is a given probability of observing an outcome less than or equal to that value


```r
qbinom(p = given_probability, prob = this_prob, size = this_size)
```

```
## [1] 2
```

## Normal distribution

For the following examples, I am using the following labeled values so you can see the kind of result R will give you.


```r
this_mean <- 0
this_sd <- 1

given_value <- 1.5

upper_value <- 2
lower_value <- -1

given_probability <- 0.2
```

To use these bits of code yourself, just replace the label with the appropriate number or assign a new value under the same label (e.g., `this_mean <- -4`).

### Probability of observing a value less than or equal to a given value


```r
pnorm(q = given_value, mean = this_mean, sd = this_sd)
```

```
## [1] 0.9331928
```

### Probability of observing a value greater than a given value


```r
1 - pnorm(q = given_value, mean = this_mean, sd = this_sd)
```

```
## [1] 0.0668072
```

### Probability of observing a value inside an interval between an upper and lower value


```r
pnorm(q = upper_value, mean = this_mean, sd = this_sd) - pnorm(q = lower_value, mean = this_mean, sd = this_sd)
```

```
## [1] 0.8185946
```

### Probability of observing a value outside an interval between an upper and lower value


```r
1 - (pnorm(q = upper_value, mean = this_mean, sd = this_sd) - pnorm(q = lower_value, mean = this_mean, sd = this_sd))
```

```
## [1] 0.1814054
```

or


```r
1 - pnorm(q = upper_value, mean = this_mean, sd = this_sd) + pnorm(q = lower_value, mean = this_mean, sd = this_sd)
```

```
## [1] 0.1814054
```


### The value for which there is a given probability of observing an outcome less than or equal to that value


```r
qnorm(p = given_probability, mean = this_mean, sd = this_sd)
```

```
## [1] -0.8416212
```
