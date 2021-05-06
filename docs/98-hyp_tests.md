# Hypothesis Tests {#hyptests}



## $t$ tests

### Doing them step-by-step

#### One-sample $t$ test

For the following example, I've labeled the collection of observed data as `X`.  If you put your own collection of values under the same label, the following code will give you what you need to do a $t$ test on your own data.


```r
X <- c(-0.58, 1.02, 1.25, -0.02, 1.15)
```

1. Translate your **research question** into a **null** and **alternative** hypothesis.

I will assume in this example that the population mean if the null hypothesis is true is $\mu = 0$, but you can replace this with your own `null_mean` as you need.


```r
null_mean <- 0
```

2. Decide on an **alpha level**.

3. Find the $t$ value ($t = \frac{\bar{X} - \mu}{\hat{\sigma} / \sqrt{N}}$):


```r
t <- (mean(X) - null_mean) / (sd(X) / sqrt(length(X)))
```

4. Find the $p$ value.

Direction of test    | Is $t$ value positive or negative? | Code
---------------------|------------------------------------|------------------------------------
One-tailed (less)    | NA                                 | `pt(q = t, df = length(X) - 1)`
One-tailed (greater) | NA                                 | `1 - pt(q = t, df = length(X) - 1)`
Two-tailed           | Positive                           | `2 * (1 - pt(q = t, df = length(X) - 1))`
Two-tailed           | Negative                           | `2 * pt(q = t, df = length(X) - 1)`

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.

#### Paired samples $t$ test

For the following example, I've labeled the pairs of observed values as `X_1` and `X_2`.  If you put your own collection of values under the same labels, the following code will give you what you need to do a $t$ test on your own data.


```r
X_1 <- c(-0.58, 1.02, 1.25, -0.02, 1.15)
X_2 <- c(-2.05, -0.92, -1.18, -0.16, 0.73)
```

We then need to get the *difference* between each pair of values, like so:


```r
D <- X_1 - X_2
```

Remember to keep track of the order in which you did the subtraction!

1. Translate your **research question** into a **null** and **alternative** hypothesis.

I will assume in this example that the population mean difference if the null hypothesis is true is $\mu_D = 0$, since this is the most common use for a paired-sample $t$ test, but you can replace this with your own `null_mean` as you need.


```r
null_mean <- 0
```

2. Decide on an **alpha level**.

3. Find the $t$ value ($t = \frac{\bar{D} - \mu_D}{\hat{\sigma}_D / \sqrt{N}}$).


```r
t <- (mean(D) - null_mean) / (sd(D) / sqrt(length(D)))
```

4. Find the $p$ value.

Direction of test    | Is $t$ value positive or negative? | Code
---------------------|------------------------------------|------------------------------------
One-tailed (less)    | NA                                 | `pt(q = t, df = length(D) - 1)`
One-tailed (greater) | NA                                 | `1 - pt(q = t, df = length(D) - 1)`
Two-tailed           | Positive                           | `2 * (1 - pt(q = t, df = length(D) - 1))`
Two-tailed           | Negative                           | `2 * pt(q = t, df = length(D) - 1)`

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.

#### Independent samples $t$ test

For the following example, I've labeled the pairs of observed values as `X_1` and `X_2`.  Note that they are different from above and that they are not the same size.  If you put your own collection of values under the same labels, the following code will give you what you need to do a $t$ test on your own data.


```r
X_1 <- c(-0.87, -0.13, 0.13, -0.14, -0.45, -1)
X_2 <- c(0.06, -0.99, 0.47, 0.86, 0.06)
```

1. Translate your **research question** into a **null** and **alternative** hypothesis.

I will assume in this example that the difference in population means if the null hypothesis is true is $\mu_1 - \mu_2 = 0$, since this is the most common use for a independent samples $t$ test, but you can replace this with your own `null_mean` as you need.


```r
null_mean <- 0
```

2. Decide on an **alpha level**.

3. Find the $t$ value.

First, we need to find the pooled sample standard deviation ($\hat{\sigma}_P = \sqrt{\frac{df_1 \hat{\sigma}_1^2 + df_2 \hat{\sigma}_2^2}{df_1 + df_2}}$)


```r
df_1 <- length(X_1) - 1
df_2 <- length(X_2) - 1

sd_pooled <- sqrt((df_1 * sd(X_1)^2 + df_2 * sd(X_2)^2) / (df_1 + df_2))
```

Now we can get the $t$ value ($t = \frac{\bar{X}_1 - \bar{X}_2 - (\mu_1 - \mu_2)}{\hat{\sigma}_P \sqrt{\frac{1}{N_1} + \frac{1}{N_2}}}$):


```r
t <- (mean(X_1) - mean(X_2) - null_mean) / (sd_pooled * sqrt(1 / length(X_1) + 1 / length(X_2)))
```

