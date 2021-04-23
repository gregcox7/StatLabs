# Comparing Independent Samples {#lab10}



<img src="img/baseball_field.png" width="100%" />

> Put umpteen people in two groups at random.<br>
> Social dynamics make changes in tandem:<br>
> Members within groups will quickly conform;<br>
> Difference between groups will soon be the norm.
>
> --- John Kruschke [@Kruschke2015]

In this session, we will see how to compare multiple independent samples in R.  Last time, we got a sense of how to compare two independent samples by using a $t$ test to test the null hypothesis that two samples come from populations with the same mean.  We will see a bit more of that in this session, but of course $t$ tests are limited to comparing just two samples at a time.  **Analysis of Variance (ANOVA)**, as we've seen, let's us compare multiple samples all at once.

In this session, we will cover

1. Doing independent samples $t$ tests in R.
2. Doing ANOVA in R.
3. Checking the assumptions of these tests.
4. Some neat tricks for manipulating data in R.
    + Using `mutate` to make new variables out of ones we already have.
    + Using `filter` to look at "subsets" of a whole dataset based on specific criteria.

Before we begin, let's make sure we get our hands on the `tidyverse` package, as well as the `infer` package we used last time.  We will also need the `magrittr` package.


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

## Get to know the data

The data for today's session hearkens back to where many of us (at least who grew up in the United States) first encountered the idea of "statistics": baseball.  These are batting records for Major League players in the 2018 season:


```r
batting <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/batting2018.csv")
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   Name = col_character(),
##   Team = col_character(),
##   Group = col_character(),
##   Position = col_character(),
##   Games_Played = col_double(),
##   AB = col_double(),
##   R = col_double(),
##   H = col_double(),
##   Doubles = col_double(),
##   Triples = col_double(),
##   HR = col_double(),
##   RBI = col_double(),
##   Walks = col_double(),
##   Strike_Outs = col_double()
## )
```

Click on the data in R's Environment pane to get a look.  Each row is a different player and each column tells us some useful information.  

* **Name**: The player's name.
* **Team**: The team for which the player played.
* **Group**: Depends on primary position played, groups them into infield, outfield, battery, and designated hitter.
* **Position**: The primary position played.  These are abbreviated:
    + 1B: First base
    + 2B: Second base
    + 3B: Third base
    + C: Catcher
    + CF: Center field
    + DH: Designated hitter
    + LF: Left field
    + P: Pitcher
    + RF: Right field
    + SS: Shortstop
* **Games_Played**: The number of games played in the 2018 regular seaosn.
* **AB**: Number of "at bats".
* **R**: Number of runs scored.
* **H**: Number of hits while at bat.
* etc.

To get a sense of where the different positions in baseball are, take a look at this picture:

<img src="img/baseball_positions.png" width="100%" />

### Batting average

A player's "batting average" is the *proportion* of times they made a hit while at bat.  For example, if a player had 400 at bats that season and had a hit 100 of those times, their batting average would be $100 / 400 = 0.25$.  Note that it is conventional in baseball stats to multiply that average by 1000 to get a number between 0 and 1000 instead of one between 0 and 1, but we'll just keep things simple and stick with using a standard proportion between 0 and 1.

If we were interested in studying the batting performance of just one player, we could use our old friend the *binomial* distribution.  After all, we have a number of repeated events (at-bats) each of which can have an outcome of interest (a hit).  But we are interested today in comparing different players, not studying the performance of a specific one.

In particular, we'd like to find the batting averages for every player in our dataset.  We have the relevant numbers already in our dataset in the H and AB columns.  Specifically, the batting average for each player is `H / AB`, the number of hits made divided by the number of opportunities (at-bats).  While we could do this by hand for each player, that would be pretty annoying.  Instead, we can use R to do that work using `mutate`:


```r
batting %>%
    mutate(AVG = H / AB)
```

```
## # A tibble: 984 x 15
##    Name      Team  Group Position Games_Played    AB     R     H Doubles Triples
##    <chr>     <chr> <chr> <chr>           <dbl> <dbl> <dbl> <dbl>   <dbl>   <dbl>
##  1 Allard, K ATL   Batt… P                   3     1     1     1       0       0
##  2 Gibson, K MIN   Batt… P                   1     2     2     2       0       0
##  3 Law, D    SF    Batt… P                   7     1     1     1       0       0
##  4 Nuno, V   TB    Batt… P                   1     2     0     2       0       0
##  5 Romero, E KC    Batt… P                   4     1     1     1       1       0
##  6 Rosario,… CHC   Batt… P                  43     1     1     1       0       0
##  7 Sobotka,… ATL   Batt… P                  14     1     0     1       0       0
##  8 Jennings… MIL   Batt… P                  65     3     1     2       1       0
##  9 Lavarnwa… PIT   Batt… C                   6     6     1     4       1       0
## 10 Bergman,… SEA   Batt… P                   1     2     0     1       0       0
## # … with 974 more rows, and 5 more variables: HR <dbl>, RBI <dbl>, Walks <dbl>,
## #   Strike_Outs <dbl>, AVG <dbl>
```

