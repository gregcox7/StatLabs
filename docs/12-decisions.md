# Decisions {#lab12}






```r
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
```

```
## ✓ ggplot2 3.3.3     ✓ purrr   0.3.4
## ✓ tibble  3.1.1     ✓ dplyr   1.0.5
## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
## ✓ readr   1.4.0     ✓ forcats 0.5.1
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(infer)
library(magrittr)
```

```
## 
## Attaching package: 'magrittr'
```

```
## The following object is masked from 'package:purrr':
## 
##     set_names
```

```
## The following object is masked from 'package:tidyr':
## 
##     extract
```

## Time

Imagine that you start a new job and have two options for your commute.  Route A takes side roads while Route B uses a highway that also has a toll.  Of course, regardless of which route you take, your commute time would never be exactly the same from day to day due to traffic, weather conditions, stop lights, and the many other factors over which we have no control.  So how would you decide which route to take?  What factors would you need to consider?

### Estimate the time for each commute

First, you'll need to figure out how long each commute takes.  To do this, you alternate every other day between taking Route A and Route B and record how long your commute took on each day.  You do this for 20 days, so you have 10 observations for each route.

Because this is just hypothetical, let's simulate the outcomes on each day.  Assume that the commute times for Route A are normally distributed with a mean of 25 minutes and a standard deviation of 4 minutes.  The commute times for Route B are also normally distributed, but with a mean of 20 minutes and a standard deviation of 5 minutes.  The table below summarizes the mean and standard deviation of the commute times for each route:

Route          | `mean` | `sd`
---------------|--------|------
A (side roads) | 25     | 4
B (toll road)  | 20     | 5

Given this information, let's simulate your commute times for 10 days using each route:


```r
simulated_commutes <- rbind(
    tibble(route = "A", time = rnorm(n = 10, mean = 25, sd = 4)),
    tibble(route = "B", time = rnorm(n = 10, mean = 20, sd = 5))
)
```

How does the code above work?  Remember that `tibble`s are how R stores data.  We created two `tibble`s: On line 2, we made one for the commute times for Route A and on line 3, we did it for Route B.  Each `tibble` has a column that says which route it was and a column for the time taken, which we simulated using `rnorm`.  We used `rbind` to *bind* the two `tibble`s together into a single dataset and told R to remember that data under the name `simulated_commutes`.

What does the result look like?  Something like this:


```r
simulated_commutes
```

```
## # A tibble: 20 x 2
##    route  time
##    <chr> <dbl>
##  1 A     21.8 
##  2 A     22.9 
##  3 A     15.5 
##  4 A     22.0 
##  5 A     23.3 
##  6 A     22.7 
##  7 A     29.1 
##  8 A     30.0 
##  9 A     24.9 
## 10 A     29.6 
## 11 B      9.73
## 12 B     15.4 
## 13 B     14.1 
## 14 B     19.2 
## 15 B     23.6 
## 16 B     15.6 
## 17 B     19.4 
## 18 B     20.6 
## 19 B     19.3 
## 20 B     17.8
```

We can use code we've used before to summarize the mean and standard deviation of the simulated commute times for each route:

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:unnamed-chunk-5"><strong>(\#exr:unnamed-chunk-5) </strong></span>Fill in the blanks in the code below to produce something similar to the summary table shown.  What code did you use?  (Hint: What is the name of our dataset and what are the names of the variables in our simulated commute data?)  Note that the numbers in your summary table won't be the same as those shown here because your simulations would turn out exactly the same as these.
</div>\EndKnitrBlock{exercise}


```r
___ %>%
    group_by(___) %>%
    summarize(M = mean(___), SD = sd(___))
```


```
## # A tibble: 2 x 3
##   route     M    SD
##   <chr> <dbl> <dbl>
## 1 A      24.2  4.44
## 2 B      17.5  3.90
```

### Do a hypothesis test?

Now that we have a sample of commute times on each route, one thing we could do is test the null hypothesis that they take the same amount of time.  This would address the **research question**, do the two routes differ in how long they take?  The specific method we would need is the **independent samples $t$ test**.  As we've seen, we can do $t$ tests in R in a pretty compact way.

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:unnamed-chunk-8"><strong>(\#exr:unnamed-chunk-8) </strong></span>Fill in the blanks in the code below to produce an output similar to what is shown below.  The output will not match exactly because your simulations will probably not be identical to the ones shown here.  What was the final chunk of code you used?  (Hint: What is the name of the dataset and what are the explanatory and response variables?)
</div>\EndKnitrBlock{exercise}


```r
___ %>%
    t_test(
        ___ ~ ___,
        alternative = "two-sided",
        mu = 0,
        var.equal = FALSE,
        conf_level = 0.95
    )
```


```
## Warning: The statistic is based on a difference or ratio; by default, for
## difference-based statistics, the explanatory variable is subtracted in the order
## "A" - "B", or divided in the order "A" / "B" for ratio-based statistics. To
## specify this order yourself, supply `order = c("A", "B")`.
```

```
## # A tibble: 1 x 6
##   statistic  t_df p_value alternative lower_ci upper_ci
##       <dbl> <dbl>   <dbl> <chr>          <dbl>    <dbl>
## 1      3.59  17.7 0.00216 two.sided       2.77     10.6
```