4. Find the $p$ value.

Direction of test    | Is $t$ value positive or negative? | Code
---------------------|------------------------------------|------------------------------------
One-tailed (less)    | NA                                 | `pt(q = t, df = df_1 + df_2)`
One-tailed (greater) | NA                                 | `1 - pt(q = t, df = df_1 + df_2)`
Two-tailed           | Positive                           | `2 * (1 - pt(q = t, df = df_1 + df_2))`
Two-tailed           | Negative                           | `2 * pt(q = t, df = df_1 + df_2)`

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.

### Doing them all at once

If we're going to do $t$ tests all at once, we need to make sure we have loaded the `tidyverse` and `infer` packages:


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
```

#### One-sample $t$ test

In this example, I'll use some simple artificial data:


```r
my_data <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/one_sample_t_test_data.csv")
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   ID = col_double(),
##   X = col_double()
## )
```


```r
my_data
```

```
## # A tibble: 5 x 2
##      ID     X
##   <dbl> <dbl>
## 1     1 -0.58
## 2     2  1.02
## 3     3  1.25
## 4     4 -0.02
## 5     5  1.15
```

1. Translate your **research question** into a **null** and **alternative** hypothesis.

I will assume in this example that the population mean according to our null hypothesis is $\mu = 0$, but you can change this as you need:


```r
null_mean <- 0
```

2. Decide on an **alpha level**.

I will tell R to remember our choice of alpha level like so:


```r
alpha_level <- 0.05
```

3. Find the $t$ value.

4. Find the $p$ value.

Both the previous two steps are accomplished in the same chunk of code:


```r
my_data %>%
    t_test(
        response = X,
        alternative = "two.sided",
        mu = null_mean,
        conf_level = 1 - alpha_level
    )
```

```
## # A tibble: 1 x 6
##   statistic  t_df p_value alternative lower_ci upper_ci
##       <dbl> <dbl>   <dbl> <chr>          <dbl>    <dbl>
## 1      1.54     4   0.198 two.sided     -0.451     1.58
```

To do this with your own data, make sure to tell R the name of your dataset (replace `my_data`) and the name of your response variable (replace `X`).  And make sure R is remembering the correct values for `null_mean` and `alpha_level`, which we set in steps 1 and 2 above.

You will need to change what you put for `alternative` depending on your null and alternative hypotheses:

Direction of test    | Code                       
---------------------|----------------------------
One-tailed (less)    | `alternative = "less"` 
One-tailed (greater) | `alternative = "greater"`
Two-tailed           | `alternative = "two.sided"`

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.

#### Paired samples $t$ test

In this example, I'll use some simple artificial data:


```r
my_data <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/paired_sample_t_test_data.csv")
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   ID = col_double(),
##   X_1 = col_double(),
##   X_2 = col_double()
## )
```


```r
my_data
```

```
## # A tibble: 5 x 3
##      ID   X_1   X_2
##   <dbl> <dbl> <dbl>
## 1     1 -0.58 -2.05
## 2     2  1.02 -0.92
## 3     3  1.25 -1.18
## 4     4 -0.02 -0.16
## 5     5  1.15  0.73
```

**Preliminary step:** If the data does not already have a variable for the difference scores, we need to create it using the `mutate` function and then tell R to update the original data.


```r
my_data <- my_data %>%
    mutate(D = X_1 - X_2)
```

1. Translate your **research question** into a **null** and **alternative** hypothesis.

I will assume in this example that the population mean according to our null hypothesis is $\mu_D = 0$, but you can change this as you need:


```r
null_mean <- 0
```

2. Decide on an **alpha level**.

I will tell R to remember our choice of alpha level like so:


```r
alpha_level <- 0.05
```

3. Find the $t$ value.

4. Find the $p$ value.

Both the previous two steps are accomplished in the same chunk of code:


```r
my_data %>%
    t_test(
        response = D,
        alternative = "two.sided",
        mu = null_mean,
        conf_level = 1 - alpha_level
    )