As usual, the first line told R what data we were working with (`batting`).  The second line `mutate`d two of the variables `H` and `AB` into `AVG`, each player's batting average.  Let's spend a bit of time on that `mutate` line, because it is extremely useful.

#### Making new variables with `mutate`

First, note that "AVG" is just the name that we decided.  We could replace "AVG" with a more descriptive name like "Batting_Average":


```r
batting %>%
    mutate(Batting_Average = H / AB)
```

```
## # A tibble: 984 x 15
##    Name      Team  Group Position Games_Played    AB     R     H Doubles Triples
##    <chr>     <chr> <chr> <chr>           <dbl> <dbl> <dbl> <dbl>   <dbl>   <dbl>
##  1 Allard, K ATL   Batt… P                   3     1     1     1       0       0
##  2 Gibson, K MIN   Batt… P                   1     2     2     2       0       0
##  3 Law, D    SF    Batt… P                   7     1     1     1       0       0
##  4 Nuno, V   TB    Batt… P                   1     2     0     2       0       0
##  5 Romero, E KC    Batt… P                   4     1     1     1       1       0
##  6 Rosario,… CHC   Batt… P                  43     1     1     1       0       0
##  7 Sobotka,… ATL   Batt… P                  14     1     0     1       0       0
##  8 Jennings… MIL   Batt… P                  65     3     1     2       1       0
##  9 Lavarnwa… PIT   Batt… C                   6     6     1     4       1       0
## 10 Bergman,… SEA   Batt… P                   1     2     0     1       0       0
## # … with 974 more rows, and 5 more variables: HR <dbl>, RBI <dbl>, Walks <dbl>,
## #   Strike_Outs <dbl>, Batting_Average <dbl>
```

Now the new column is called "Batting_Average" instead of "AVG".

We can use this to make some more variables as well.  Try using `mutate` to create a new variable called `Total_Bases` which will count the total number of bases earned by a player.  This number is equal to `H + Doubles + 2 * Triples + 3 * HR`.  After filling in the blank below, the result should look like the following:


```r
batting %>%
    mutate(Total_Bases = ___)
```


```
## # A tibble: 984 x 15
##    Name      Team  Group Position Games_Played    AB     R     H Doubles Triples
##    <chr>     <chr> <chr> <chr>           <dbl> <dbl> <dbl> <dbl>   <dbl>   <dbl>
##  1 Allard, K ATL   Batt… P                   3     1     1     1       0       0
##  2 Gibson, K MIN   Batt… P                   1     2     2     2       0       0
##  3 Law, D    SF    Batt… P                   7     1     1     1       0       0
##  4 Nuno, V   TB    Batt… P                   1     2     0     2       0       0
##  5 Romero, E KC    Batt… P                   4     1     1     1       1       0
##  6 Rosario,… CHC   Batt… P                  43     1     1     1       0       0
##  7 Sobotka,… ATL   Batt… P                  14     1     0     1       0       0
##  8 Jennings… MIL   Batt… P                  65     3     1     2       1       0
##  9 Lavarnwa… PIT   Batt… C                   6     6     1     4       1       0
## 10 Bergman,… SEA   Batt… P                   1     2     0     1       0       0
## # … with 974 more rows, and 5 more variables: HR <dbl>, RBI <dbl>, Walks <dbl>,
## #   Strike_Outs <dbl>, Total_Bases <dbl>
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1001"><strong>(\#exr:ex1001) </strong></span>
What code did you write to use `mutate` to create the new `Total_Bases` variable?
</div>\EndKnitrBlock{exercise}

#### Updating our data with new variables

So far, we've left our original `batting` dataset untouched because we haven't told R to remember the dataset with the new variables we've created.  Since we'll be using the batting average later, let's tell R to replace our original `batting` data with the updated version including the `AVG` column:


```r
batting <- batting %>%
    mutate(AVG = H / AB)
```

By adding `batting <-` to the beginning, we've told R to remember our updated data (with the new `AVG` column) under the same name (`batting`) as our original data.

### Batting average by position

Now let's see whether the batting average looks much different between different positions.  For example, we'd expect that pitchers would, in general, have pretty low batting averages because that's not their job.

To get a sense of the differences, we will make a set of histograms:


```r
batting %>%
    ggplot(aes(x = AVG)) +
    geom_histogram(binwidth = 0.05) +
    facet_wrap("Position")
