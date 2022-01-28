# Relationships between numerical variables {#lab4}



<img src="img/regression_cloud.png" width="100%" />

In this session, we will use R to help us describe relationships between numerical variables.  Typically, the purpose in doing so is to see how well we can predict or explain differences in a **response** variable in terms of differences in an **explanatory** variable.  As we have seen, we have several useful tools to work with:  **scatterplots**, **correlation**, and **linear regression**.

<!-- In this session, we will also encounter situations in which we have to deal with **transformations** of a variable as well as **outliers**. -->

## Load the `tidyverse`

As usual, once we have started up RStudio, the first thing we should be sure to do is load the `tidyverse` package from R's library using the line below:


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

## Always plot your data

Numerical summaries of data are extremely useful and compact descriptions of things like central tendency and variability.  We have also seen how the Pearson correlation coefficient is a useful summary of the strength and direction of a relationship between numerical variables.  But these numerical summaries can also be misleading, as we shall see in the following example.

### Load the data

First, we need to import some data into R using the code below.


```r
anscombe <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/cor_data.csv")
```

```{.Rout .text-info}
## Rows: 44 Columns: 3
```

```{.Rout .text-info}
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (1): Group
## dbl (2): X, Y
```

```{.Rout .text-info}
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

These data are artificial and were devised by @Anscombe1973.

### Correlations for different sets of measurements

There are four groups of observations in these data.  The groups are labeled "A", "B", "C", and "D".  Observations were made on two variables, labeled "X" and "Y".  Click on `anscombe` in the environment panel in RStudio (upper right) to take a look.

Using R, we can quickly get numerical summaries of these data.  The code below provides the mean and standard deviation of the X and Y values in each group, as well as the correlation between X and Y in each group.


```r
anscombe %>%
    group_by(Group) %>%
    summarize(Mean_X = mean(X), Mean_Y = mean(Y), SD_X = sd(X), SD_Y = sd(Y), r = cor(X, Y))
```

```{.Rout .text-muted}
## # A tibble: 4 × 6
##   Group Mean_X Mean_Y  SD_X  SD_Y     r
##   <chr>  <dbl>  <dbl> <dbl> <dbl> <dbl>
## 1 A          9   7.50  3.32  2.03 0.816
## 2 B          9   7.50  3.32  2.03 0.816
## 3 C          9   7.5   3.32  2.03 0.816
## 4 D          9   7.50  3.32  2.03 0.817
```

Do you notice anything funny about these results?  It looks like there are basically no differences at all between the groups!

### Scatterplots

Rather than a numerical summary, now let's use R to visually summarize these data using scatterplots.  We will put the `X` variable on the horizontal ("x") axis and the `Y` variable on the vertical ("y") axis.  We will use `Group` as a "facetting" variable:


```r
anscombe %>%
    ggplot(aes(x=X, y=Y)) +
    geom_point() +
    facet_wrap("Group")
```

<img src="04-numerical_relationships_files/figure-html/unnamed-chunk-5-1.png" width="672" />

::: {.exercise}
For each of the scatterplots above, respond to the following questions:

a. Does the scatterplot indicate that there is probably an association between the two variables?  If so, describe the type of relationship.
b. Does the correlation coefficient (`r`) provide a good summary of whether or how the two variables are related?  Why or why not?

:::

## And now for a word

*Psycholinguistics* is the study of the perceptual and cognitive processes involved in learning, understanding, and producing language.  One of the ways psycholinguists study language processing is using a "lexical decision task".  In a lexical decision task, participants are shown strings of letters; sometimes, these make real words (like "AUTHOR") and sometimes they don't (like "AWBLOR").  The time someone takes to decide that a string of letters is a real word (AUTHOR) is a measure of how easily knowledge about that word can be accessed.  By looking at the relationships between **lexical decision time (LDT)** and different properties of a word, we can begin to understand the processes by which we organize and access our knowledge of language.  In other words, lexical decision time tells us how the "mental dictionary" is structured.

The [English Lexicon Project](https://elexicon.wustl.edu/) has been collecting this kind of data from a lot of people with many different words in the English language.  They report the mean lexical decision time for a word, along with a number of other properties of the word.  We will treat the mean lexical decision time as the **response variable** and examine its relationships to a number of other **explanatory variables**.

### Load the data

Run the following line of code to download a subset of the data from the English Lexicon Project.


```r
elp <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/elp.csv")
```

```{.Rout .text-info}
## Rows: 31433 Columns: 25
```

```{.Rout .text-info}
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr  (2): Word, POS
## dbl (23): Length, Freq_KF, Freq_HAL, SUBTLWF, SUBTLCD, Ortho_N, Phono_N, OLD...
```

```{.Rout .text-info}
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Each case/observation in this dataset is a particular word.  In addition to lexical decision time, there are several other potential explanatory variables that have been measured for each word.

### Examine the distribution of lexical decision times

The `LDT` variable contains the lexical decision time for each word in the dataset.  LDT is measured in milliseconds.  Let us first examine the distribution of lexical decision times using the code below:


```r
elp %>%
  ggplot(aes(x = LDT)) +
  geom_histogram(binwidth=20)
```

<img src="04-numerical_relationships_files/figure-html/unnamed-chunk-7-1.png" width="672" />

::: {.exercise}
Describe the distribution of lexical decision times across words (you can re-run the code to look at other binwidths if you like).  Be sure to note the number of modes, skewness, and whether there are any potential outliers.

:::

### Word length as an explanatory variable

A natural **research question** to ask at this point is whether LDT can be explained by word length.  In other words, does the number of letters in a word affect how easy it is to recognize?

#### Scatterplot

First, we should make a scatterplot of these two variables.  Word length is recorded in the variable named `Length`.