But does this hypothesis test really address the question that we care about?  Remember that Route B uses a toll road, so it is costing us money.  What we really want to know is, *is Route B fast enough to be worth paying the toll?*

### Quantifying costs

To answer that question, we need to know two things:

1. How much is the toll?
2. How valuable is our time?

Let's say the toll is \$2.  Imagine that we get a bonus for showing up early to work, so each minute we spend commuting is actually costing us \$0.25.

Then we can assign, for each commute, a cost in terms of dollars.  For both routes, there is a cost of time, which will be `time * 0.25` (i.e., the number of minutes times the cost per minute).  There is an additional cost of 2 for Route B, corresponding to the toll.

Using this information, we can create a new variable "cost" using the `mutate` function in R:


```r
simulated_commutes %>%
    mutate(cost = (route == "B") * 2 + time * 0.25)
```

```
## # A tibble: 20 x 3
##    route  time  cost
##    <chr> <dbl> <dbl>
##  1 A     21.8   5.44
##  2 A     22.9   5.73
##  3 A     15.5   3.88
##  4 A     22.0   5.51
##  5 A     23.3   5.83
##  6 A     22.7   5.67
##  7 A     29.1   7.27
##  8 A     30.0   7.50
##  9 A     24.9   6.23
## 10 A     29.6   7.40
## 11 B      9.73  4.43
## 12 B     15.4   5.85
## 13 B     14.1   5.53
## 14 B     19.2   6.79
## 15 B     23.6   7.91
## 16 B     15.6   5.91
## 17 B     19.4   6.84
## 18 B     20.6   7.16
## 19 B     19.3   6.82
## 20 B     17.8   6.44
```

The `(route == "B")` part in the second line says whether or not the route is the one with the toll (B) or not (A); this is then multiplied by the cost of the toll (`* 2`).  To see how that bit of code works, let's try removing it and see what the effect is:


```r
simulated_commutes %>%
    mutate(cost = time * 0.25)
```

```
## # A tibble: 20 x 3
##    route  time  cost
##    <chr> <dbl> <dbl>
##  1 A     21.8   5.44
##  2 A     22.9   5.73
##  3 A     15.5   3.88
##  4 A     22.0   5.51
##  5 A     23.3   5.83
##  6 A     22.7   5.67
##  7 A     29.1   7.27
##  8 A     30.0   7.50
##  9 A     24.9   6.23
## 10 A     29.6   7.40
## 11 B      9.73  2.43
## 12 B     15.4   3.85
## 13 B     14.1   3.53
## 14 B     19.2   4.79
## 15 B     23.6   5.91
## 16 B     15.6   3.91
## 17 B     19.4   4.84
## 18 B     20.6   5.16
## 19 B     19.3   4.82
## 20 B     17.8   4.44
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:unnamed-chunk-13"><strong>(\#exr:unnamed-chunk-13) </strong></span>Compare the numbers in the "cost" column when we include the `(route == "B") * 2` part versus when we don't.  Which costs are different?
</div>\EndKnitrBlock{exercise}

### Picking the cheapest route

Now that we can assign a cost to each commute, which of the two routes is cheaper?  This is more complicated than just asking, "which is faster."  Although we know that Route B is faster, because it has a toll, we don't know if it is actually more cost-effective.

Just like we summarized the mean and SD of the commute times, we can now summarize the mean and SD of the commute *costs*:

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:unnamed-chunk-14"><strong>(\#exr:unnamed-chunk-14) </strong></span>Fill in the blanks in the code below to produce something similar to the summary table shown.  What code did you use?  (Hint: What is the name of the new variable we are summarizing?)  Does one route seem to have a much higher cost than the other, or do they look similar?  Note that the numbers in your summary table won't be the same as those shown here because your simulations won't turn out exactly the same as these.
</div>\EndKnitrBlock{exercise}


```r
simulated_commutes %>%
    mutate(cost = (route == "B") * 2 + time * 0.25) %>%
    group_by(___) %>%
    summarize(M = mean(___), SD = sd(___))
```


```
## # A tibble: 2 x 3
##   route     M    SD
##   <chr> <dbl> <dbl>
## 1 A      6.05 1.11 
## 2 B      6.37 0.975
```


```r
simulated_commutes %>%
    mutate(cost = (route == "B") * 2 + time * 0.25) %>%
    t_test(
        cost ~ route,
        alternative = "two-sided",
        mu = 0,
        var.equal = FALSE,
        conf_level = 0.95
    )
```

```
## Warning: The statistic is based on a difference or ratio; by default, for
## difference-based statistics, the explanatory variable is subtracted in the order
## "A" - "B", or divided in the order "A" / "B" for ratio-based statistics. To
## specify this order yourself, supply `order = c("A", "B")`.
```

```
## # A tibble: 1 x 6
##   statistic  t_df p_value alternative lower_ci upper_ci
##       <dbl> <dbl>   <dbl> <chr>          <dbl>    <dbl>
## 1    -0.691  17.7   0.498 two.sided      -1.31    0.660
```

What would the population look like without the intervention?

What would the population look like with the intervention?

What is the cost of the new policy?

## Wrap-up