```

<img src="10-indep_groups_files/figure-html/unnamed-chunk-10-1.png" width="672" />

That's pretty hard to interpret!  Let's add an option to the last line (`facet_wrap`) to help us out.  This option is `scales = "free_y"`, meaning that the `scale` of the vertical axes (the `y` axis) on each histogram are allowed to be different (they are "`free`"):


```r
batting %>%
    ggplot(aes(x = AVG)) +
    geom_histogram(binwidth = 0.05) +
    facet_wrap("Position", scales = "free_y")
```

<img src="10-indep_groups_files/figure-html/unnamed-chunk-11-1.png" width="672" />

This is a bit easier to see, and we can immediately tell there are some differences between different positions.

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1002"><strong>(\#exr:ex1002) </strong></span>
Why does the histogram for `DH` (Designated Hitter) look so different from the others? (Hint: look at the numbers on the vertical axis of the `DH` histogram.)  What seems to be different about the histogram for `P` (Pitchers)?
</div>\EndKnitrBlock{exercise}

To get a sense of what might be causing the unusual shape of the histogram for pitchers, let's construct another histogram that looks at `AB`, the number of at-bats.


```r
batting %>%
    ggplot(aes(x = ___)) +
    geom_histogram(binwidth = ___) +
    facet_wrap("Position", scales = "free_y")
```

<img src="10-indep_groups_files/figure-html/unnamed-chunk-13-1.png" width="672" />

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1003"><strong>(\#exr:ex1003) </strong></span>
What code did you use to make histograms for at-bats (`AB`)?  What did you pick for the `binwidth` and why?
</div>\EndKnitrBlock{exercise}

Based on these new histograms, it looks like Pitchers don't have nearly as many at-bats as players in other positions, so we don't have as many opportunities to see their batting ability.  This suggests that we can't think about pitchers the same way as we would other positions.

## Independent samples $t$ test: Infield vs. Outfield

We will first use an independent samples $t$ test to compare batting averages between infielders and outfielders.  An infielder is a player who plays a position within the bases (1B, 2B, 3B, and SS) while an outfielder is a player who plays a position further away (LF, CF, RF).  Designated hitters (DH) do not play on the field at all, and pitchers and catchers are considered part of a different category (the "battery").  These groupings are given by the **Group** variable in our dataset.

To compare just infielders to outfielders we need to **filter** our data so that it only contains players from those two groups.

### Filtering data with `filter`

R makes it easy to filter out data we don't need from a particular analysis.  The code for this is, helpfully, called `filter`.  Let's see it in operation:


```r
batting %>%
    filter(Group != "Battery")
```

```
## # A tibble: 511 x 15
##    Name     Team  Group  Position Games_Played    AB     R     H Doubles Triples
##    <chr>    <chr> <chr>  <chr>           <dbl> <dbl> <dbl> <dbl>   <dbl>   <dbl>
##  1 Vincej,… SEA   Infie… SS                  1     4     0     2       0       0
##  2 Zagunis… CHC   Outfi… RF                  5     5     0     2       1       0
##  3 Jones, R SF    Infie… 3B                  5     8     2     3       0       0
##  4 Betts, M BOS   Outfi… RF                136   520   129   180      47       5
##  5 Lagares… NYM   Outfi… CF                 30    59     9    20       1       1
##  6 Kang, J  PIT   Infie… 3B                  3     6     0     2       0       0
##  7 Straw, M HOU   Outfi… CF                  9     9     4     3       0       0
##  8 Martine… BOS   Outfi… LF                150   569   111   188      37       2
##  9 McNeil,… NYM   Infie… 2B                 63   225    35    74      11       6
## 10 Yelich,… MIL   Outfi… LF                147   574   118   187      34       7
## # … with 501 more rows, and 5 more variables: HR <dbl>, RBI <dbl>, Walks <dbl>,
## #   Strike_Outs <dbl>, AVG <dbl>
```

The second line `filters` the data according to the criteria in the parentheses.  The `!=` symbol means "not equal", so `Group != "Battery"` can be read as "group is not equal to battery (pitcher or catcher)".  The result of the filtering operation is a subset of the original data that excludes players with battery positions, i.e., pitchers and catchers.

We could also filter out designated hitters using a similar chunk of code.


```r
batting %>%
    filter(___)
```


```
## # A tibble: 978 x 15
##    Name      Team  Group Position Games_Played    AB     R     H Doubles Triples
##    <chr>     <chr> <chr> <chr>           <dbl> <dbl> <dbl> <dbl>   <dbl>   <dbl>
##  1 Allard, K ATL   Batt… P                   3     1     1     1       0       0
##  2 Gibson, K MIN   Batt… P                   1     2     2     2       0       0
##  3 Law, D    SF    Batt… P                   7     1     1     1       0       0
##  4 Nuno, V   TB    Batt… P                   1     2     0     2       0       0
##  5 Romero, E KC    Batt… P                   4     1     1     1       1       0
##  6 Rosario,… CHC   Batt… P                  43     1     1     1       0       0
##  7 Sobotka,… ATL   Batt… P                  14     1     0     1       0       0
##  8 Jennings… MIL   Batt… P                  65     3     1     2       1       0
##  9 Lavarnwa… PIT   Batt… C                   6     6     1     4       1       0
## 10 Bergman,… SEA   Batt… P                   1     2     0     1       0       0
## # … with 968 more rows, and 5 more variables: HR <dbl>, RBI <dbl>, Walks <dbl>,
## #   Strike_Outs <dbl>, AVG <dbl>
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1004"><strong>(\#exr:ex1004) </strong></span>
What code would filter out designated hitters?  *Hint: what is the abbreviation for designated hitters?*
</div>\EndKnitrBlock{exercise}