```

```
## # A tibble: 1 x 6
##   statistic  t_df p_value alternative lower_ci upper_ci
##       <dbl> <dbl>   <dbl> <chr>          <dbl>    <dbl>
## 1      2.92     4  0.0431 two.sided     0.0645     2.50
```

To do this with your own data, make sure to tell R the name of your dataset (replace `my_data`) and the name of your response variable (replace `D`).  And make sure R is remembering the correct values for `null_mean` and `alpha_level`, which we set in steps 1 and 2 above.

You will need to change what you put for `alternative` depending on your null and alternative hypotheses:

Direction of test    | Code                       
---------------------|----------------------------
One-tailed (less)    | `alternative = "less"` 
One-tailed (greater) | `alternative = "greater"`
Two-tailed           | `alternative = "two.sided"`

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.

#### Independent samples $t$ test

In this example, I'll use some simple artificial data:


```r
my_data <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/indep_samples_t_test_data.csv")
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   ID = col_double(),
##   Group = col_double(),
##   X = col_double()
## )
```


```r
my_data
```

```
## # A tibble: 11 x 3
##       ID Group     X
##    <dbl> <dbl> <dbl>
##  1     1     1 -0.87
##  2     2     1 -0.13
##  3     3     1  0.13
##  4     4     1 -0.14
##  5     5     1 -0.45
##  6     6     1 -1   
##  7     7     2  0.06
##  8     8     2 -0.99
##  9     9     2  0.47
## 10    10     2  0.86
## 11    11     2  0.06
```

1. Translate your **research question** into a **null** and **alternative** hypothesis.

I will assume in this example that the population mean according to our null hypothesis is $\mu_1 - \mu_2 = 0$, but you can change this as you need:


```r
null_mean <- 0
```

2. Decide on an **alpha level**.

I will tell R to remember our choice of alpha level like so:


```r
alpha_level <- 0.05
```

3. Find the $t$ value.

4. Find the $p$ value.

Both the previous two steps are accomplished in the same chunk of code:


```r
my_data %>%
    t_test(
        X ~ Group,
        alternative = "two.sided",
        mu = null_mean,
        var.equal = TRUE,
        conf_level = 1 - alpha_level
    )
```

```
## Warning: The statistic is based on a difference or ratio; by default, for
## difference-based statistics, the explanatory variable is subtracted in the order
## "1" - "2", or divided in the order "1" / "2" for ratio-based statistics. To
## specify this order yourself, supply `order = c("1", "2")`.
```

```
## # A tibble: 1 x 6
##   statistic  t_df p_value alternative lower_ci upper_ci
##       <dbl> <dbl>   <dbl> <chr>          <dbl>    <dbl>
## 1     -1.46     9   0.179 two.sided      -1.28    0.277
```

To do this with your own data, make sure to tell R the name of your dataset (replace `my_data`), the name of your response variable (replace `X`), and the name of your explanatory variable that designates which of the two samples each observation came from (replace `Group`).  And make sure R is remembering the correct values for `null_mean` and `alpha_level`, which we set in steps 1 and 2 above.

In the above example, we assumed that the variances between the two groups were approximately equal; this is what the line `var.equal = TRUE` means.  If we have reason to believe they are not equal, we can say `var.equal = FALSE`, but we won't be using that option in this course.

You will need to change what you put for `alternative` depending on your null and alternative hypotheses:

Direction of test    | Code                       
---------------------|----------------------------
One-tailed (less)    | `alternative = "less"` 
One-tailed (greater) | `alternative = "greater"`
Two-tailed           | `alternative = "two.sided"`

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.

## Analysis of Variance (ANOVA)

As we've seen, ANOVA is not something that is typically done by hand, so we will only illustrate how to do it all at once.  To do ANOVA, we need to load both the `tidyverse` and the `magrittr` packages from R's library:


```r
library(tidyverse)
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

As we've seen, ANOVA has two stages:  First, we conduct an ANOVA to see if we have evidence that groups tend to differ from one another on average.  Second, if we are able to reject the null hypothesis with our ANOVA, we move on to conduct post hoc pairwise $t$ tests to see if we have evidence about which groups differ from one another.

For these examples, we will use a simple example dataset:


```r
my_data <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/anova_data.csv")
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   ID = col_double(),
##   Group = col_double(),
##   X = col_double()
## )
```

This is what this example looks like:


```r
my_data
```

```
## # A tibble: 15 x 3
##       ID Group     X
##    <dbl> <dbl> <dbl>
##  1     1     1 -0.58
##  2     2     1 -0.29
##  3     3     1 -1.01
##  4     4     1 -1.81
##  5     5     1 -0.47
##  6     6     1 -0.23
##  7     7     2 -0.21
##  8     8     2  0.96
##  9     9     2  0.5 
## 10    10     2  0.8 
## 11    11     3  0.68
## 12    12     3  0.53
## 13    13     3 -0.31
## 14    14     3  1.53
## 15    15     3  0.52
```

### ANOVA

1. Translate your **research question** into a **null** and **alternative** hypothesis.

As we've seen, this part is easy because the null hypothesis in ANOVA is always the same:  The null hypothesis is that all samples come from populations that have equal means ($H_0$: $\mu_1 = \mu_2 = \cdots = \mu_G$).  The alternative hypothesis is that the samples come from populations with means that are not all equal; in other words, at least one population mean is different from the others.

2. Decide on an **alpha level**.

