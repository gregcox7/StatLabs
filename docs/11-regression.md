# Linear Regression {#lab11}



<img src="img/colin_jackson.jpg" width="100%" />

In this session, we will get acquainted with **linear regression**.  This is an important technique in statistics because it allows us both to make *inferences* about relationships between variables, and because it allows us to make *predictions* that help us make decisions.  We will work through how to do linear regression in R to do both inference and prediction.

Before we begin, make sure to grab our usual `tidyverse` package from R's library, as well as the `magrittr` package:


```r
library(tidyverse)
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
```

```
## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
## ✓ tibble  3.1.3     ✓ dplyr   1.0.5
## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
## ✓ readr   2.0.0     ✓ forcats 0.5.1
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
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

## Inference: The Answer is Blowing in the Wind

We will get ourselves acquainted with linear regression in R using a small dataset.  This dataset records the finishing times for [Colin Jackson](https://en.wikipedia.org/wiki/Colin_Jackson) in the 110 meter hurdles that he competed in during the year 1990.

Load the data into R:


```r
wind_run_data <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/wind_run.csv")
```

```
## Rows: 21 Columns: 2
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## dbl (2): Wind, Time
```

```
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

There are 21 total races, for which we have two variables observed:

* **Time**: The amount of time Colin took to complete the race (in seconds).
* **Wind**: The speed of the wind (in meters per second) during the race.  Negative values are head winds, so they were blowing in Colin's face.  Positive values are tail winds, so they were blowing on his back.

Let's first make a **scatterplot** to see whether there might be a relationship between wind speed and finishing time:


```r
wind_run_data %>%
    ggplot(aes(x = Wind, y = Time)) +
    geom_point()
```

<img src="11-regression_files/figure-html/unnamed-chunk-4-1.png" width="672" />

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1101"><strong>(\#exr:ex1101) </strong></span>Based on the scatterplot, how would you describe the relationship between wind speed and finishing time?  Might they be correlated?  If so, is the correlation positive or negative?  Strong or weak?
</div>\EndKnitrBlock{exercise}

### What a line is made of: Slopes and Intercepts

Let's see how well we can describe the relationship between wind speed and finishing time using a line.  As we've seen, the equation for a line looks like this:

$$
\hat{Y} = b_1 X + b_0
$$

where $b_1$ is the *slope* and $b_0$ is the *intercept*.  The slope describes how the response variable is predicted to change when the explanatory variable is increased by one.  The intercept describes what the predicted response is when the explanatory variable equals zero.

### Adding our own line

The following chunk of code adds a line to our scatterplot using `geom_abline`.  Notice that we need to specify the `slope` and `intercept` of the line that we want to add.


```r
wind_run_data %>%
    ggplot(aes(x = Wind, y = Time)) +
    geom_point() +
    geom_abline(slope = 0.1, intercept = 13.3)
```

<img src="11-regression_files/figure-html/unnamed-chunk-5-1.png" width="672" />

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1102"><strong>(\#exr:ex1102) </strong></span>Play around with the code above by changing the values for `slope` and `intercept` in the last line.  See if you can find values for the slope and intercept that make the line run close to the points in the plot.  What values did you find?
</div>\EndKnitrBlock{exercise}

### Adding the best-fitting line

Now that we've got a reasonable guess about the best-fitting line, let's see how close we were.  We can add the best fitting line to our plot by adding another line to our code.  This line is `stat_smooth(method = "lm")`.  `stat_smooth` can draw various kinds of lines on top of our data that are meant to "smooth" the raw data and make it easier to see any important relationships there might be.  In the parentheses, we tell R that the `method` it should use is `lm`, where `lm` stands for "linear model" (we've already seen `lm` and we'll see it again shortly).

Note that you'll need to fill in the blanks in the code below with the slope and intercept you found in the last section.


```r
wind_run_data %>%
    ggplot(aes(x = Wind, y = Time)) +
    geom_point() +
    geom_abline(slope = ___, intercept = ___) +
    stat_smooth(method = 'lm')
```


```
## `geom_smooth()` using formula 'y ~ x'
```

