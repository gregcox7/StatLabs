# Inference for a single mean {#lab9}



<img src="img/memory-tray.jpg" width="100%" />

In this session, we will learn about doing inference when the response variable is *numerical* rather than *categorical*.  Specifically, we will focus on how we can use data to draw inferences about what a population average might be, based on a sample.  This is very similar to how we have been drawing inferences about a population proportion.  As we shall see, simulation methods like bootstrapping work just the same with a numerical response variable as they do with a categorical response variable.  Where they differ is that the mathematical model for proportions is a *normal* distribution whereas the mathematical model for means is a **T distribution**.

## Required packages

Make sure you have loaded both the `tidyverse` and `infer` packages from R's library:


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

```r
library(infer)
```

## Inference with NHANES

To begin, we will take another look at two variables from the NHANES dataset that we already looked at in a [previous lab](#lab7).  Load it now:


```r
nhanes <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/nhanes.csv")
```

```{.Rout .text-info}
## Rows: 4924 Columns: 76── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (31): SurveyYr, Gender, AgeDecade, Race1, Race3, Education, MaritalStatu...
## dbl (41): ID, Age, AgeMonths, HHIncomeMid, Poverty, HomeRooms, Weight, Heigh...
## lgl  (4): Length, HeadCirc, TVHrsDayChild, CompHrsDayChild
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Remember that the variable `DaysMentHlthBad` represents the number of days, out of the past 30, that a person says their mental health was poor.  We saw already that the distribution of observed values of this variable is *not* well described by a normal curve, as we can see in the histogram below:


```r
nhanes %>%
    ggplot(aes(x = DaysMentHlthBad)) +
    geom_histogram(binwidth = 1)
```

<img src="09-single_mean_files/figure-html/unnamed-chunk-4-1.png" width="672" />

Nonetheless, we know from the *central limit theorem* that, even though the distribution of the original data is not normal, the *distribution of sample means* will tend to look something like a normal distribution.

### Bootstrapping

We can construct the distribution of sample means using **bootstrapping**.  Run the following code to build this sampling distribution and save it under the name `boot_dist_mental_health`.


```r
boot_dist_mental_health <- nhanes %>%
    specify(response = DaysMentHlthBad) %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "mean")

boot_dist_mental_health
```

```{.Rout .text-muted}
## Response: DaysMentHlthBad (numeric)
## # A tibble: 1,000 × 2
##    replicate  stat
##        <int> <dbl>
##  1         1  4.49
##  2         2  4.45
##  3         3  4.42
##  4         4  4.69
##  5         5  4.33
##  6         6  4.38
##  7         7  4.38
##  8         8  4.35
##  9         9  4.33
## 10        10  4.62
## # … with 990 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

::: {.exercise}

The following chunk of code would use bootstrapping to construct a sampling distribution for the proportion of people who have tried marijuana:


```r
boot_dist_marijuana <- nhanes %>%
    specify(response = Marijuana, success = "Yes") %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "prop")
```

Compare this chunk of code with the first four lines of the code just prior to this exercise that we used to build a sampling distribution for the mean number of bad mental health days.  For each of the four lines, what is similar and what is different?  For any difference, describe why you think there is a difference.

:::

Let's visualize the sampling distribution for the mean number of poor mental health days:


```r
boot_dist_mental_health %>%
    visualize()
```

<img src="09-single_mean_files/figure-html/unnamed-chunk-7-1.png" width="672" />

### Standard error of the mean

If we find the standard deviation of this sampling distribution, we will get an estimate of the **standard error of the mean**:


```r
boot_dist_mental_health %>%
    summarize(standard_error = sd(stat))
```

```{.Rout .text-muted}
## # A tibble: 1 × 1
##   standard_error
##            <dbl>
## 1          0.115
```

We can also estimate the standard error of the mean by using the mathematical model approach based on the central limit theorem.  According to this approach, the standard error is

$$
SE = \frac{s}{\sqrt{n}}
$$

where $s$ is the sample standard deviation and $n$ is the sample size.

::: {.exercise}

Fill in the blanks in the code below to use R to calculate what the standard error is, based on the mathematical model.  (Hint: the blanks will be the *names* of numbers calculated earlier in the chunk.)


