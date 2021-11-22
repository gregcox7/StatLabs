# Inference for paired data {#lab11}



<img src="img/lullaby.png" width="100%" />

In this session, we will use R to conduct inference with *paired* data.  Like in the previous session, we are interested in comparing two sets of numbers.  But because each observation in one set is *paired* with an observation in the other set, the techniques for doing inference amount to the same ones we learned when dealing with just a single set of numbers.  This is because we treat the **difference within a pair** as our object of study.

## Required packages

For this session, we are going to need to load both our standard `tidyverse` package as well as the `infer` package from R's library.


```r
library(tidyverse)
```

```{.Rout .text-info}
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
```

```{.Rout .text-info}
## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
## ✓ tibble  3.1.3     ✓ dplyr   1.0.5
## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
## ✓ readr   2.0.0     ✓ forcats 0.5.1
```

```{.Rout .text-info}
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
library(infer)
```

## Do infants prefer people who sing familiar songs?

Sam Mehr, Lee Ann Song (aptly named), and Liz Spelke [@MehrEtAl2016] were interested in how infants use music as a social cue.  When an infant sees someone for the first time, are they more likely to be attracted to that person if they sing a song that the infant already knows?

@MehrEtAl2016 conducted an experiment in which a child's parents were taught a new melody and were instructed to sing it to their child at home over the course of 1--2 weeks.  After this exposure period, the parents brought their infant back to the lab.  The infant was seated in front of a screen showing videos of two adults the infant had never seen before.  At first, the two adults just smiled in silence.  They recorded the proportion of the time that the infant looked at each stranger during this "before" phase.  Then, one of these people sang the melody that the parents had been singing for 1--2 weeks, while the other sang a totally new song.  Finally, during the "after" phase, the infant saw the same videos of each person silently smiling and the researchers recorded the proportion of the time spent looking at the person who sang the familiar song.  Will infants tend to look more at the stranger who sang the familiar song?

### Check out the data

First, let's get the data into R:


```r
lullaby <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/lullaby_wide.csv")
```

```{.Rout .text-info}
## Rows: 32 Columns: 3
```

```{.Rout .text-info}
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## dbl (3): id, Before, After
```

```{.Rout .text-info}
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

```r
lullaby
```

```{.Rout .text-muted}
## # A tibble: 32 × 3
##       id Before After
##    <dbl>  <dbl> <dbl>
##  1   101  0.437 0.603
##  2   102  0.413 0.683
##  3   103  0.754 0.724
##  4   104  0.439 0.282
##  5   105  0.475 0.499
##  6   106  0.871 0.951
##  7   107  0.237 0.418
##  8   108  0.759 0.938
##  9   109  0.416 0.5  
## 10   110  0.800 0.586
## # … with 22 more rows
```

Have a look at the data by clicking on `lullaby` in RStudio's "Environment" pane.  Each row is data from a specific infant.  There are three variables in this dataset:

* "id": A number identifying each infant in the study.
* "Before": In the phase before the infants heard anyone sing, what proportion of the time did they look at the person who would eventually sing the familiar melody?
* "After": In the phase after the infants heard the two people sing, what proportion of the time did they look at the person who sang the familiar melody?

::: {.exercise}

--

a. If an infant showed no preference during either the Before or After phase, what proportion of the time in that phase would they spend looking at the person who sang the familiar melody?
b. If an infant did not change who they looked at after hearing each person sing, what would the difference in looking proportions be between the Before and After phase?

:::

### Examine the distribution of differences

Our **research question** is whether hearing the two people sing affected infant's viewing preferences.  As a result, we are interested in the **difference** between `After` and `Before`.  To find this for each infant, we will use R's `mutate` function:


```r
lullaby %>%
    mutate(diff = After - Before)