<img src="11-regression_files/figure-html/unnamed-chunk-7-1.png" width="672" />

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1103"><strong>(\#exr:ex1103) </strong></span>How close were you to the best-fitting line in blue?  Notice that in addition to the line, there is a shaded region around the line.  This shaded region is a visual representation of our **uncertainty** regarding the slope and intercept of the best-fitting line.  Why do you think this region is narrower near the middle and gets wider toward the edges?
</div>\EndKnitrBlock{exercise}

### Getting the slope and intercept

Being able to see the best-fitting line is great, but it doesn't let us *do* anything with it.  For example, if we want to predict Colin's time under a stronger headwind (e.g., -4 m/s), we'll need to actually know what $b_1$ and $b_0$ are.

In class, we saw how to calculate the coefficients of the best-fitting line using the descriptive statistics for our data.  Now, we will use R to do this.  The code is shockingly similar to what we used for ANOVA last time:


```r
wind_run_data %$%
    lm(Time ~ Wind)
```

```
## 
## Call:
## lm(formula = Time ~ Wind)
## 
## Coefficients:
## (Intercept)         Wind  
##     13.3218      -0.0846
```

Once again, the first line tells R what data we are working with.  The second line tells R that we want to find the best-fitting "linear model" (`lm`) that describes the linear relationship between our response variable (`Time`) and our explanatory variable (`Wind`).  R then told us the coefficients of that line.  R labels the slope with the same name as the explanatory variable (`Wind` in this case).

### How much variance does wind speed explain?

As we've seen, we can use $r^2$ to describe how much of the variability in Colin's finishing time can be explained by wind speed.  Because $r^2$ is the square of the Pearson correlation coefficient, we can find it by first calculating the correlation between finishing time and wind speed:


```r
wind_run_data %>%
    summarize(r = cor(Time, Wind))
```

```
## # A tibble: 1 × 1
##        r
##    <dbl>
## 1 -0.635
```

If we take the square of that result, we'll get the value of $r^2$:


```r
(-0.635)^2
```

```
## [1] 0.403225
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1104"><strong>(\#exr:ex1104) </strong></span>Based on the value for $r^2$, do you think that wind speed has a big effect on Colin's finishing times?  A small effect?  A moderate effect?  Remember that $r^2$ is always between 0 (no effect) and 1 (explains everything).
</div>\EndKnitrBlock{exercise}

### Making Predictions

We can now use the linear model to make predictions about how fast Colin will be expected to finish based on different wind speeds.  First, let's see what the model predicts for each of the observed wind speeds:


```r
wind_run_data %$%
    lm(Time ~ Wind) %>%
    predict()
```

```
##        1        2        3        4        5        6        7        8 
## 13.56714 13.49100 13.45716 13.44024 13.38947 13.35563 13.35563 13.33871 
##        9       10       11       12       13       14       15       16 
## 13.33025 13.30487 13.30487 13.27949 13.27949 13.25411 13.23719 13.22873 
##       17       18       19       20       21 
## 13.22873 13.22027 13.13567 13.08490 13.07644
```

The result is what the model *predicts* Colin's finishing time would have been for each race in our dataset.  In other words, these are all the $\hat{Y}_i$'s for each $X_i$ in our data.  We can also get the **residuals** for each prediction, to see how far off it was:


```r
wind_run_data %$%
    lm(Time ~ Wind) %>%
    residuals()
```

```
##            1            2            3            4            5            6 
## -0.037139491  0.139002832 -0.067156136  0.089764380  0.240525929 -0.185633039 
##            7            8            9           10           11           12 
## -0.105633039 -0.108712522  0.299747736 -0.214871490 -0.124871490 -0.199490716 
##           13           14           15           16           17           18 
##  0.100509284  0.265890059 -0.127189425 -0.128729167 -0.028729167  0.009731091 
##           19           20           21 
##  0.084333672  0.055095221  0.043555479
```

To make a prediction about a *new* race, we need to add something to our "predict" line.  Specifically, we need to give it "new data" about the Wind speed for each prediction we want to make.  This is how we can do this:


```r
future_wind <- tibble(Wind = c(-1, 0, 1))
```

The previous line of code created a new dataset called `future_wind` that contains a single variable called `Wind` which has 3 values, -1, 0, and 1.  We can get Colin's predicted time for each of these three wind speeds like so:


```r
wind_run_data %$%
    lm(Time ~ Wind) %>%
    predict(newdata = future_wind)