Finally, we can combine filters just by listing them.  The following bit of code filters out both pitchers and catchers, so the resulting data includes only infield and outfield players.


```r
batting %>%
    filter(Group != "Battery", Group != "DH")
```

```
## # A tibble: 505 x 15
##    Name     Team  Group  Position Games_Played    AB     R     H Doubles Triples
##    <chr>    <chr> <chr>  <chr>           <dbl> <dbl> <dbl> <dbl>   <dbl>   <dbl>
##  1 Vincej,… SEA   Infie… SS                  1     4     0     2       0       0
##  2 Zagunis… CHC   Outfi… RF                  5     5     0     2       1       0
##  3 Jones, R SF    Infie… 3B                  5     8     2     3       0       0
##  4 Betts, M BOS   Outfi… RF                136   520   129   180      47       5
##  5 Lagares… NYM   Outfi… CF                 30    59     9    20       1       1
##  6 Kang, J  PIT   Infie… 3B                  3     6     0     2       0       0
##  7 Straw, M HOU   Outfi… CF                  9     9     4     3       0       0
##  8 Martine… BOS   Outfi… LF                150   569   111   188      37       2
##  9 McNeil,… NYM   Infie… 2B                 63   225    35    74      11       6
## 10 Yelich,… MIL   Outfi… LF                147   574   118   187      34       7
## # … with 495 more rows, and 5 more variables: HR <dbl>, RBI <dbl>, Walks <dbl>,
## #   Strike_Outs <dbl>, AVG <dbl>
```

### Doing the $t$ test

Last time, we saw how to carry out the individual components of the computation involved in an independent samples $t$ test, but today we will see how to do it in a more streamlined form similar to how we did it with one-sample and paired samples $t$ tests last time.

First, let's make ourselves more histograms to get a sense of whether there is anything we should be concerned about in our data


```r
batting %>%
    filter(Group != "Battery", Group != "DH") %>%
    ggplot(aes(x = AVG)) +
    geom_histogram(binwidth=0.05) +
    facet_wrap("Group", scales = "free_y")
```

<img src="10-indep_groups_files/figure-html/unnamed-chunk-18-1.png" width="672" />

Nothing too wonky, so we should be good to go to conduct our $t$ test.

#### State your hypotheses

Our **research question** is, "is there a difference in batting averages between infield and outfield players?"  Because our research question is about *any* kind of difference, we will be doing a **two-sided** test.  Specifically, our **null hypothesis** is that there is no difference in the population mean batting average for infielders and outfielders ($H_0$: $\mu_1 - \mu_2 = 0$) while our **alternative hypothesis** is that there is some difference ($H_1$: $\mu_1 - \mu_2 \neq 0$).

#### Set your alpha level

Let's choose an **alpha level of 0.05**.

#### Find the $t$ value

We will use the `infer` package to visualize the $t$ test like last time.  First, we need to get our $t$ value:


```r
t_value <- batting %>%
    filter(Group != "Battery", Group != "DH") %>%
    specify(AVG ~ Group) %>%
    calculate(stat = 't')
```

```
## Warning: The statistic is based on a difference or ratio; by default, for
## difference-based statistics, the explanatory variable is subtracted in the
## order "Infield" - "Outfield", or divided in the order "Infield" / "Outfield"
## for ratio-based statistics. To specify this order yourself, supply `order =
## c("Infield", "Outfield")` to the calculate() function.
```

We told R to remember the result under the label `t_value`.  Aside from that, the first two lines are the same as above and tell R what data we are working with; it takes two lines because the second line is the `filter`ing operation.  The third line looks interesting:  Remember that last time we used `specify` to tell R what our "response" variable was.  Now, we have both a response variable and an "explanatory" variable, `Group`.  By "explanatory", we mean that the `Group` variable is what divides the response variable into two independent groups, and we are seeing if that variable *explains* differences between those groups.  `AVG ~ Group` says that the variable on the left of the `~` (`AVG`) is the **response** variable (the one we want to analyze) and the variable on the right (`Group`) is what we are testing to see if it **explains** differences in our response variable.  Finally, the last line just tells R to calculate the $t$ statistic.

#### Find the $p$ value

We can now visualize where our sample falls on the appropriate $t$ distribution:


```r
batting %>%
    filter(Group != "Battery", Group != "DH") %>%
    specify(AVG ~ Group) %>%
    hypothesize(null = 'point', mu = 0) %>%
    visualize(method = 'theoretical') +
    shade_p_value(obs_stat = t_value, direction = 'two-sided')
