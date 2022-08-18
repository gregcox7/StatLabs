# Inference for comparing two independent means {#lab10}



<img src="img/german_apprentice.jpg" width="100%" />

In this session, we will see how to conduct inferences about whether two groups differ on average.  In these situations, we have two separate and independent samples from two (potentially) different populations.  We want to know if the observed differences in sample means reflect a difference in the means of the two populations or if they could reasonably be attributed to chance alone.  Just like when we were doing inferences about differences in proportions, we can use both simulation and mathematical methods to address these types of questions.

## Required packages

As we've practiced quite a bit by now, we will first load both the `tidyverse` and `infer` packages.


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

## Are recruiters more impressed by a spoken vs. written hiring pitch?

Imagine trying to convince a recruiter that you are the right person for the job.  Do you come off better in writing or if you can give your pitch in person?  This was the question addressed in a series of experiments by @SchroederEpley2015.  We will focus on one of their experiments (Experiment 4 in the original paper).

In this experiment, MBA students at the University of Chicago business school prepared short "elevator pitches" describing why they should be hired at a firm of their choice.  The students then recorded themselves giving their pitch.  Finally, a sample of professional recruiters was selected and randomly assigned to one of two groups:  One group would hear the audio recording of the student's pitch; another group would read a transcript of that audio recording.  The recruiters evaluated the potential applicants on a number of scales, but we will focus only on one response variable:  On a scale from 1--10, recruiters rated the likelihood that they would hire student based on their (spoken or written) pitch.

The **research question** we will address with these data is, "is there a difference in average hiring ratings when a recruiter hears or reads a pitch?"

::: {.exercise}

What are the **null** and **alternative** hypotheses corresponding to our research question?

:::

### Check out the data

First, let's load the data into our RStudio environment:


```r
hiring_study <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/hiring_study.csv")
```

```{.Rout .text-info}
## Rows: 39 Columns: 27── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr   (2): test, Condition
## dbl  (23): compt, thought, intell, like, pos, neg, hire, age, gender, cond, ...
## dttm  (2): start_time, end_time
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Each row represents the responses from a particular recruiter.  Whether the recruiter got a spoken or written pitch is recorded in the `Condition` variable, which is either "audio" (for hearing a spoken pitch) or "transcript" (for reading a transcript of the pitch).  The recruiter's hiring rating is recorded in the `hire` variable, which is a number between 1 and 10.

::: {.exercise}

--

a. What are the names of the **response** variable and **explanatory** variable in the `hiring_study1` dataset?
b. Fill in the blanks in the code below with the corresponding variable names (from part [a] of this exercise) to visualize the distribution of ratings in the two groups.  Describe the shape of the distributions and whether it seems like there may be a relationship between the type of pitch and hiring ratings.


```r
hiring_study %>%
    ggplot(aes(x = ___)) +
    geom_histogram(binwidth = 1) +
    facet_wrap("___", ncol = 1)
```

c. Fill in the blanks in the code below with the corresponding variable names (from part [a] of this exercise) to simulate a version of how the data would look if the null hypothesis were true (using random permutation).  Describe how, if at all, the distributions differ from how they looked in the original data in part (b).


```r
null_simulation <- hiring_study %>%
    specify(___ ~ ___) %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1, type = "permute")

null_simulation %>%
    ggplot(aes(x = ___)) +
    geom_histogram(binwidth = 1) +
    facet_wrap("___", ncol=1)
```

:::

::: {.exercise}

Fill in the blanks in the code below using the appropriate variable names to obtain numerical summaries of each group's hiring ratings.


```r
hiring_study %>%
    group_by(___) %>%
    summarize(sample_mean = mean(___), sample_sd = sd(___), sample_size = n())
