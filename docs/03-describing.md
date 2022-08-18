# Describing data {#lab3}



<img src="img/rats.jpg" width="100%" />

This session is divided into two parts.  In the first, we will use R to understand how two measures of *variability* work: the **standard deviation** and its close cousin, the **variance**.  We will see how valuable the computer can be to quickly produce both numerical and visual summaries of data.

But while computers are great at mind*less* computation, that means us people have to be better at mind*ful* stuff.  We need to think about what these numbers mean and why they may be important for understanding the world.

In the second part of the session we will analyze data from an experiment.  We will use both visual and numerical summaries to help draw conclusions about what was going on in the experiment.

## Load the `tidyverse` library

After starting up RStudio, we begin by making sure we've got the `tidyverse` package loaded from R's library.


```r
library(tidyverse)
```

```{.Rout .text-info}
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
```

```{.Rout .text-info}
## ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
## ✔ tibble  3.1.8     ✔ dplyr   1.0.9
## ✔ tidyr   1.1.3     ✔ stringr 1.4.0
## ✔ readr   2.1.2     ✔ forcats 0.5.1
```

```{.Rout .text-info}
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

## Variance and standard deviation

Two important and widely-used numerical summaries of variability are **variance** and **standard deviation**.  Although they have two different names, they are really two ways of looking at the same thing.  The standard deviation is more often used as a summary of variability, although we shall see that variance is useful for other purposes later in this course.

These summaries involve a somewhat long chain of calculations.  It is important to see this chain to understand what these numbers are telling us.  In this part of the session, we will use R to find the variance and standard deviation of some simple simulated data.  First, we will follow that long chain.  Then, we will see how to find these summaries more quickly and efficiently.

### The big picture

A good numerical summary of variability should tell us how much we would expect the observed values of a variable to differ from what is "typical".  This is what "standard deviation" means: it is a summary of the typical ("standard") amount by which observed values of some variable tend to differ ("deviate") from their central tendency.  The variance and standard deviation are based on using the *mean* to describe central tendency.

### Load the data

To see how the variance and standard deviation are calculated, let's create a very small fake data set, which we will creatively call `my_data`.  It contains 5 observations of a single variable called "X".


```r
my_data <- tibble(X = c(91, 102, 107, 109, 111))
```

Although these data are not real, they are similar to what one might observe in a random sample of IQ scores (which have a mean of 100 and standard deviation of 15 in the typical population).

### Step by step

We will now follow the chain of calculations, step by step, that results in finding the variance and then the standard deviation of a set of observed values like we have for the "X" variable in our simulated data.

#### Find the mean

First, we find the mean of the observed values.  R is, in many ways, a fancy calculator.  So we could find the mean of the observed values on the `X` variable by plugging them into the formula for the mean that we already know:


```r
(91 + 102 + 107 + 109 + 111) / 5
```

```{.Rout .text-muted}
## [1] 104
```

While using R as a calculator has its advantages over doing it by hand, the downside is that we still have to type/copy those numbers.  Moreover, if we wanted to use the result for something else (which we will), we'd have to copy that too, and the more we do this, the greater the chances are that we make a mistake.

Rather than typing in the numbers manually, we could instead use R's `mean` function within the "summarize" line we've used before:


```r
my_data %>%
    summarize(mean(X))
```

```{.Rout .text-muted}
## # A tibble: 1 × 1
##   `mean(X)`
##       <dbl>
## 1       104
```

::: {.exercise}
When we've used the "summarize" function in previous sessions, we always preceded it with a `group_by` line.  Say in your own words why we didn't use a `group_by` line to find the mean in the chunk of code we just ran.

:::

#### Find the deviations from the mean

The next step is to find, for each observed value in our data, its **deviation** from the mean.  In mathematical notation, each deviation can be written as $(x_i - \bar{x})$ where $x_i$ is a shorthand for each observed value and $\bar{x}$ is the mean.

In previous sessions, we've used the `mutate` line to transform counts into proportions.  Now we will use it to find the deviations:


```r
my_data %>%
    mutate(deviation = X - mean(X))
```

```{.Rout .text-muted}
## # A tibble: 5 × 2
##       X deviation
##   <dbl>     <dbl>
## 1    91       -13
## 2   102        -2
## 3   107         3
## 4   109         5
## 5   111         7
```

#### Square the deviations

Now that we've found the deviations, we square each of them, again using a `mutate` line:


```r
my_data %>%
    mutate(deviation = X - mean(X)) %>%
    mutate(squared_deviation = deviation^2)
