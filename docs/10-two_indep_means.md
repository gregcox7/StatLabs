# Inference for comparing two independent means {#lab10}



<img src="img/german_apprentice.jpg" width="100%" />

In this session, we will see how to conduct inferences about whether two groups differ on average.  In these situations, we have two separate and independent samples from two (potentially) different populations.  We want to know if the observed differences in sample means reflect a difference in the means of the two populations or if they could reasonably be attributed to chance alone.  Just like when we were doing inferences about differences in proportions, we can use both simulation and mathematical methods to address these types of questions.

To help with the later exercises in this session, be sure to **download the worksheet for this session** by right-clicking on the following link and selecting "Save link as...": [Worksheet for Lab 10](https://raw.githubusercontent.com/gregcox7/StatLabs/main/worksheets/ws_lab10.Rmd).  Open the saved file (which by default is called "ws_lab10.Rmd") in RStudio.

## What if there were two groups of infants?

In our previous lab, we analyzed data from an experiment in which infants listened to two singers and then researchers recorded how much time each infant spent looking at the person who sang a familiar song, relative to someone who sang a new song.  The data from the previous lab were *paired*.  For each infant, we could compare the amount of time looking at the familiar singer *before* they sang vs. *after* they sang.  To do this, we created a new variable called `diff` that was the difference between the "Before" and "After" looking times.

In this first part of our activity, we are going to see how our conclusions would be affected if we had instead compared *two independent groups* of infants, one who didn't hear anyone sing (the "Before" group) and another who did hear the two people sing (the "After" group).  We will again look at the difference in mean looking times, only now we won't be looking at that difference *within* each infant.  We will be looking at the difference *between* each *group* of infants.

### Paired vs. two-group data

::: {.exercise}

Run the following chunk of code to examine the first few rows of the *original* infant data from last time:


```r
head(lullaby_paired)
```

Now look at the first few rows of the data in which we *pretend* that the infants were two different groups:


```r
head(lullaby_twogroups)
```

In your own words, describe the differences in how the data are structured between the original paired data and our pretend version with two groups.  *Hint:* Would we be able to easily create a new `diff` variable with the two-group data like we did with the original paired data?

:::

### Comparing inferences

::: {.exercise}

Last time, we tested the null hypothesis that the difference in mean looking times was zero.  Another way to state that null hypothesis is that looking time and hearing people sing are *independent*.  Now we will use our pretend two-group data to test the same null hypothesis and see whether our conclusions would be different.

Fill in the blanks in the following chunk of code to use *random permutation* to simulated 1000 datasets assuming the null hypothesis is true.  At the end of the chunk, we visualize the sampling distribution of the *difference in means* between groups across each of those simulations, along with a red line indicating where the observed difference falls.  For guidance, check out how we did this with Kobe's data in Lab 5; the only important difference is the `stat` in the `calculate` line (remember that we are looking at differences in means, not proportions).  Also, remember that with the pretend two-group data we have both a response variable (`Looking`) and an explanatory variable (`Group`).


```r
lullaby_twogroups_obs_diff <- lullaby_twogroups %>%
    specify(___ ~ ___) %>%
    calculate(stat = "___", order = c("After", "Before"))

lullaby_twogroups_null_dist <- lullaby_twogroups %>%
    specify(___ ~ ___) %>%
    hypothesize(null = "___") %>%
    generate(reps = 1000, type = "___") %>%
    calculate(stat = "___", order = c("After", "Before"))

lullaby_twogroups_null_dist %>%
    visualize() +
    shade_p_value(obs_stat = lullaby_twogroups_obs_diff, direction = "two-sided")
```

a. Based on the visualization you just made, what would you conclude?  Would you reject the null hypothesis or not and why?
b. Run the following chunk of code to perform the same test using the original paired data (last time, we did this with a mathematical model instead of simulation, but the outcome is the same).  Would you come to the same conclusion with the original paired data as with our pretend two-group data?


```r
lullaby_paired_obs_diff <- lullaby_paired %>%
    mutate(diff = After - Before) %>%
    specify(response = diff) %>%
    calculate(stat = "mean")

lullaby_paired_null_dist <- lullaby_paired %>%
    mutate(diff = After - Before) %>%
    specify(response = diff) %>%
    hypothesize(null = "point", mu = 0) %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "mean")

lullaby_paired_null_dist %>%
    visualize() +
    shade_p_value(obs_stat = lullaby_paired_obs_diff, direction = "two-sided")
```

c. Why do you think the observed difference of means (the red line) is in the same position on the X axis in both graphs?
d. Why do you think the sampling distribution is wider in part [a] (with the pretend two-group data) than part [b] (with the original paired data)?

:::

## Are recruiters more impressed by a spoken vs. written hiring pitch?

Imagine trying to convince a recruiter that you are the right person for the job.  Do you come off better in writing or if you can give your pitch in person?  This was the question addressed in a series of experiments by @SchroederEpley2015.  We will focus on one of their experiments (Experiment 4 in the original paper).

In this experiment, MBA students at the University of Chicago business school prepared short "elevator pitches" describing why they should be hired at a firm of their choice.  The students then recorded themselves giving their pitch.  Finally, a sample of professional recruiters was selected and randomly assigned to one of two groups:  One group would hear the audio recording of the student's pitch; another group would read a transcript of that audio recording.  The recruiters evaluated the potential applicants on a number of scales, but we will focus only on one response variable:  On a scale from 1--10, recruiters rated the likelihood that they would hire student based on their (spoken or written) pitch.

The **research question** we will address with these data is, "is there a difference in average hiring ratings when a recruiter hears or reads a pitch?"

::: {.exercise}

What are the **null** and **alternative** hypotheses corresponding to our research question?

:::

### Check out the data

First, let's check out the first few rows of the data:


|start_time          |end_time            | compt| thought| intell| like| pos| neg| hire| age| gender|test                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | cond|    time| wordcount| negR| intellect| impression| speaker| pnum| meanhire| meanintellect| meanimpression|   centhire| centintellect| centimpression|Condition  |
|:-------------------|:-------------------|-----:|-------:|------:|----:|---:|---:|----:|---:|------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----:|-------:|---------:|----:|---------:|----------:|-------:|----:|--------:|-------------:|--------------:|----------:|-------------:|--------------:|:----------|
|2014-05-01 20:40:05 |2014-05-01 20:44:38 |     7|       7|      7|    7|   7|   1|    7|  29|      2|Miriam wanted to work at Mckinsey. Worked previously at teach for america where she worked on analytical skills and teamwork. She is founder of the Booth educational club and used power of persuasion to get funding.                                                                                                                                                                                                                                                                                                                                                                           |    1| 135.045|        36|   10|  7.000000|   8.000000|       9|    1| 4.583333|      5.722222|       6.638889|  2.4166667|      1.277778|      1.3611111|audio      |
|2014-05-01 21:27:09 |2014-05-01 21:36:03 |     6|       8|      6|    6|   6|   6|    5|  27|      2|The candidate worked at Citigroup in their leveraged finance team, working mainly on LBOs.  He was offered the opportunity to remain with the firm as an associate, but chose to return to India to work for a home furnishings company.   That company was struggling and he was attempting to turn it around as much as possible within 2 years.  He know wants to work in a general management role at MetLife.                                                                                                                                                                                |    1| 127.160|        71|    5|  6.666667|   5.666667|      18|    2| 4.666667|      5.577778|       5.777778|  0.3333333|      1.088889|     -0.1111111|audio      |
|2014-05-01 22:01:34 |2014-05-01 22:09:44 |     7|       8|      6|    9|   9|   1|    6|  27|      2|worked as an analyst at citigroup in levfin, said he was promoted twice. decided to move to india to help turn around a struggling business. was the most difficult decision of his life but believed taking that opportunity would be a better learning experience than continuing on as an associate in his current function.                                                                                                                                                                                                                                                                   |    1| 140.512|        54|   10|  7.000000|   9.333333|      18|    3| 4.666667|      5.577778|       5.777778|  1.3333333|      1.422222|      3.5555556|audio      |
|2014-05-01 22:00:50 |2014-05-01 22:11:41 |     4|       3|      6|    6|   6|   6|    5|  40|      2|The candidate was applying for a job with McKinsey, specifically. However might be looking for consulting positions with a premium firm. He believes that the most important characteristics for a consultant work communications, analytics, teamwork, entrepreneurship. He was a Teacher for teach for America where he felt he demonstrated analytics through his metric driven education of children; he demonstrated entrepreneurship by starting new club on campus, had demonstrated communication skills, which were seen in presentations that he made, one of which was in San Antonio. |    0|  59.906|        85|    5|  4.333333|   5.666667|       9|    4| 4.583333|      5.722222|       6.638889|  0.4166667|     -1.388889|     -0.9722222|transcript |
|2014-05-01 23:03:14 |2014-05-01 23:13:44 |     2|       3|      1|    2|   2|   8|    2|  32|      2|Applied for a job at McKinsey, was a teacher in Brooklyn, started industry club at Booth- got admin approval & budget money for club, convinced San Antonio mayor to give budget for sustainable project in a local school, worked at a mgmt consulting firm over the summer & worked in teams                                                                                                                                                                                                                                                                                                    |    0| 108.722|        51|    3|  2.000000|   2.333333|       9|    5| 4.583333|      5.722222|       6.638889| -2.5833333|     -3.722222|     -4.3055556|transcript |
|2014-05-02 10:18:38 |2014-05-02 10:26:25 |     3|       3|      3|    2|   2|   6|    2|  24|      2|Previously worked at Citigroup for 3 years - then had to go back to India to help a struggling business. He was given 2 years to help turn the struggling business around and it was overall a great learning experience for him. He now wants a job at Metlife                                                                                                                                                                                                                                                                                                                                   |    0|  75.190|        49|    5|  3.000000|   3.000000|      18|    6| 4.666667|      5.577778|       5.777778| -2.6666667|     -2.577778|     -2.7777778|transcript |

Each row represents the responses from a particular recruiter.  Whether the recruiter got a spoken or written pitch is recorded in the `Condition` variable, which is either "audio" (for hearing a spoken pitch) or "transcript" (for reading a transcript of the pitch).  The recruiter's hiring rating is recorded in the `hire` variable, which is a number between 1 and 10.

::: {.exercise}

Fill in the blanks in the code below with the appropriate variable names to visualize the distribution of ratings in the two groups.  *Hint:* Keep in mind what are the names of the explanatory variable and response variable.


```r
hiring_study %>%
    ggplot(aes(x = ___)) +
    geom_histogram(binwidth = 1) +
    facet_wrap("___", ncol = 1)
```

a. Describe the shape of the distributions and whether it seems like there may be a relationship between the type of pitch and hiring ratings.
b. Fill in the blanks in the code below to use random permutation to simulate *one* way the data would look if the null hypothesis were true.  Describe how, if at all, the distributions differ from how they looked in the original data in part (a).


```r
hiring_null_simulation <- hiring_study %>%
    specify(___ ~ ___) %>%
    hypothesize(null = "___") %>%
    generate(reps = 1, type = "___")

hiring_null_simulation %>%
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

Fill in the blanks in the code below (using the appropriate variable names) to find the observed difference in mean hiring ratings between conditions, then compare this against the differences we would expect *if* the null hypothesis were true.  We will build the sampling distribution of differences in means using random permutation.  Be sure to make at least 1000 simulations.  For the final blank, the `direction` can be either `less`, `greater`, or `two-sided`; pick the one corresponding to the alternative hypothesis.


```r
hiring_obs_diff <- hiring_study %>%
    specify(___ ~ ___) %>%
    calculate(stat = "___", order = c("audio", "transcript"))

hiring_null_simulation <- hiring_study %>%
    specify(___ ~ ___) %>%
    hypothesize(null = "___") %>%
    generate(reps = ___, type = "___") %>%
    calculate(stat = "___", order = c("audio", "transcript"))

hiring_null_simulation %>%
    visualize() +
    shade_p_value(obs_stat = hiring_obs_diff, direction = "___")
```

Based on the visualization, does it seems like the observed difference would be unusual if the null hypothesis were true?

:::

### Hypothesis testing using the T distribution

In this section, we will relate the simulation approach we just used to the mathematical model approach using the T distribution.

::: {.exercise}

Fill in the blanks in the code below (using the appropriate variable names) to calculate the **T score** associated with our sample:


```r
hiring_obs_t <- hiring_study %>%
    specify(___ ~ ___) %>%
    calculate(stat = "t", order = c("audio", "transcript"))

hiring_obs_t
```

a. Does the T score indicate that the observed difference is relatively near or far from what we would expect if the null hypothesis were true?  Explain your reasoning.
b. Above, we used code with the line `calculate(stat = "diff in means", order = c("audio", "transcript"))` to get the observed difference in sample means.  How does that line differ from the `calculate` line in the code you used in this Exercise to find the T score?  Describe in your own words what the `stat` option seems to do.

:::

::: {.exercise}

Fill in the blanks in the code below to visualize where our sample falls on the corresponding T distribution.  As above, be sure to fill in the last blank according to the alternative hypothesis (either `two-sided`, `less`, or `greater`).


```r
hiring_null_math <- hiring_study %>%
    specify(___ ~ ___) %>%
    assume("t")

hiring_null_math %>%
    visualize() +
    shade_p_value(obs_stat = hiring_obs_t, direction = "___")
```

a. Compare the visualization you just made using the mathematical model with the visualization you made earlier using simulation.  Relative to each null distribution, is our observed data (the red vertical line) in a similar place?  Is a similar proportion of the null distribution more extreme than what was observed?

b. Fill in the blanks in the code below to get the $p$ value according to the mathematical model (again, the `direction` should correspond to the alternative hypothesis).  Would you reject the null hypothesis or not and why?  (Be sure to state your significance level!)


```r
hiring_null_math %>%
    get_p_value(obs_stat = hiring_obs_t, direction = "___")
```

c. Based on this hypothesis test (either the simulation or mathematical approach will do), give a one sentence summary of what we should conclude about the effectiveness of spoken vs. written pitches on hiring ratings.
d. Speculate about why these results turned out the way they did.  Do you expect this result would generalize to hiring decisions in real life?  Why or why not?

:::

## Wrap-up

In this session, we got some practice doing hypothesis tests to compare means between two independent groups.  We carried out the test using both simulation and mathematical models.  Along the way, we saw whether there was evidence that spoken or written job pitches are more likely to lead to hiring ratings, illustrating how these methods are used and applied in research settings.
