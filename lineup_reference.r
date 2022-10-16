library(tidyverse)
library(infer)

lineup <- rbind(
    tibble(condition = "Blind", presentation = "Simultaneous", ID = rep(c("None", "Filler", "Suspect"), c(71, 9 + 15 + 24, 49 + 13 + 6))),
    tibble(condition = "Blind", presentation = "Sequential", ID = rep(c("None", "Filler", "Suspect"), c(59, 8 + 18 + 30, 22 + 15 + 9))),
    tibble(condition = "Blinded", presentation = "Simultaneous", ID = rep(c("None", "Filler", "Suspect"), c(96, 7 + 17 + 26, 30 + 11 + 7))),
    tibble(condition = "Blinded", presentation = "Sequential", ID = rep(c("None", "Filler", "Suspect"), c(54, 6 + 11 + 36, 34 + 29 + 5)))
)

lineup <- lineup[sample(1:nrow(lineup)),]

# Simulation

obs_prop <- lineup %>%
    filter(ID != "None") %>%
    specify(response = ID, success = "Suspect") %>%
    calculate(stat = "prop")

boot_prop_dist <- lineup %>%
    filter(ID != "None") %>%
    specify(response = ID, success = "Suspect") %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "prop")

boot_prop_ci <- boot_prop_dist %>%
    get_confidence_interval(level = 0.95)

null_prop_dist <- lineup %>%
    filter(ID != "None") %>%
    specify(response = ID, success = "Suspect") %>%
    hypothesize(null = "point", p = 1 / 6) %>%
    generate(reps = 1000, type = "draw") %>%
    calculate(stat = "prop")

null_prop_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_prop, direction = "greater")

# Mathematical

obs_z <- lineup %>%
    filter(ID != "None") %>%
    specify(response = ID, success = "Suspect") %>%
    hypothesize(null = "point", p = 1 / 6) %>%
    calculate(stat = "z")

prop_samp_dist <- lineup %>%
    filter(ID != "None") %>%
    specify(response = ID, success = "Suspect") %>%
    assume(distribution = "z")

z_prop_ci <- prop_samp_dist %>%
    get_confidence_interval(level = 0.95, point_estimate = obs_prop)

null_prop_dist <- lineup %>%
    filter(ID != "None") %>%
    specify(response = ID, success = "Suspect") %>%
    hypothesize(null = "point", p = 1 / 6) %>%
    assume(distribution = "z")

null_prop_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_z, direction = "greater")

boot_prop_dist %>%
    visualize() +
    shade_confidence_interval(boot_prop_ci)

prop_samp_dist %>%
    visualize() +
    shade_confidence_interval(z_prop_ci)

###

obs_diff <- lineup %>%
    filter(ID != "None") %>%
    specify(ID ~ presentation, success = "Suspect") %>%
    calculate(stat = "diff in props", order = c("Sequential", "Simultaneous"))

null_diff_dist <- lineup %>%
    filter(ID != "None") %>%
    specify(ID ~ presentation, success = "Suspect") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in props", order = c("Sequential", "Simultaneous"))

null_diff_dist %>%
    visualize() +
    shade_p_value(obs_stat = obs_diff, direction = "two-sided")