```

```{.Rout .text-muted}
## # A tibble: 5 × 3
##       X deviation squared_deviation
##   <dbl>     <dbl>             <dbl>
## 1    91       -13               169
## 2   102        -2                 4
## 3   107         3                 9
## 4   109         5                25
## 5   111         7                49
```

Note that, in R, the caret symbol `^` is used for exponentiation.

#### Add up the squared deviations

Now, we add up the squared deviations using the `sum` function as part of a `summarize` line:


```r
my_data %>%
    mutate(deviation = X - mean(X)) %>%
    mutate(squared_deviation = deviation^2) %>%
    summarize(sum_squared_deviation = sum(squared_deviation))
```

```{.Rout .text-muted}
## # A tibble: 1 × 1
##   sum_squared_deviation
##                   <dbl>
## 1                   256
```

::: {.exercise}
Modify the chunk of code we just ran to just add up the `deviation`s instead of the `squared_deviation`s.  (*Hint:* think about what variable name to put inside the parentheses after "sum" on the last line.)

a. What is the sum of the deviations?
b. How do you think the sum of the deviations might relate to the idea that the mean is the "balance point" of a distribution of numbers?

:::

#### Variance: Divide by $n - 1$

The **variance** is the sum of squared deviations divided by $n - 1$, where $n$ is the number of observed values, the "sample size".  To get $n$, we can include `n = n()` in the `summarize` line and then use another `mutate` line to get the variance:


```r
my_data %>%
    mutate(deviation = X - mean(X)) %>%
    mutate(squared_deviation = deviation^2) %>%
    summarize(sum_squared_deviation = sum(squared_deviation), n = n()) %>%
    mutate(variance = sum_squared_deviation / (n - 1))
```

```{.Rout .text-muted}
## # A tibble: 1 × 3
##   sum_squared_deviation     n variance
##                   <dbl> <int>    <dbl>
## 1                   256     5       64
```

#### Standard deviation: Take the square root

Finally, we get the **standard deviation** by taking the square root of the variance, which we do with a final `mutate` line.  In R, the `sqrt` function stands for `sq`uare `r`oo`t`.


```r
my_data %>%
    mutate(deviation = X - mean(X)) %>%
    mutate(squared_deviation = deviation^2) %>%
    summarize(sum_squared_deviation = sum(squared_deviation), n = n()) %>%
    mutate(variance = sum_squared_deviation / (n - 1)) %>%
    mutate(standard_deviation = sqrt(variance))
```

```{.Rout .text-muted}
## # A tibble: 1 × 4
##   sum_squared_deviation     n variance standard_deviation
##                   <dbl> <int>    <dbl>              <dbl>
## 1                   256     5       64                  8
```

### All at once

We just saw the complete chain of calculations involved in finding the variance and then the standard deviation.  But as you might have guessed from the fact that R has a `mean` function, it also has functions that directly calculate variances and standard deviations.  These functions are called `var` and `sd`, respectively, and we can use them in a `summary` line, like so:


```r
my_data %>%
    summarize(mean = mean(X), variance = var(X), standard_deviation = sd(X))
```

```{.Rout .text-muted}
## # A tibble: 1 × 3
##    mean variance standard_deviation
##   <dbl>    <dbl>              <dbl>
## 1   104       64                  8
```

The code we just ran is much more compact, readable, and less liable to lead to any typos, so naturally we will use the built-in `var` and `sd` functions pretty often!

::: {.exercise}
Take a look at how we used the `mutate` and `summarize` lines when we were calculating the variance and standard deviation step-by-step.  In your own words, describe a basic difference between what a `mutate` line is used for and what a `summarize` line is used for.

*Hint:* Think about the result we got after adding either a `mutate` or `summarize` line and how it affected the number of rows and/or columns in the result.

:::

## Diet and Lifespan

Having seen how to use R to calculate numerical summaries of central tendency and variability, let's see how they operate in real data.  The data we will be looking at come from a study by @YuEtAl1982.  They studied the lifespan of a sample of rats which were randomly assigned to one of two different diets:  One group of rats was allowed to eat freely, however they wanted; another group was fed on a restricted diet with only about 60% of the calories that the free-eating rats had.

### Load the data

First, we need to get this data into R.  The following code will download and import the data into your current R session:


```r
rats <- read_csv('https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/ratlives.csv')
```

```{.Rout .text-info}
## Rows: 195 Columns: 2── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (1): Diet
## dbl (1): Lifespan
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