```

```
##        1        2        3 
## 13.40639 13.32179 13.23719
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1105"><strong>(\#exr:ex1105) </strong></span>Create a new "future_wind" dataset that contains the values -30 and 30, then use the preceding chunk of code to get predictions for how long Colin will take to finish under those two conditions.  What were the predictions?  Do they seem reasonable?  Does it seem reasonable that someone would be running when the wind is blowing 30 meters per second (67 miles per hour)?
</div>\EndKnitrBlock{exercise}

### Hypothesis Testing

Based on the plots we made earlier, it certainly looks like there is an approximately linear relationship between Colin's finishing times and wind speed.  But the slope of the best-fitting line is only about -0.08, which seems kind of small.  So it is worth asking the **research question**, "is there a relationship between finishing time and wind speed?"

Let's use our standard 5-step hypothesis testing procedure to address this question.

1. Translate your research question into a null and alternative hypothesis

Our **null hypothesis** is that there is no such relationship, meaning that the true value of the slope is 0 ($H_0$: $b_1 = 0$).  Our **alternative hypothesis** is that there is a relationship, meaning that the true value of the slope is not zero ($H_1$: $b_1 \neq 0$).

2. Select an alpha level

We will select a reasonable **alpha level** of 0.05.

3. Find the $F$ value

4. Find the $p$ value

These two steps can be done using...the very same code we used for ANOVA!  As we saw in class, linear regression and ANOVA can be thought of as addressing the same question, it is just that the explanatory variable in ANOVA is nominal while the explanatory variable in linear regression is interval or ratio.  The following code gives us both the $F$ value and the $p$ value:


```r
wind_run_data %$%
    lm(Time ~ Wind) %>%
    anova()
```

```
## Analysis of Variance Table
## 
## Response: Time
##           Df  Sum Sq  Mean Sq F value  Pr(>F)   
## Wind       1 0.31535 0.315350  12.844 0.00198 **
## Residuals 19 0.46648 0.024551                   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

As you can see, the basic structure of that code and what we used for ANOVA is the same, and the resulting output is nearly identical as well.  The difference is in the type of explanatory variable:  It is a nominal variable in ANOVA, whereas it is an interval or ratio scale variable in linear regression.  The shared basic outline is this:


```r
Name_of_Data %$%
    lm(Name_of_Response_Variable ~ Name_of_Explanatory_Variable) %>%
    anova()
```

5. Decide whether or not to reject the null hypothesis

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1106"><strong>(\#exr:ex1106) </strong></span>Based on the $p$ value reported in the table above, and based on the alpha level we chose in step 2, do we reject the null hypothesis?  What does this tell us about the relationship between Colin's performance and wind speed?
</div>\EndKnitrBlock{exercise}

## Making Decisions: Housing Prices

Linear regression is often helpful when we have to make a decision.  Specifically, if we want to make a decision about a response variable---and all we know is an explanatory variable---linear regression allows us to use the relationship between the response and explanatory variables to make a reasonable guess.

One setting in which these decisions are important is *purchasing*.  The seller needs to decide how much to price what they are selling.  The potential buyer needs to know whether they are paying a fair price.

To see this in action, we will look at housing sale data from the lovely college town of Ames, Iowa.


```r
ames <- read_csv("https://raw.githubusercontent.com/gregcox7/StatLabs/main/data/ames.csv")
```

```
## Rows: 2930 Columns: 15
```

```
## ── Column specification ────────────────────────────────────────────────────────
## Delimiter: ","
## chr (11): Street, Alley, Lot.Shape, Land.Contour, Utilities, Lot.Config, Lan...
## dbl  (4): PID, area, price, Year.Built
```

```
## 
## ℹ Use `spec()` to retrieve the full column specification for this data.
## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
```

Although there are a lot of variables in this dataset, there are two that we will focus on:

* **area**: The total livable area of the house, in square feet.
* **price**: The final price for which the house sold.

### Visualize the data

First, let's make a scatterplot to visualize the relationship between these variables.  Fill in the blanks below.


```r
ames %>%
    ggplot(aes(x = ___, y = ___)) +
    ___()