```r
sample_sd <- nhanes %>%
    summarize(sd(DaysMentHlthBad)) %>%
    pull()

sample_size <- nhanes %>%
    summarize(n()) %>%
    pull()

standard_error <- ___ / sqrt(___)

standard_error
```



a. What did you get for the `standard_error`?
b. Compare the value in part (a) to what you found just before this exercise by calculating the standard deviation of the bootstrap distribution.  Are the values similar or different?  Describe why you would expect the two values to be similar or different.

:::

### Confidence intervals

Suppose we want to construct a **95% confidence interval** for the population mean, based on our sample.  We've already seen how to do this with a bootstrap distribution:


```r
boot_ci_mental_health <- boot_dist_mental_health %>%
    get_confidence_interval(level = 0.95)

boot_ci_mental_health
```

```{.Rout .text-muted}
## # A tibble: 1 × 2
##   lower_ci upper_ci
##      <dbl>    <dbl>
## 1     4.26     4.71
```

To do the same using a mathematical model, we use this formula that we've seen before:

$$
\bar{x} \pm t^{\star}_{df} \times SE
$$

We already found the standard error ($SE$).  Next, we need to find $t^{\star}_{df}$, the "critical value" on the T distribution that divides the middle 95% of the distribution from its upper and lower tails.  R's `qt` function will help us do this, but as you'll recall, the T distribution has a different shape depending on the number of **degrees of freedom** ($df$).  When working with just a single sample, the degrees of freedom is one less than the sample size:

$$
df = n - 1
$$

Luckily, we already told R to remember the sample size during the previous exercise, so we can find the number of degrees of freedom:


```r
degrees_of_freedom <- sample_size - 1

degrees_of_freedom
```

```{.Rout .text-muted}
## [1] 4923
```

Now, we can use the `qt` distribution to find which `q`uantile of the T distribution represents the upper tail of our confidence interval.  We set `p = 0.975` because we want to find the point at which 2.5% (or 0.025) of the distribution is *above* this quantile, so 97.5% will have to be *below* it.  The resulting quantile is our critical t value:


```r
critical_t <- qt(p = 0.975, df = degrees_of_freedom)

critical_t
```

```{.Rout .text-muted}
## [1] 1.960446
```

Finally, the last ingredient we need for a confidence interval is the sample mean ($\bar{x}$):


```r
sample_mean <- nhanes %>%
    summarize(mean(DaysMentHlthBad)) %>%
    pull()

sample_mean
```

```{.Rout .text-muted}
## [1] 4.48355
```

::: {.exercise}

Fill in the blanks below to find the 95% confidence interval according to the T distribution.  *Hint:* your best bet is to fill the blanks with *names* of numbers calculated from running the code chunks before this exercise.  Consider the formula for the confidence interval given above.  Also, remember that `*` in R does multiplication.


```r
ci_lower <- ___ - ___ * ___
ci_upper <- ___ + ___ * ___

c(ci_lower, ci_upper)
```

a. What code did you use?
b. What was the interval you got?
c. Is the resulting confidence interval similar or different to the one we found earlier using the bootstrap distribution?
d. Interpret the confidence interval in the context of the research scenario.

:::

### Hypothesis testing

Consider that, over the course of the past 30 days, having more than 4 days of poor mental health would be equivalent to having roughly one bad mental health day per week.  While we don't know from people's responses to the question whether their bad days all occurred together or spread out, it is reasonable to ask the **research question**, "do Americans on average have more than four bad mental health days per month?"

This is a question we can address via a hypothesis test.  The **null hypothesis** is that the average number of bad mental health days per month is less than or equal to 4.  The **alternative hypothesis** is that the average number of bad mental health days per month is more than 4.

#### By simulation

One way to conduct this hypothesis test is to use bootstrapping to simulate what our data would look like if the null hypothesis were true.  This will construct a sampling distribution under the assumption that the true average in the population is 4 bad days per month.  We will then see where the mean from our data falls on this distribution to find a $p$ value and decide whether or not to reject the null hypothesis.

The code below constructs sampling distribution under the assumption that the true average in the population is 4 bad days per month:


```r
null_dist_mental_health <- nhanes %>%
    specify(response = DaysMentHlthBad) %>%
    hypothesize(null = "point", mu = 4) %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "mean")

null_dist_mental_health
```

```{.Rout .text-muted}
## Response: DaysMentHlthBad (numeric)
## Null Hypothesis: point
## # A tibble: 1,000 × 2
##    replicate  stat
##        <int> <dbl>
##  1         1  3.93
##  2         2  4.16
##  3         3  4.14
##  4         4  4.02
##  5         5  3.91
##  6         6  3.93
##  7         7  4.23
##  8         8  4.13
##  9         9  4.07
## 10        10  3.95
## # … with 990 more rows
## # ℹ Use `print(n = ...)` to see more rows
```

::: {.exercise}

The chunk of code to build a sampling distribution for a confidence interval (that we used above) was


```r
boot_dist_mental_health <- nhanes %>%
    specify(response = DaysMentHlthBad) %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "mean")
```

Compare this to the code we just ran to build a sampling distribution for a hypothesis test:


```r
null_dist_mental_health <- nhanes %>%
    specify(response = DaysMentHlthBad) %>%
    hypothesize(null = "point", mu = 4) %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "mean")
```

a. What is similar and what is different between the two chunks of code above?  For any difference you find, describe why you think that difference is there.
b. In the second chunk of code we used the line `hypothesize(null = "point", mu = 4)` to tell R that we were hypothesizing that the true average in the population was 4.  How would you change this line if you wanted to hypothesize that the true average in the population was 7?

:::

Now that we have built our sampling distribution (assuming the null hypothesis is true), let's see where our observed sample mean falls on this distribution.  Note that we set `direction = "greater"` in the code below, because our alternative hypothesis is that the average is *greater than* 4 days:


```r
null_dist_mental_health %>%
    visualize() +
    shade_p_value(obs_stat = sample_mean, direction = "greater")
```

<img src="09-single_mean_files/figure-html/unnamed-chunk-19-1.png" width="672" />

Not looking too good for the null hypothesis!  None (or very few) of our simulations were at least as extreme as the observed sample mean.

#### Using the T distribution

Because the sample is so large, we can also use a mathematical model to find the $p$ value we need for our hypothesis test.  To do this, we will use R to calculate the **T score** and then find out what proportion of the T distribution is larger than this T score.

Recall that, just like a Z score, a T score is defined as the difference between a point estimate and its hypothesized value, relative to the standard error:

$$
\begin{align*}
T & = \frac{\text{point estimate} - \text{null value}}{\text{standard error}} \\
& = \frac{\bar{x} - \mu_0}{SE}
\end{align*}
$$

::: {.exercise}

Fill in the blanks in the code below to find the T score and then the corresponding $p$ value using the T distribution.  *Hint:* Try to fill in at least some of the blanks with the *names* of values we have already calculated earlier in the session.


```r
t_score <- (___ - ___) / ___

p_value <- pt(q = t_score, df = ___, lower.tail = FALSE)
```

a. What code did you use?
b. Assuming a significance level of 0.05, do you reject the null hypothesis?  Why or why not?
c. Give a one sentence summary of the outcome of this hypothesis test in the context of the scenario.

:::

## How much can people keep track of?

To get further experience seeing how inference about the mean of a numerical variable is important in psychology, we will consider the case of "memory span".  To be clear, this is not the total amount of stuff you can remember over your whole life!  Rather, it is how much you can remember about a situation with multiple different things in it.  In that sense, it is related to the idea of "attention span": how many distinct things can you keep track of at one time?

One way memory span is measured is by showing people a sequence of objects and then asking them to recall which objects were in the sequence.  The longest sequence you can recall without making errors is your "memory span".  For example, these are two sequences someone might be shown, with each row of pictures being a sequence:

![Two example sequences of random objects, the top one with 3 objects and the bottom one with 4 objects.](img/span_ex.png)

Say a participant sees the first sequence and correctly recalls a small black square, a large black triangle, and a small purple triangle.  Then they see the second sequence and recall a large blue cross, a small blue spiral, and a large red spiral.  They made an error by forgetting the small red spiral.  As a result, their memory span would be measured as 3 objects because that is the most they could recall without error.

Measurements of memory span were recently collected by @MathyEtAl2018 using a random sample of college students.

