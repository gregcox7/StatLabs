# Inference for multiple independent groups {#lab11}



<img src="img/tetris.png" width="100%" />

In this session, we will use R to do inference for comparing averages from multiple independent groups.  Specifically, we will be interested in doing hypothesis tests to address questions about whether multiple groups differ on average, called **Analysis of Variance (ANOVA)**.  We will see that the simulation techniques we learned for comparing proportions or means between two groups also apply when we have multiple groups.  The mathematical model for ANOVA is different, however; it is an "F distribution".  We will use these techniques to analyse an experiment designed to compare different ways to minimize intrusions of traumatic memories.

To help with the exercises in this session, be sure to **download the worksheet for this session** by right-clicking on the following link and selecting "Save link as...": [Worksheet for Lab 11](https://raw.githubusercontent.com/gregcox7/StatLabs/main/worksheets/ws_lab11.Rmd).  Open the saved file (which by default is called "ws_lab11.Rmd") in RStudio.

## Can we reduce intrusions of traumatic memories?

One of the hallmarks of post-traumatic stress disorder is that memories of the traumatic event "intrude" on everyday life, popping up when they are not wanted.  When you remember a previous event, the memory is said to be "active".  According to reconsolidation theory, active memories can also be changed.  For example, when you tell a story from memory, telling the story might change your memory such that you would tell it differently next time.  Reconsolidation theory suggests that one way to reduce intrusions of traumatic memories is to "activate" them and then change them so they are less likely to intrude on everyday life.

One way to modify intrusive memories was studied by @JamesEtAl2015.  They thought that playing a video game, namely *Tetris*, while a memory was active would help make that memory less traumatic.  They had participants first view a traumatic film (including scenes of real car accidents).  Over the next week, participants recorded how often a memory of the traumatic film *intruded* on their everyday life.  During that week, participants came back into the lab and were randomly assigned to one of four treatment conditions:

* Reactivation-plus-Tetris: In this group, participants were shown still images from the traumatic film to "reactivate" memories for the film.  They then played Tetris for 12 minutes.
* Reactivation only: In this group, participants were shown still images from the traumatic film to "reactivate" memories for the film, but then sat silently for 12 minutes and did not play Tetris.
* Tetris only: In this group, participants were not shown any images from the film but simply played Tetris for 12 minutes.
* No task (control): In this group, participants simply sat quietly for 12 minutes.

According to reconsolidation theory, people in the reactivation-plus-Tetris condition should experience fewer intrusive memories because playing Tetris should change those memories to be less disruptive.  This is not predicted to happen in any other group.  In the control and Tetris-only conditions, the original traumatic memories are not being reactivated, so they should not be affected.  In the reactivation-only condition, although memories are being reactivated, they are not being altered.  Of course, this is just what the theory *says* should happen.  Let's see what actually transpired.

### Check out the data

These are the first few rows of our data, which is loaded into R under the name `tetris_data`:


|condition         | intrusions_pre| intrusions_post|
|:-----------------|--------------:|---------------:|
|No task (control) |              2|               4|
|No task (control) |              2|               3|
|No task (control) |              5|               6|
|No task (control) |              0|               2|
|No task (control) |              5|               3|
|No task (control) |              4|               4|

Each row shows data from a single participant.  There are 3 variables in the dataset:

* `condition`: Which of the four treatment conditions the participant was in.
* `intrusions_pre`: The number of times the participant reported an intrusive memory of the traumatic film prior to treatment.
* `intrusions_post`: The number of times the participant reported an intrusive memory of the traumatic film after treatment.

::: {.exercise}

Consider the design of this study to address the following questions.

a. Would it be possible to conclude that the treatment condition plays a role in *causing* any changes we might observe in the number of intrusive memories?  Why or why not?
b. Fill in the blanks in the code below to use `mutate` to create a new variable called `effect` that represents the *difference* between the number of intrusions after treatment and the number of intrusions before treatment.  Write the code so that a *negative* value of `effect` means a *reduction* in the number of intrusive memories from before to after treatment.  What code did you use?


```r
tetris_data %>%
    mutate(effect = ___ - ___)
```

:::

### Visualize the data

::: {.exercise}

Fill in the blanks in the code below to make a boxplot that compares the distribution of `effect` for each group (defined by their treatment `condition`).  Your `mutate` line should be the same as in the previous exercise.  Try putting treatment condition on the horizontal ("x") axis and treatment effect on the vertical ("y") axis.


```r
tetris_data %>%
    mutate(effect = ___ - ___) %>%
    ggplot(aes(x = ___, y = ___)) +
    geom_boxplot()
```

a. Our **research question** is, "is there a difference in average effectiveness between treatment conditions?"  What are the null and alternative hypotheses corresponding to this research question?
b. What are the names of the explanatory variable and response variable?
c. Based on the boxplot you just made in this exercise, do these data seem more consistent with the null or the alternative hypothesis?  Explain your reasoning.

:::

### Hypothesis testing by randomization

We will use these data to conduct a hypothesis test to help us address the research question, "is there a difference in average effectiveness between treatment conditions?"  As we've seen, the test statistic that we need is a **F statistic**, which represents how much variability there is *between* groups, relative to the amount of variability *within* groups.

#### The observed F statistic

::: {.exercise}

Fill in the blanks in the code below to find the F statistic for our observed data.  *Hint:* for the `specify` line, remember to put the name of the response variable on the left of the `~` and the name of the explanatory variable on the right.


```r
obs_f <- tetris_data %>%
    mutate(effect = ___ - ___) %>%
    specify(___ ~ ___) %>%
    calculate(stat = "F")

obs_f
```

a. What was the F statistic you found?
b. Does the F statistic you found indicate that the between-group variability is greater or smaller than the within-group variability?  Explain your reasoning.

:::

#### Simulating the null hypothesis

Just like when we were comparing proportions or comparing means from independent samples, we can simulate how the data would look if the null hypothesis were true.  Specifically, to simulate a single dataset, we randomly re-assign (*permute*) the values of the explanatory variable across observations.  We then calculate an F statistic for that simulated dataset.  We then repeat that process many times to build a **sampling distribution** for the F statistic.  Finally, we see whether the F statistic for the actual data is large enough that we reject the idea that it came about by sampling error alone.

::: {.exercise}

Fill in the blanks in the code below to use random permutation to conduct a hypothesis test.  The final result should be a histogram of simulated F statistics along with a line indicating where our observed F statistic (`obs_f` from the last exercise) falls in that distribution.  *Hint:* For the blanks in the `hypothesize` and `generate` lines, consider how we simulated the null hypothesis for [comparing proportions](#lab5) or [means from independent samples](#lab10).  Also, make sure that `obs_f` from the last exercise is present in R's environment (upper right part of RStudio), otherwise this won't work!


```r
null_dist <- tetris_data %>%
    mutate(effect = ___ - ___) %>%
    specify(___ ~ ___) %>%
    hypothesize(null = "___") %>%
    generate(reps = 1000, type = "___") %>%
    calculate(stat = "F")

null_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_f, direction = "greater")
```

a. Based on the histogram you just produced, would you consider the observed F statistic to be unusually large if the null hypothesis were true?
b. Run the chunk of code below to overlay the mathematical model of the null hypothesis---the "F distribution"---on the histogram of simulated F statistics.  Describe the shape of the F distribution (skewness, number of modes) as well as whether the F distribution (the smooth curve) make a good "fit" with the histogram of simulated F statistics.


```r
null_dist %>%
    visualize(method = "both") +
    shade_p_value(obs_stat = obs_f, direction = "greater")
```

:::

### Hypothesis testing by mathematical model

In practice, ANOVA is often done using a mathematical model of the null hypothesis instead of using simulation.  The relevant calculations are carried out by computer, but the results are often presented in a table that makes it easier to see how the sausage is made (this is the same format used in class and in the book).

::: {.exercise}

Fill in the blanks in the code below to use R to produce an ANOVA table.  *Hint:* The first two lines are just for convenience; they tell R to store a version of the data that already has the `effect` variable.  So be sure to use the same `mutate` line you've been using in previous exercises.  For the `lm` line, recall that the squiggly `~` is used to `specify` the response and explanatory variables.


```r
tetris_data_effect <- tetris_data %>%
    mutate(effect = ___ - ___)

lm(___ ~ ___, data = tetris_data_effect) %>%
    anova()
```

a. Find the mathematically computed $p$ value in the table you just produced (the column headings will be helpful, you may also compare the format to ANOVA tables from class or the book).  What is the $p$ value?
b. Using a significance level of 0.05, would we reject the null hypothesis or not?  Why or why not?
c. Summarize what the results of this hypothesis test tell us about whether the treatment conditions were equally effective in reducing intrusive memories.

:::

### Post-hoc comparisons

The reconsolidation theory predicts that reactivation-and-Tetris should be significantly more effective than all three other treatment conditions.  Although we have established that the treatment conditions are not equally effective, we do not know whether we have evidence that reactivation-and-Tetris is significantly better than other treatments.

Fortunately, R provides a convenient way to test, for every possible pair of groups, the null hypothesis that the difference in means between groups is zero.  R does so using the independent samples T test that we used last time.  R will report the *adjusted* $p$ value from each test.

#### Adjusted $p$ value vs. adjusted significance level

In class, we discussed that when making multiple comparisons, you have to *adjust* your significance level.  This is because the significance level is the chance that we make a "false alarm" or **Type I error**.  The more tests we perform, the more opportunities we have to make this kind of error.  So by reducing the significance level, we can reduce the total probability of making a Type I error.

The **Bonferroni correction** says that we should adjust our significance level by *dividing* it by the number of pairwise comparisons we make.  If there are $k$ groups, the number of comparisons is

$$
\text{Number of pairwise comparisons} = \frac{k (k - 1)}{2}
$$

Then, for *each* pairwise test, we reject the null hypothesis *for that specific pair* if

$$
p \text{ value} < \frac{\text{Significance level}}{\text{Number of pairwise comparisons}}
$$

An equivalent way to say when we would reject the null hypothesis is this:

$$
\left( p \text{ value} \right) \times \left( \text{Number of pairwise comparisons} \right) < \text{Significance level}
$$

In other words, we can either reduce our significance level (the first inequality) or increase our $p$ value.  Both approaches involve the same adjustment factor, namely, the number of pairwise comparisons.  And both approaches will result in the same decision, so they can be treated as equivalent.

R takes the second approach.  That is, for each pairwise comparison, R reports the *adjusted $p$ value*.  The reason is because R doesn't know what our significance level is---that's our choice.  So by adjusting the $p$ value, R gives us a result that we can use regardless of what our significance level is.  We will look at each $p$ value that R reports and, for each one, decide whether or not to reject the corresponding null hypothesis by seeing whether the adjusted $p$ value is less than our significance level.

::: {.exercise}

Fill in the blanks in the code below to tell R to conduct an independent samples T test for every pair of groups in our data.  Remember to use the same `mutate` line we've been using.  Also note that you'll need to put the name of the response variable following `x` and the name of the explanatory ("grouping") variable following `g`.  Finally, see that we have specified the **Bonferroni** correction for multiple comparisons.  The result of running this chunk should be a table of adjusted $p$ values.


```r
with(
    tetris_data %>%
        mutate(effect = ___ - ___),
    pairwise.t.test(x = ___, g = ___, p.adjust.method = "bonferroni")
)
```

Each entry in the table is the result of a two-tailed independent samples T test testing the null hypothesis that the two groups have the same mean.  The row and column labels indicate which groups are being compared.  Each P value in the table has been multiplied by an adjustment factor according to the Bonferroni method.

a. What is the Bonferroni adjustment factor for these posthoc pairwise tests?
b. We retain our significance level of 0.05.  Which comparisons, if any, would lead us to reject the null hypothesis and conclude that there is a significance difference in means between conditions?
c. Do these results provide strong support reconsolidation theory?  Why do you think the post-hoc comparisons turned out the way they did, given the result of our ANOVA?

:::

## Wrap-up

Analysis of Variance, is used to address questions about whether multiple independent groups differ from one another on average.  The F statistic is used to summarize how much variability there is between groups versus the amount of variability within groups.  We used random permutation to simulate the kinds of data that would occur if the null hypothesis were true.  We used simulation as well as a mathematical model to determine whether the observed F statistic is large enough to reject the null hypothesis.