```

<img src="11-regression_files/figure-html/unnamed-chunk-19-1.png" width="672" />


\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1107"><strong>(\#exr:ex1107) </strong></span>What did you put in the blanks above?  How would you describe the relationship between area and price?  Are they positively or negatively correlated?  Is the correlation strong or weak?  Do you notice any "outliers", points that seem really odd relative to the rest of the data?
</div>\EndKnitrBlock{exercise}

### Find the best-fitting line

Now let's add the best-fitting line to our scatterplot (again, be sure to fill in the blanks; see the Colin Jackson example above for examples):


```r
ames %>%
    ggplot(aes(x = ___, y = ___)) +
    ___() +
    stat_smooth(method = ___)
```


```
## `geom_smooth()` using formula 'y ~ x'
```

<img src="11-regression_files/figure-html/unnamed-chunk-21-1.png" width="672" />

And let's get the coefficients (slope and intercept) of the best-fitting line:


```r
ames %$%
    lm(price ~ area)
```

```
## 
## Call:
## lm(formula = price ~ area)
## 
## Coefficients:
## (Intercept)         area  
##     13289.6        111.7
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1108"><strong>(\#exr:ex1108) </strong></span>What does the intercept tell us about house prices and area?  What does the slope tell us about house prices and area?  Based on the scatterplot, do you think the linear model does a better job predicting prices for different sized houses?
</div>\EndKnitrBlock{exercise}

### Make Predictions

Now let's put ourselves in different scenarios and see how our linear model can help us make decisions.

#### How to set the price?

Let's imagine that there are two houses on the market, one with a 1000 square foot area, one with 2000 square foot area.  Let's first use our linear model to *predict* the price for these three houses:


```r
new_price <- tibble(area = c(1000, 2000))

ames %$%
    lm(price ~ area) %>%
    predict(newdata = new_price)
```

```
##        1        2 
## 124983.6 236677.6
```

As above, the first result is the predicted price for the 1000 square foot house and the second result is the predicted price for the 2000 square foot house.

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1109"><strong>(\#exr:ex1109) </strong></span>Imagine you are a seller.  Look at the scatterplot to get a sense of where these predicted prices fall relative to all the houses around the two sizes.  Do you think the prices predicted from the linear model are too low, too high, or about average for these two houses?  Do you think you might have more flexibility in setting the price of the smaller house (1000 sq. ft.) or the larger house (2000 sq. ft.)?
</div>\EndKnitrBlock{exercise}

#### Am I getting a fair price?

Now let's imagine that we are looking to buy a house.  We have three different options which are 1200, 2400, and 4500 square feet in size, respectively.  The listed prices for each house are

House Area ($X$)   | 1200 sq. ft | 2400 sq. ft | 4500 sq. ft
-------------------|-------------|-------------|------------
Actual Price ($Y$) | \$150000.00 | \$400000.00 | \$250000.00

Let's use our linear model to predict what the prices for these houses *would* be.  By comparing these predictions to the actual prices, we can see which prices seem fair, which seem excessively high, and which might be a discount.

First, fill in the blanks to get the predicted price for each of these houses:


```r
new_price <- tibble(___ = c(___))

ames %$%
    lm(price ~ area) %>%
    predict(newdata = new_price)
```


```
##        1        2        3 
## 147322.4 281355.2 515912.6
```

\BeginKnitrBlock{exercise}<div class="exercise"><span class="exercise" id="exr:ex1110"><strong>(\#exr:ex1110) </strong></span>By comparing the actual prices to the predicted prices, which of the three houses seems like a good deal?  Which seem to be overpriced?
</div>\EndKnitrBlock{exercise}

## Wrap-up

Today, we saw how to do linear regression in R, including

1. How to visualize the best-fitting line that relates an explanatory variable and a response variable.
2. How to get the coefficients of the best-fitting line.
3. How to find the proportion of variance explained by the linear relationship ($r^2$).
4. How to make predictions using a linear model.
5. How to test the null hypothesis that the slope of the line is zero, to draw inferences about whether there is a meaningful relationship between the explanatory and response variables.
6. How to use predictions from the linear model to help make decisions.