### Load the data

Download their data, of which we will only look at two variables:  A participant ID number and the measured memory span for each participant.  Note that the reported spans are not always integers because they allowed partial credit for sequences that were not perfectly recalled.


```r
span_data <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/simple_span.csv")
```

```{.Rout .text-info}
## Rows: 94 Columns: 2── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## dbl (2): id, span
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

### Check out the data

First, let's get a sense of the raw data by making a histogram of the measured memory spans, recorded under the variable named `span`.


```r
span_data %>%
    ggplot(aes(x = span)) +
    geom_histogram(binwidth = 1)
```

<img src="09-single_mean_files/figure-html/unnamed-chunk-22-1.png" width="672" />

And let's also get the sample mean, sample standard deviation, and sample size:


```r
span_data %>%
    summarize(sample_mean = mean(span), sample_sd = sd(span), sample_size = n())
```

```{.Rout .text-muted}
## # A tibble: 1 × 3
##   sample_mean sample_sd sample_size
##         <dbl>     <dbl>       <int>
## 1        4.05      1.06          94
```

::: {.exercise}

Consider the histogram and summary statistics for the `span` variable we just made.

a. Describe the distribution of memory span, being sure to note the number of modes, skewness, and whether there are any outliers.
b. Does it seem like the conditions are satisfied to use a mathematical model for the sampling distribution of the mean?

:::

### Build a confidence interval

::: {.exercise}

Use bootstrapping to construct a sampling distribution for the mean memory span, based on the data from this sample.  Use this distribution to find a 95% confidence interval for the mean memory span.  To do this, fill in the blanks in the chunk of code below (*Hint:* refer to code from earlier in the session and remember what the name of the response variable is.):


```r
boot_dist_span <- span_data %>%
    specify(response = ___) %>%
    generate(reps = 1000, type = "___") %>%
    calculate(stat = "___")

boot_ci_span <- boot_dist_span %>%
    get_confidence_interval(level = ___)

boot_dist_span %>%
    visualize() +
    shade_confidence_interval(boot_ci_span)

boot_ci_span
```

a. What code did you use?
b. Report the confidence interval you found (you can find this in R's environment under `boot_ci_span`) and interpret the interval in the context of the research scenario.

:::

### Test a hypothesis

Based on many prior studies of memory span, it seems that people on average can keep track of about 4 unique objects at a time.  It is therefore reasonable to ask the **research question**, "do these data provide evidence that the population sampled has a memory span *different* from 4 objects?"

::: {.exercise}

--

a. What are the null and alternative hypotheses corresponding to this research question?
b. Fill in the blanks in the code below to build a sampling distribution that assumes the null hypothesis is true.  In the end, you should get a histogram of the sampling distribution showing where the observed sample mean falls.  What code did you use?  (*Hint:* remember that the last blank has three options, `less`, `greater`, or `two-sided`, and which is appropriate depends on the null/alternative hypotheses.)


```r
null_dist_span <- span_data %>%
    specify(response = ___) %>%
    hypothesize(null = "___", mu = ___) %>%
    generate(reps = 1000, type = "___") %>%
    calculate(stat = "___")

sample_mean_span <- span_data %>%
    summarize(mean(span)) %>%
    pull()

null_dist_span %>%
    visualize() +
    shade_p_value(obs_stat = sample_mean_span, direction = "___")
```

c. Based on the visualization you made in part (b), would you expect the T score to have a large or small magnitude?  To be positive or negative?


```r
null_dist_span %>%
    get_p_value(obs_stat = sample_mean_span, direction = "___")
```

d. Use the code above to find the $p$ value (making sure to use the same `direction` from part b).  Based on what you believe is a reasonable significance level, would you reject the null hypothesis?

e. In one sentence, summarize the result of this hypothesis test in the context of the problem.

f. Could we have anticipated the outcome of this hypothesis test based on the confidence interval you found in the previous exercise?  Why or why not?

:::

## Wrap-up

In this session, we saw how we can use the same kinds of computational techniques we applied to proportions---particularly bootstrapping---to construct confidence intervals and perform hypothesis tests about means.  We also saw how to use the T distribution to find confidence intervals and conduct hypothesis tests.