Let's assume that we have adopted an alpha level of 0.05.

3. Find the $F$ value.

4. Find the $p$ value.

Both the previous two steps are accomplished in the same chunk of code:


```r
my_data %$%
    lm(X ~ Group) %>%
    anova()
```

```
## Analysis of Variance Table
## 
## Response: X
##           Df Sum Sq Mean Sq F value  Pr(>F)   
## Group      1 4.9824  4.9824  12.245 0.00392 **
## Residuals 13 5.2897  0.4069                   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

To do this with your own data, make sure to tell R the name of your dataset (replace `my_data`), the name of your response variable (replace `X`), and the name of your explanatory variable that designates which sample each observation came from (replace `Group`).

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.

### Post hoc pairwise $t$ tests

If we reject the ANOVA null hypothesis (as we did in the above example), then we proceed to do "post hoc" pairwise $t$ tests.  The purpose of these tests is to see if we have evidence about which groups differ from one another.

"Under the hood", R is doing independent samples $t$ tests between each pair of groups in our data.  Each of those tests is two-tailed, meaning the null hypothesis for each of these tests is $H_0$: $\mu_1 - \mu_2 = 0$ (step 1).  We retain the same alpha level that we used in our ANOVA (step 2).  R does not show us the $t$ values (step 3), only the $p$ values (step 4) from each test.  These $p$ values are "adjusted" in order to avoid increasing the probability of a Type I error, and we have to tell R what adjustment to use.  Finally, it us up to us to decide whether or not to reject the null hypothesis *in each test* based on the $p$ values and our alpha level.

This is how it is done in R:


```r
my_data %$%
    pairwise.t.test(
        x = X,
        g = Group,
        p.adjust.method = 'bonferroni'
    )
```

```
## 
## 	Pairwise comparisons using t tests with pooled SD 
## 
## data:  X and Group 
## 
##   1     2    
## 2 0.022 -    
## 3 0.010 1.000
## 
## P value adjustment method: bonferroni
```

As above, remember that you'll need to swap out `my_data` for your own data, as well as changing the names of the response variable (in `x = ___`) and the explanatory variable (in `g = ___`).

## Linear Regression

With linear regression, we are interested in asking whether the linear relationship between the explanatory and response variables---this relationship is a "**linear model**"---actually helps explain differences in the response variable.  The resulting hypothesis test procedure is very similar to that for ANOVA.

The difference is that ANOVA asks about an explanatory variable that is on a *nominal* scale, i.e., it just tells us which group an observation came from; linear regression asks about an explanatory variable that is on an *interval* or *ratio* scale, i.e., it tells us a specific number that is on a meaningful scale.

For this example, we will use a simple artificial dataset:


```r
my_data <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/linreg_example_data.csv")
```

```
## 
## ── Column specification ────────────────────────────────────────────────────────
## cols(
##   X = col_double(),
##   Y = col_double()
## )
```

This is what the data look like:


```r
my_data
```

```
## # A tibble: 30 x 2
##        X      Y
##    <dbl>  <dbl>
##  1 -1.85 -2.02 
##  2 -1.78 -3.82 
##  3 -1.53 -4.28 
##  4 -1.53 -0.400
##  5 -1.33 -2.72 
##  6 -1.03 -0.768
##  7 -0.96 -0.861
##  8 -0.84 -1.61 
##  9 -0.63 -0.529
## 10 -0.59 -0.806
## # … with 20 more rows
```

We will use the `X` variable as the **explanatory** variable and the `Y` variable as the **response** variable.

1. Translate your **research question** into a **null** and **alternative** hypothesis.

As with ANOVA, this part is easy because the null hypothesis in linear regression is always the same:  The null hypothesis is that the true value of the *slope* of the linear relationship is zero ($H_0$: $b_1 = 0$).  The alternative hypothesis is that the true value of the slope is not equal to zero ($H_1$: $b_1 \neq 0$).

2. Decide on an **alpha level**.

Let's assume that we have adopted an alpha level of 0.05.

3. Find the $F$ value.

4. Find the $p$ value.

Both the previous two steps are accomplished in the same chunk of code:


```r
my_data %$%
    lm(Y ~ X) %>%
    anova()
```

```
## Analysis of Variance Table
## 
## Response: Y
##           Df Sum Sq Mean Sq F value    Pr(>F)    
## X          1 24.141 24.1408  33.078 3.581e-06 ***
## Residuals 28 20.435  0.7298                      
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

To do this with your own data, make sure to tell R the name of your dataset (replace `my_data`), the name of your response variable (replace `X`), and the name of your explanatory variable (replace `Y`).

5. Decide whether or not to reject the null hypothesis.

If the $p$ value is less than the alpha level, you *reject* the null hypothesis, otherwise you *fail to reject* it.
