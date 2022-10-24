library(tidyverse)
library(infer)

## Fairness

fairness_n <- round(2 * .23 * (1 - .23) * (2.31)^2 / .01)

fairness <- rbind(
    tibble(condition = "Blind", ID = rep(c("Filler", "Suspect"), round(c((1 - .18) * fairness_n, .18 * fairness_n)))),
    tibble(condition = "Not blind", ID = rep(c("Filler", "Suspect"), round(c((1 - .28) * fairness_n, .28 * fairness_n))))
)

fairness <- fairness[sample(1:nrow(fairness)),]

write_csv(fairness, file = "data/lineup_fairness.csv")

fairness_obs_diff <- fairness %>%
    specify(ID ~ condition, success = "Suspect") %>%
    calculate(stat = "diff in props", order = c("Not blind", "Blind"))

fairness_null_dist <- fairness %>%
    specify(ID ~ condition, success = "Suspect") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in props", order = c("Not blind", "Blind"))

fairness_null_dist %>%
    visualize() +
    shade_p_value(obs_stat = fairness_obs_diff, direction = "greater")

## Main study

lineup <- rbind(
    tibble(presentation = "Simultaneous", ID = rep(c("None", "Filler", "Suspect"), c(71, 9 + 15 + 24, 49 + 13 + 6))),
    tibble(presentation = "Sequential", ID = rep(c("None", "Filler", "Suspect"), c(59, 8 + 18 + 30, 22 + 15 + 9))) #,
    # tibble(condition = "Blinded", presentation = "Simultaneous", ID = rep(c("None", "Filler", "Suspect"), c(96, 7 + 17 + 26, 30 + 11 + 7))),
    # tibble(condition = "Blinded", presentation = "Sequential", ID = rep(c("None", "Filler", "Suspect"), c(54, 6 + 11 + 36, 34 + 29 + 5)))
) %>%
    filter(ID != "None")

lineup <- lineup[sample(1:nrow(lineup)),]

write_csv(lineup, file = "data/lineup.csv")

# Simulation

obs_prop <- lineup %>%
    specify(response = ID, success = "Suspect") %>%
    calculate(stat = "prop")

boot_prop_dist <- lineup %>%
    specify(response = ID, success = "Suspect") %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "prop")

boot_prop_ci <- boot_prop_dist %>%
    get_confidence_interval(level = 0.95)

boot_prop_dist %>%
    visualize() +
    shade_confidence_interval(boot_prop_ci)

null_prop_dist <- lineup %>%
    specify(response = ID, success = "Suspect") %>%
    hypothesize(null = "point", p = 1 / 6) %>%
    generate(reps = 1000, type = "draw") %>%
    calculate(stat = "prop")

null_prop_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_prop, direction = "greater")

# Mathematical

obs_z <- lineup %>%
    specify(response = ID, success = "Suspect") %>%
    hypothesize(null = "point", p = 1 / 6) %>%
    calculate(stat = "z")

prop_samp_dist <- lineup %>%
    specify(response = ID, success = "Suspect") %>%
    assume(distribution = "z")

z_prop_ci <- prop_samp_dist %>%
    get_confidence_interval(level = 0.95, point_estimate = obs_prop)

null_prop_dist <- lineup %>%
    specify(response = ID, success = "Suspect") %>%
    hypothesize(null = "point", p = 1 / 6) %>%
    assume(distribution = "z")

null_prop_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_z, direction = "greater")

prop_samp_dist %>%
    visualize() +
    shade_confidence_interval(z_prop_ci)

###

obs_diff <- lineup %>%
    specify(ID ~ presentation, success = "Suspect") %>%
    calculate(stat = "diff in props", order = c("Sequential", "Simultaneous"))

null_diff_dist <- lineup %>%
    specify(ID ~ presentation, success = "Suspect") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in props", order = c("Sequential", "Simultaneous"))

null_diff_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_diff, direction = "two-sided")