```

```{.Rout .text-muted}
## # A tibble: 32 × 4
##       id Before After    diff
##    <dbl>  <dbl> <dbl>   <dbl>
##  1   101  0.437 0.603  0.166 
##  2   102  0.413 0.683  0.270 
##  3   103  0.754 0.724 -0.0304
##  4   104  0.439 0.282 -0.157 
##  5   105  0.475 0.499  0.0239
##  6   106  0.871 0.951  0.0800
##  7   107  0.237 0.418  0.181 
##  8   108  0.759 0.938  0.179 
##  9   109  0.416 0.5    0.0837
## 10   110  0.800 0.586 -0.213 
## # … with 22 more rows
```

::: {.exercise}

Look at the result when we ran the chunk of code just prior to this exercise.

a. In your own words, describe what the line of code `mutate(diff = After - Before)` did.
b. Refer to the description of the study given above.  What does a positive value of `diff` say about how an infant's looking preferences changed?  What does a negative value of `diff` say about how their preferences changed?

:::

The nice thing about that `mutate` line is that we can add more code after it that uses the `diff` variable we created in that line.  For example, we can make a histogram of the differences in looking time from before to after:


```r
lullaby %>%
    mutate(diff = After - Before) %>%
    ggplot(aes(x = diff)) +
    geom_histogram(binwidth = 0.1)
```

<img src="11-paired_means_files/figure-html/unnamed-chunk-5-1.png" width="672" />

::: {.exercise}

Refer to the histogram we just made of the `diff`erences in looking times from Before to After hearing the people sing.

a. Describe the shape of the distribution (be sure to note the number of modes, skewness, and whether there may be any outliers).
b. Based on the histogram, do these data appear to satisfy the conditions required for using a mathematical model (specifically, the T distribution)?  Why or why not?
c. Based on the histogram, does it seem like the average preference may have changed after hearing the people sing?  If so, in what direction?

:::

### Confidence interval by bootstrapping

To begin, let's use bootstrapping to construct a **confidence interval** for the difference in looking proportion between Before and After.  This confidence interval will describe how much hearing someone sing a familiar melody changes infants' looking preferences.

::: {.exercise}

Fill in the blanks in the code below to construct a **95% confidence interval** for the mean difference in looking proportion from before to after.  Be sure to refer to code from earlier in the session, as well as previous labs, for guidance.  (*Hint:* if you're looking for the name of the response variable, remember that we are doing inference about a *difference*.)


```r
boot_dist <- lullaby %>%
    ___(diff = After - Before) %>%
    specify(response = ___) %>%
    generate(reps = 1000, type = "___") %>%
    calculate(stat = "___")

boot_ci <- boot_dist %>%
    get_confidence_interval(level = ___)

boot_dist %>%
    visualize() +
    shade_confidence_interval(boot_ci)
```

a. What code did you use?
b. Based on the confidence interval you found, is there evidence for a significance difference in looking preferences from before to after hearing the people sing?  Explain your reasoning.

:::

### Hypothesis test via mathematical model

Next, we will use a mathematical model to conduct a hypothesis test.  This hypothesis test will address the **research question**, "is there a difference in infants' average looking behavior from before to after hearing the two strangers sing?"

::: {.exercise}

--

a. What are the null and alternative hypotheses corresponding to our research question?
b. Fill in the blanks in the code below to calculate the **T score** for the observed data.  What code did you use?  (*Hint:* for `mu`, remember the null hypothesis.)


```r
obs_t_diff <- lullaby %>%
    ___(diff = After - Before) %>%
    specify(response = ___) %>%
    hypothesize(null = "point", mu = ___) %>%
    calculate(stat = "t")
```

c. Fill in the blanks in the code below to visualize where the observed T score falls on the null distribution.  Based on the visualization you made, would our observed data be likely or unlikely if the null hypothesis were true?  (*Hint:* for the last blank, check how we have filled it in in previous labs depending on what our alternative hypothesis is.)


```r
null_dist <- lullaby %>%
    ___(diff = After - Before) %>%
    specify(response = ___) %>%
    hypothesize(null = "point", mu = ___) %>%
    assume("t")

null_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_t_diff, direction = "___")
```

d. Fill in the blanks in the code below to get the $p$ value.  What did you get for the $p$ value?


```r
null_dist %>%
    get_p_value(obs_stat = obs_t_diff, direction = "___")
```

e. If we adopt a significance level of 0.05, do we reject the null hypothesis or not?  Why or why not?
f. Give a one-sentence summary of what the outcome of this hypothesis test tells us about how infant looking behavior is affected by hearing someone sing a familiar melody.

:::

## Wrap-up

In this session, we used R to do inference on paired data, where we are typically interested in whether there is a difference within pairs of observations on average.  We used R's `mutate` function to compute the differences within each participant.  We then used bootstrapping to construct a confidence interval and a mathematical model to conduct a hypothesis test.  In the end, we were able to address the question of whether infants respond favorably (by looking more) to a stranger who sings a familiar song, giving us insight into the potential social importance of music.