In your "Environment" panel in the upper right, you'll see a new entry called "rats".  This is the data we just imported.  Click on it to have a look at the data, which will appear in the upper left.  There are just two variables in this dataset, **Diet** and **Lifespan** (measured in days).  Diet is the explanatory variable and Lifespan is the response variable.

### Summarizing the data visually

Although numerical summaries are useful, they should always be accompanied by visual summaries in order to get a more complete understanding of the data.

#### Histograms

Let's make a facetted histogram that shows the distribution of lifespans of the rats under each diet.  We will use an option under `facet_wrap` that lets us set the `n`umber of `col`umns (`ncol`) so we can see the facets stacked atop one another.


```r
rats %>%
    ggplot(aes(x=Lifespan)) +
    geom_histogram(binwidth=90) +
    facet_wrap("Diet", ncol = 1)
```

<img src="03-describing_files/figure-html/unnamed-chunk-13-1.png" width="672" />

::: {.exercise}
First, let's describe what we can see from the histograms (you may also try out other bin widths for the histograms as you like).

a. Describe the shape of the two distributions.  Be sure to note the number of *modes*, any *skewness*, and whether there may be any *outliers* in either group.
b. Compare the two distributions.  Be sure to note whether there seem to be any differences in *central tendency* or *variability* between the two groups.

:::

#### Boxplots

We've also seen some examples of **boxplots** as useful visual summaries of data.  The "box" of the boxplot encloses the "inter-quartile range" (IQR), that is, the middle 50% of the data that falls between the 25th and 75th percentiles.  The line in the middle of the box shows where the median is.  Boxplots are easy to produce in R by using `geom_boxplot` instead of `geom_histogram`:


```r
rats %>%
    ggplot(aes(x=Lifespan, y=Diet)) +
    geom_boxplot()
```

<img src="03-describing_files/figure-html/unnamed-chunk-14-1.png" width="672" />

::: {.exercise}
Compare the boxplots and histograms we just made.

a. What sorts of things seem easier to do with the boxplots as opposed to histograms?  Think about what features of the data might be easier to see with a boxplot and what comparisons might be easier to make using a boxplot.
b. Do you lose anything by using a boxplot instead of a histogram?  Are there any important features of the data that are harder to see in the boxplot?

:::

### Summarizing the data numerically

Finally, let's use R to get a numerical summary of the lifespans of the rats under the two diets.  In the first part of the session, we focused on the *mean* and *standard deviation* (and *variance*), but we have also seen that the *median* and *inter-quartile range* (IQR) can also be used as numerical summaries of central tendency and variability.

R can find the median and IQR for us:


```r
rats %>%
    group_by(Diet) %>%
    summarize(Median = median(Lifespan), IQR = IQR(Lifespan))
```

```{.Rout .text-muted}
## # A tibble: 2 × 3
##   Diet       Median   IQR
##   <chr>       <dbl> <dbl>
## 1 Free         710   116 
## 2 Restricted  1036.  300.
```

::: {.exercise}
Fill in the blanks in the following chunk of code to find the mean and standard deviation of the lifespans of the rats under each diet.  *Hint:* recall the names of the functions we used to find these quantities earlier.


```r
___ %>%
    group_by(___) %>%
    ___(Mean = ___, SD = ___)
```

a. What code did you use?
b. Compare the means and standard deviations for each group of rats to the histograms we made earlier.  How are the differences in mean lifespan between groups reflected in the two histograms?  How are the differences in the standard deviation of lifespan reflected in the two histograms?

:::

These numerical summaries of central tendency and variability provide a concise description of the lifespans of rats under the two different diets.  These descriptions help us address the **research question**: does a restricted diet have an effect on lifespan?

::: {.exercise}
Based on the visual and numerical summaries we have made, let us draw some conclusions about that research question.

a. Briefly describe the differences in lifespans between rats under a restricted diet versus rats with a free diet.
b. Based on the design of the study, can we conclude that the differences in diet probably played a role in *causing* the observed differences in lifespan in this sample?  Why or why not?
c. What is the population to which you think we could *generalize* these results?

:::

## Wrap-up

In this session, we saw how to find two important numerical summaries of variability: **variance** and **standard deviation**.  We analyzed data from an experiment studying the relationship between diet and lifespan in a sample of rats, using both visual and numerical summaries to get a more complete picture of the relationships between explanatory and response variables.