```r
elp %>%
  ggplot(aes(x = Length, y = LDT)) +
  geom_point()
```

<img src="04-numerical_relationships_files/figure-html/unnamed-chunk-8-1.png" width="672" />

The scatterplot suggests a positive relationship that could be described by a line.

#### Overlaying a line

We can easily put the best-fitting linear regression line on top of our scatterplot to get a visual sense of how well a linear model could describe the relationship.  To do this, we add a line called `geom_smooth(method = "lm")`.  `geom_smooth` puts "smooth" lines or curves on our plot, and including `method = "lm"` in the parentheses tells R that we specifically want a `l`inear `m`odel.


```r
elp %>%
  ggplot(aes(x = Length, y = LDT)) +
  geom_point() +
  geom_smooth(method = "lm")
```

```{.Rout .text-info}
## `geom_smooth()` using formula 'y ~ x'
```

<img src="04-numerical_relationships_files/figure-html/unnamed-chunk-9-1.png" width="672" />

#### Finding the correlation

We can get the correlation coefficient using the `cor` function, like we did before:


```r
elp %>%
    summarize(r = cor(LDT, Length))
```

```{.Rout .text-muted}
## # A tibble: 1 × 1
##       r
##   <dbl>
## 1 0.543
```

#### Finding the slope and intercept

Finally, we can get the slope and intercept of the best-fitting line.  The line of code looks a little different from how we've done things until now.  It is just a single line called "lm" for "linear model".  In the parentheses, there are two instructions separated by a comma.  The first says what are the explanatory and response variables using a funky format `[response variable name] ~ [explanatory variable name]`.  The second instruction in the parentheses tells R which data to find those variables in.

Here's how it looks all together:


```r
lm(LDT ~ Length, data = elp)
```

```{.Rout .text-muted}
## 
## Call:
## lm(formula = LDT ~ Length, data = elp)
## 
## Coefficients:
## (Intercept)       Length  
##      546.33        28.15
```

The result of this line gives us the intercept of the best fitting line, as well as the slope.  The slope is labeled in terms of the *name* of the explanatory variable.

::: {.exercise}
Based on the result we got from running the code above, for each additional letter a word has, how much longer does it take to recognize that it is a word?

:::

### Age of Acquisition as an explanatory variable

Although it makes sense that a longer word would take longer to recognize, another important aspect of a word is *when* it was learned.  It is reasonable to think that a word that you learn early in life would be easier to access that one learned more recently.

The English Lexicon Project also records the mean "age of acquisition" for each word.  This is the mean age (in years) when someone first learns a word.  This variable is labeled `Age_Of_Acquisition` in the `elp` data.  Now, we will follow the same steps we did for looking at the relationship between Length and LDT, but instead of Length as the explanatory variable, we will use "age of acquisition".

For the following exercises, be sure to refer to the code we used in the previous section.

#### Scatterplot

As before, let's first make a scatterplot to visualize the relationship between LDT and age of acquisition.

::: {.exercise}
Fill in the blanks below to make a scatterplot with LDT as the response variable (on the `y` axis) and `Age_Of_Acquisition` as the explanatory variable (on the `x` axis):


```r
___ %>%
  ggplot(aes(x = ___, y = ___)) +
  ___()
```

a. What code did you use?
b. How would you describe the relationship between LDT and age of acquisition?

:::

#### Overlaying a line

Now, let's add a line to the scatterplot.

::: {.exercise}
Fill in the blanks below to make a scatterplot with LDT as the response variable (on the `y` axis) and `Age_Of_Acquisition` as the explanatory variable (on the `x` axis) with the best-fitting line overlaid on top.


```r
___ %>%
  ggplot(aes(x = ___, y = ___)) +
  ___() +
  ___(method = "lm")
```

a. What code did you use?
b. Does the line seem to be a good fit to the data?  Are there any areas where the line seems to under-shoot or over-shoot the data?

:::

#### Finding the correlation

Now let's find the correlation (again, be sure to look at the code we used in the previous section as a guide):

::: {.exercise}
Fill in the blanks below to find the correlation between `LDT` and `Age_Of_Acquisition`:


```r
___ %>%
    summarize(r = cor(___, ___))
```

a. What code did you use?
b. Is the correlation between LDT and Age of Acquisition stronger or weaker than the correlation between LDT and Length?
c. In the ELP dataset, Age of Acquisition is measured in years and LDT is measured in milliseconds.  Would the correlation between LDT and Age of Acquisition change if Age of Acquisition were measured in months and LDT were measured in seconds?  Why or why not?

:::

#### Finding the slope and intercept

Finally, let's find the slope and intercept of that best-fitting regression line between Age of Acquisition and LDT:

::: {.exercise}
Fill in the blanks in the code below to find the intercept and slope of the line using Age of Acquisition as the explanatory variable and LDT as the response variable:


```r
lm(___ ~ ___, data = ___)
```

a. What code did you use?
b. According to the linear model you just found, how much longer would it take to recognize a word that was learned at age 10, relative to a word that was learned at age 9?
c. Would it make sense to try to extend this relationship to very young ages (e.g., 6 months old)?  Explain your reasoning.
d. Do you expect the relationship would continue for words learned relatively later in life, like technical words you learn in college or work?  If not, what shape would you expect the relationship to have for words learned later in life and why?

:::

### Summary

We have seen that we can predict how long it takes to recognize a word in terms of either its length (number of letters) or the age at which it was learned (Age of Acquisition).  These results tell us that the "mental dictionary" is organized not just by things like spelling, but also by life experience.

## Wrap-up

We have seen how scatterplots, correlation, and linear regression all are valuable tools for describing relationships between numerical variables.  These tools help us explain the details of behavior that reveal the structure of memory.  These tools should always be used carefully and always with visualization, since numerical summaries alone can be misleading.