```

```
## Warning: Check to make sure the conditions have been met for the theoretical
## method. {infer} currently does not check these for you.
```

<img src="10-indep_groups_files/figure-html/unnamed-chunk-20-1.png" width="672" />

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1005"><strong>(\#exr:ex1005) </strong></span>
Based on the plot above and the amount of the $t$ distribution that is shaded in, do you think our $p$ value will be relatively high or relatively low?
    </div>\EndKnitrBlock{exercise}

Finally, let's get our full $t$ test results:


```r
batting %>%
    filter(Group != "Battery", Group != "DH") %>%
    t_test(AVG ~ Group,
           alternative = 'two-sided',
           var.equal = TRUE,
           mu = 0,
           conf_level = 0.95)
```

```
## Warning: The statistic is based on a difference or ratio; by default, for
## difference-based statistics, the explanatory variable is subtracted in the
## order "Infield" - "Outfield", or divided in the order "Infield" / "Outfield"
## for ratio-based statistics. To specify this order yourself, supply `order =
## c("Infield", "Outfield")`.
```

```
## # A tibble: 1 x 6
##   statistic  t_df p_value alternative lower_ci upper_ci
##       <dbl> <dbl>   <dbl> <chr>          <dbl>    <dbl>
## 1     0.592   503   0.554 two.sided   -0.00764   0.0142
```

As above, the first two lines tell R what data to use.  The remaining lines tell R all about the `t_test` we want to perform.  First, we use `AVG ~ Group` to say that we are testing a null hypothesis about how `AVG` differs between different values of `Group`.  We are doing a test with an `alternative` hypothesis that is `two-sided`; that the mean difference according to the null hypothesis is `mu = 0`; and that our confidence level (`conf_level`) is 0.95, which is one minus our alpha level.  The `var.equal = TRUE` line tells R that we are assuming the population `var`iances are `equal` between the two groups, so we can use the pooled sample standard deviation.  If we had reason to believe the variances were not equal between groups, we could say `var.equal = FALSE` instead, like so:


```r
batting %>%
    filter(Group != "Battery", Group != "DH") %>%
    t_test(AVG ~ Group,
           alternative = 'two-sided',
           var.equal = FALSE,
           mu = 0,
           conf_level = 0.95)
```

```
## Warning: The statistic is based on a difference or ratio; by default, for
## difference-based statistics, the explanatory variable is subtracted in the
## order "Infield" - "Outfield", or divided in the order "Infield" / "Outfield"
## for ratio-based statistics. To specify this order yourself, supply `order =
## c("Infield", "Outfield")`.
```

```
## # A tibble: 1 x 6
##   statistic  t_df p_value alternative lower_ci upper_ci
##       <dbl> <dbl>   <dbl> <chr>          <dbl>    <dbl>
## 1     0.590  473.   0.556 two.sided   -0.00768   0.0143
```

We won't get into the mathematics for this, but just point out that it is an option.  For our purposes, we will always use `var.equal = TRUE`.

#### Decide whether or not to reject the null hypothesis

Based on the $p$ value and our alpha level above, we **fail to reject** the null hypothesis.  We have no reason to believe that infielders and outfielders have different batting averages.

## Analysis of Variance: Batting average by position

Maybe infielders and outfielders as two big groups don't differ in their batting average.  But what if we took a closer look and compared by specific positions?  And what about the positions that we didn't include before, pitchers, catchers, and designated hitters?  To compare multiple independent samples, we will use **Analysis of Variance (ANOVA)**.

### Doing the ANOVA

As we've seen, the steps of ANOVA are broadly similar to any other hypothesis test.

#### State your hypotheses

Our **research question** is, "is there a difference in batting average between positions?"  Our **null hypothesis** is that the population mean batting average is the same for all positions ($H_0$: $\mu_{1B} = \mu_{2B} = \cdots = \mu_{SS}$).  Our **alternative hypothesis** is that there is at least one position with a different population mean batting average from the others.

#### Set your alpha level

Again, let's keep our **alpha level of 0.05**.

#### Find the $F$ value

Similar to above, we can use R not only to find the $F$ value for our data, but to visualize where it falls on the distribution of $F$ values that we would observe if the null hypothesis were true.


```r
F_value <- batting %>%
    specify(AVG ~ Position) %>%
    calculate(stat = "F")