```

Use the resulting table to answer the following questions.

a. Do the two groups have similar variability?  (Be sure to refer to the "rule of thumb" for checking whether two samples have similar variability.)
b. Do the sample means suggest an advantage for either spoken ("audio") or written ("transcript") hiring pitches?

:::

### Hypothesis testing via simulation

As we've seen, we can use random permutation to model how the data would look if the null hypothesis were true.  For each of these simulated datasets, we compute the difference in mean hiring ratings between the audio and transcript conditions.  By doing this many times, we build up a sampling distribution of the difference in means.  If very few simulated datasets produce a difference at least as extreme as what we actually observed, we can reject the null hypothesis.

::: {.exercise}

--

a. Fill in the blanks in the code below (using the appropriate variable names) to find the observed difference in mean hiring ratings between conditions.  What is the observed difference in means?


```r
obs_diff <- hiring_study %>%
    specify(___ ~ ___) %>%
    calculate(stat = "diff in means", order = c("audio", "transcript"))

obs_diff
```

b. Fill in the blanks in the code below to simulate and visualize 1000 differences in means according to the null hypothesis.  For the final blank, the `direction` can be either `less`, `greater`, or `two-sided`; pick the one corresponding to the alternative hypothesis.  Based on the visualization, would the observed difference be unusual if the null hypothesis were true?


```r
null_dist_simulation <- hiring_study %>%
    specify(___ ~ ___) %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in means", order = c("audio", "transcript"))

null_dist_simulation %>%
    visualize() +
    shade_p_value(obs_stat = obs_diff, direction = "___")
```

c. Fill in the blank below (using the same `direction` you gave in part b) to get the proportion of simulated datasets that were at least as extreme as what we observed.  If we assume a significance level of 0.05, would we reject the null hypothesis?  Why or why not?


```r
null_dist_simulation %>%
    get_p_value(obs_stat = obs_diff, direction = "___")
```

:::

### Hypothesis testing using the T distribution

In this section, we will relate the simulation approach we just used to the mathematical model approach using the T distribution.

::: {.exercise}

Fill in the blanks in the code below (using the appropriate variable names) to calculate the **T score** associated with our sample:


```r
obs_t <- hiring_study %>%
    specify(___ ~ ___) %>%
    calculate(stat = "t", order = c("audio", "transcript"))

obs_t
```

a. What is the T score you got?
a. Does the T score indicate that the observed difference is relatively near or far from what the null hypothesis would predict?  What about the T score tells you how near/far it is from the null?
a. Above, we used code with the line `calculate(stat = "diff in means", order = c("audio", "transcript"))` to get the observed difference in sample means.  How does that line differ from the `calculate` line in the code you used in this Exercise to find the T score?  Describe in your own words what the `stat` option seems to do.

:::

::: {.exercise}

Fill in the blanks in the code below to visualize where our sample falls on the corresponding T distribution.  As above, be sure to fill in the last blank according to the alternative hypothesis (either `two-sided`, `less`, or `greater`).


```r
null_dist_math <- hiring_study %>%
    specify(___ ~ ___) %>%
    assume("t")

null_dist_math %>%
    visualize() +
    shade_p_value(obs_stat = obs_t, direction = "___")
```

a. Compare the visualization you just made using the mathematical model with the visualization you made earlier using simulation.  Relative to each null distribution, is our observed data (the red vertical line) in a similar place?  Is a similar proportion of the null distribution more extreme than what was observed?

b. Fill in the blanks in the code below to get the $p$ value according to the mathematical model (again, the `direction` should correspond to the alternative hypothesis).  What was the $p$ value you got?  Again assuming a significance level of 0.05, would we reject the null hypothesis?  Do we come to a different conclusion than we did using simulation?


```r
null_dist_math %>%
    get_p_value(obs_stat = obs_t, direction = "___")
```

c. Based on this hypothesis test (either the simulation or mathematical approach will do), give a one sentence summary of what we should conclude about the effectiveness of spoken vs. written pitches on hiring ratings.
d. Speculate about why these results turned out the way they did.  Do you expect this result would generalize to hiring decisions in real life?  Why or why not?

:::

## Wrap-up

In this session, we got some practice doing hypothesis tests to compare means between two independent groups.  We carried out the test using both simulation and mathematical models.  Along the way, we saw whether there was evidence that spoken or written job pitches are more likely to lead to hiring ratings, illustrating how these methods are used and applied in research settings.
