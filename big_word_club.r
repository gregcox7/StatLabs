library(tidyverse)
library(infer)

load('../big_word_club.rda')

big_word_club <- big_word_club %>%
    mutate(group = factor(treat, levels = c(1, 0), labels = c("Treatment", "Control")))

big_word_club$invalid_a1[is.na(big_word_club$invalid_a1)] <- 0
big_word_club$invalid_a2[is.na(big_word_club$invalid_a2)] <- 0
big_word_club$invalid_ppvt[is.na(big_word_club$invalid_ppvt)] <- 0

big_word_club <- big_word_club %>%
    filter(invalid_a1 == 0, invalid_a2 == 0, invalid_ppvt == 0, !is.na(score_a1), !is.na(score_a2), !is.na(score_ppvt))

big_word_club %>%
    group_by(group) %>%
    summarize(mean(score_a1), mean(score_a2), mean(score_ppvt), n = n())

big_word_club %>%
    ggplot(aes(x = score_ppvt)) +
    geom_histogram(binwidth = 5) +
    facet_wrap("group", ncol = 1)

big_word_club %>%
    t_test(score_ppvt ~ group, order = c("Treatment", "Control"))

big_word_club %>%
    ggplot(aes(x = score_pct_change)) +
    geom_histogram(binwidth = 10) +
    facet_wrap("group", ncol = 1)

big_word_club %>%
    ggplot(aes(x = score_pct_change, fill = group)) +
    geom_freqpoly(binwidth = 10, position = "identity", alpha = 0.5)

big_word_club_obs_diff <- big_word_club %>%
    specify(score_pct_change ~ group) %>%
    calculate(stat = "diff in means", order = c("Treatment", "Control"))

big_word_club_null_dist <- big_word_club %>%
    specify(score_pct_change ~ group) %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in means", order = c("Treatment", "Control"))

big_word_club_null_dist %>%
    visualize() +
    shade_p_value(obs_stat = big_word_club_obs_diff, direction =)