```

The block of code above calculated the $F$ value and told R to remember it under the label `F_value`.  As usual, we began by telling R what data to work with (`batting`), then `specify` that our response variable is `AVG` and our explanatory variable is `Position`.  Again, by "explanatory", we mean that we are testing to see how well differences in the response variable can be "explained by" the fact that they came from different groups defined by the explanatory variable (`Position`).  Finally, we get the $F$ value.

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1006"><strong>(\#exr:ex1006) </strong></span>
Compare the code we just used to find `F_value` with the code we used above to find the `t_value` (comparing infielders and outfielders).  What is similar and what is different?  Is there a difference in how we told R what data to use?  Is there a difference in how we "specified" the response variable and explanatory variable?  Is there a difference in what we told R to "calculate"?
    </div>\EndKnitrBlock{exercise}

Let's check out that $F$ value now


```r
F_value
```

```
## # A tibble: 1 x 1
##    stat
##   <dbl>
## 1  33.4
```

#### Find the $p$ value

The following code let's us visualize the $F$ value for our data relative to the distribution of $F$ values that we would expect to see if the null hypothesis were true:


```r
batting %>%
  specify(AVG ~ Position) %>%
  hypothesize(null = "independence") %>%
  visualize(method = "theoretical") +
  shade_p_value(F_value, direction = "greater")
```

```
## Warning: Check to make sure the conditions have been met for the theoretical
## method. {infer} currently does not check these for you.
```

<img src="10-indep_groups_files/figure-html/unnamed-chunk-25-1.png" width="672" />

It's pretty clear that our $F$ value is way out there!

But let's finally get our ANOVA table so we can see the $p$ value:


```r
batting %$%
    lm(AVG ~ Position) %>%
    anova()
```

```
## Analysis of Variance Table
## 
## Response: AVG
##            Df  Sum Sq Mean Sq F value    Pr(>F)    
## Position    9  4.1771 0.46413  33.392 < 2.2e-16 ***
## Residuals 974 13.5378 0.01390                      
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The block of code above is how to do ANOVA in R.  As usual, we first tell R what data to work with (`batting`).  In the second line, we again define our response variable (`AVG`) and explanatory variable (`Position`) using the `~`.  Finally, the last line tells R to do an `anova`.

There are two things to note:  First, the connection between the first and second lines uses the `$%$` symbol.  The reason for this is not so critical in this class, but this is something to check if you ever encounter a problem.  Second, the second line begins with `lm`, rather than `specify`.  As we will see, `lm` is an important function in R that is used for other things too.

Anyway, the output we get from R is a familiar ANOVA table and we can read from it that our $p$ value is extremely low, essentially equal to 0.  In other words, if the null hypothesis were true, a result like ours would be exceedingly unlikely.

#### Decide whether or not to reject the null hypothesis

Based on the fact that the $p$ value is much less than our alpha level, we **reject** the null hypothesis.  We have reason to believe that batting averages do differ between different positions.

### Post hoc pairwise tests

Since we rejected the null hypothesis at the end of our ANOVA, let's use post hoc pairwise $t$ tests to see which specific pairs of positions are likely to differ from one another.  We can get some sense of this by looking at the sample mean batting averages for each position:


```r
batting %>%
    group_by(Position) %>%
    summarize(M = mean(AVG))
```

```
## # A tibble: 10 x 2
##    Position      M
##    <chr>     <dbl>
##  1 1B       0.243 
##  2 2B       0.226 
##  3 3B       0.234 
##  4 C        0.219 
##  5 CF       0.223 
##  6 DH       0.248 
##  7 LF       0.241 
##  8 P        0.0952
##  9 RF       0.227 
## 10 SS       0.235
```

Hmm, it certainly looks like there's one particularly low mean relative to the others.  But to know whether we have statistical evidence for these differences, we use the following code in R to conduct post-hoc pairwise $t$ tests:


```r
batting %$%
    pairwise.t.test(
        x = AVG,
        g = Position,
        p.adjust.method = 'bonferroni'
    )
```

```
## 
## 	Pairwise comparisons using t tests with pooled SD 
## 
## data:  AVG and Position 
## 
##    1B      2B      3B      C       CF      DH    LF      P       RF   
## 2B 1.000   -       -       -       -       -     -       -       -    
## 3B 1.000   1.000   -       -       -       -     -       -       -    
## C  1.000   1.000   1.000   -       -       -     -       -       -    
## CF 1.000   1.000   1.000   1.000   -       -     -       -       -    
## DH 1.000   1.000   1.000   1.000   1.000   -     -       -       -    
## LF 1.000   1.000   1.000   1.000   1.000   1.000 -       -       -    
## P  < 2e-16 < 2e-16 < 2e-16 < 2e-16 4.2e-16 0.074 < 2e-16 -       -    
## RF 1.000   1.000   1.000   1.000   1.000   1.000 1.000   < 2e-16 -    
## SS 1.000   1.000   1.000   1.000   1.000   1.000 1.000   < 2e-16 1.000
## 
## P value adjustment method: bonferroni
```

Notice that, again, we connected the first and second lines with `%$%`.  By telling R `x = AVG`, we were saying that our response variable is `AVG`.  By telling R `g = Position`, we were saying that the explanatory variable is `Position`.  Finally, we told R to adjust the $p$ values for each of our pairwise $t$ tests using the `bonferroni` correction we discussed in class.

The result is a big matrix of $p$ values.  To see which pairs of groups are statistically significantly different from one another, we compare each $p$ value against our alpha level (0.05); as usual, if the $p$ value in the matrix is less than our alpha level, we can reject the null hypothesis that there is no difference on average.

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1007"><strong>(\#exr:ex1007) </strong></span>
Based on the $p$ values in the table above, for which pairs of positions would we reject the null hypothesis?  Does this outcome make sense based on the sample means we found above, and the histograms we made at the beginning?
</div>\EndKnitrBlock{exercise}

### No Pitchers Allowed?

At the beginning of the session, we saw that the batting averages for pitchers seemed odd relative to other positions, largely because they are not at bat as often.  And we saw with our post hoc pairwise tests that all the statistically significant pairwise differences between positions involved pitchers.  If we excluded pitchers from the set of groups being compared, would we still have evidence that positions differ in batting average?

Let's see!  You will need to add a line to our ANOVA code that filters out pitchers.  You'll need to fill in the blank part of the following slice of code:


```r
batting %>%
    filter(___) %$%
    lm(AVG ~ Position) %>%
    anova()
```

The result of running your new ANOVA will be the following:


```
## Analysis of Variance Table
## 
## Response: AVG
##            Df  Sum Sq   Mean Sq F value Pr(>F)
## Position    8 0.04273 0.0053411  1.2699 0.2563
## Residuals 617 2.59505 0.0042059
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1008"><strong>(\#exr:ex1008) </strong></span>
What code did you write to do an ANOVA with `AVG` as the response variable and `Position` as the explanatory variable, but first using a `filter` to exclude pitchers?  *Hint: Look at how we filtered out specific groups of positions earlier in the session, and remember the abbreviation for "Pitcher".*
    </div>\EndKnitrBlock{exercise}

### Slugging Average

It looks like, if pitchers are excluded, we no longer have any evidence that positions differ in their batting averages, since we would fail to reject the null hypothesis at our alpha level of 0.05.

But maybe we would find evidence for a difference in some other measure of batting performance?  Let's use `mutate` to once again create a new variable for us to analyze, this time the "slugging average".  The slugging average is the average number of bases made on each at-bat.  The slugging average is therefore a more sensitive measure of batting ability than just the batting average, because it takes into account how *good* a hit was, not just whether it was made.

The slugging average is the total number of bases won (which we found above) divided by the number of at-bats.


```r
batting <- batting %>%
    mutate(SLG = (H + Doubles + 2 * Triples + 3 * HR) / AB)
```

#### Inspecting the data

First, let's get a sense of the central tendency (mean) and variability (standard deviation) of the slugging average for each position:


```r
batting %>%
    group_by(Position) %>%
    summarize(M = mean(SLG), S = sd(SLG))
```

```
## # A tibble: 10 x 3
##    Position     M      S
##    <chr>    <dbl>  <dbl>
##  1 1B       0.431 0.0979
##  2 2B       0.349 0.111 
##  3 3B       0.397 0.148 
##  4 C        0.336 0.114 
##  5 CF       0.354 0.119 
##  6 DH       0.441 0.0528
##  7 LF       0.399 0.113 
##  8 P        0.123 0.237 
##  9 RF       0.374 0.128 
## 10 SS       0.355 0.110
```

Next, let's construct a set of histograms so we can get a sense of whether there are any outliers or if any of the groups look like they might be very different from the others.  We will modify the code we used above for `AVG`, so you'll need to fill in the blanks to get something like the result below (play around with different `binwidth`s until you find one that seems good):


```r
batting %>%
    ggplot(aes(x = ___)) +
    geom_histogram(binwidth = ___) +
    facet_wrap("Position", scales = "free_y")
```

<img src="10-indep_groups_files/figure-html/unnamed-chunk-34-1.png" width="672" />

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1009"><strong>(\#exr:ex1009) </strong></span>
What code did you write to make something like the set of histograms above?  What did you choose for your `binwidth`?
</div>\EndKnitrBlock{exercise}

Again, there might be something weird about pitchers, so we'll try the ANOVA both with and without including them.

#### ANOVA including pitchers

First, let's run the ANOVA including all positions, including pitchers.  Remember that we are now using slugging average (`SLG`) as the response variable.  Fill in the blank to get the result below.


```r
batting %$%
    lm(___ ~ Position) %>%
    anova()
```


```
## Analysis of Variance Table
## 
## Response: SLG
##            Df Sum Sq Mean Sq F value    Pr(>F)    
## Position    9 14.549 1.61659  54.954 < 2.2e-16 ***
## Residuals 974 28.652 0.02942                      
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

Again, an extremely unlikely result if the null hypothesis were true!  As a result, we reject the null hypothesis and can move on to conducting post hoc pairwise tests to see which groups differ from one another.  Again, fill in the blank to get the result below:


```r
batting %$%
    pairwise.t.test(
        x = ___,
        g = Position,
        p.adjust.method = 'bonferroni'
    )
```


```
## 
## 	Pairwise comparisons using t tests with pooled SD 
## 
## data:  SLG and Position 
## 
##    1B      2B      3B      C       CF      DH      LF      P       RF     
## 2B 0.24483 -       -       -       -       -       -       -       -      
## 3B 1.00000 1.00000 -       -       -       -       -       -       -      
## C  0.02683 1.00000 0.82864 -       -       -       -       -       -      
## CF 0.43912 1.00000 1.00000 1.00000 -       -       -       -       -      
## DH 1.00000 1.00000 1.00000 1.00000 1.00000 -       -       -       -      
## LF 1.00000 1.00000 1.00000 0.72424 1.00000 1.00000 -       -       -      
## P  < 2e-16 < 2e-16 < 2e-16 < 2e-16 < 2e-16 0.00034 < 2e-16 -       -      
## RF 1.00000 1.00000 1.00000 1.00000 1.00000 1.00000 1.00000 < 2e-16 -      
## SS 0.60442 1.00000 1.00000 1.00000 1.00000 1.00000 1.00000 < 2e-16 1.00000
## 
## P value adjustment method: bonferroni
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1010"><strong>(\#exr:ex1010) </strong></span>
What did you put in the blank to get the correct pairwise $t$ test result?  This time, do you see any $p$ values less than our alpha level (0.05) that do *not* involve pitchers?  What pairs of positions have differences in slugging average that are statistically significant?
</div>\EndKnitrBlock{exercise}

#### ANOVA excluding pitchers

Just to be on the safe side, let's see how that ANOVA would turn out if we had excluded pitchers.  Now we need to insert a `filter` line.  Fill in the blanks below to conduct the ANOVA:


```r
batting %>%
    filter(___) %$%
    lm(___ ~ Position) %>%
    anova()
```


```
## Analysis of Variance Table
## 
## Response: SLG
##            Df Sum Sq  Mean Sq F value    Pr(>F)    
## Position    8 0.5611 0.070142  5.0045 4.961e-06 ***
## Residuals 617 8.6478 0.014016                      
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1011"><strong>(\#exr:ex1011) </strong></span>
What code did you write to do an ANOVA using `SLG` as the response variable instead of `AVG`?
</div>\EndKnitrBlock{exercise}

Interesting!  Again, a result that would be very unlikely if the null hypothesis were true, even though we have excluded pitchers from the set of groups being compared.  Time for some post hoc pairwise tests...


```r
batting %>%
    filter(___) %$%
    pairwise.t.test(
        x = ___,
        g = Position,
        p.adjust.method = 'bonferroni'
    )
```


```
## 
## 	Pairwise comparisons using t tests with pooled SD 
## 
## data:  SLG and Position 
## 
##    1B      2B     3B     C      CF     DH     LF     RF    
## 2B 0.0022  -      -      -      -      -      -      -     
## 3B 1.0000  0.4605 -      -      -      -      -      -     
## C  2.8e-05 1.0000 0.0240 -      -      -      -      -     
## CF 0.0069  1.0000 0.9977 1.0000 -      -      -      -     
## DH 1.0000  1.0000 1.0000 1.0000 1.0000 -      -      -     
## LF 1.0000  0.3669 1.0000 0.0184 0.8056 1.0000 -      -     
## RF 0.1957  1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 -     
## SS 0.0129  1.0000 1.0000 1.0000 1.0000 1.0000 1.0000 1.0000
## 
## P value adjustment method: bonferroni
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1012"><strong>(\#exr:ex1012) </strong></span>
What code did you use to do the post hoc pairwise tests above?  Which pairs of positions have different slugging averages using an alpha level of 0.05?  Why are we able to detect differences that we couldn't before when we had included pitchers?  (*Hint: remember that the Bonferroni correction depends on the number of possible pairs.*)
</div>\EndKnitrBlock{exercise}

## Wrap-up

In this session, we have seen how to compare independent samples in R.  We can compare two independent samples using a **$t$ test**.  We can compare multiple independent samples using **Analysis of Variance (ANOVA)**.  If the result of our ANOVA leads us to reject the null hypothesis, then we can proceed to conduct **post hoc pairwise $t$ tests** using the **Bonferroni correction** to avoid inflating our probability of making a Type I error.
