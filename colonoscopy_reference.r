# routine high-quality .2082 * 293 = 61 / 293
# algorithm high-quality 0.2637 * 292 = 77 / 292
# routine low-quality (109 - 61) / (536 - 293) = 48 / 243
# algorithm low-quality (152 - 77) / (522 - 292) = 75 / 230
# routine all 0.2034 * 536 = 109 / 536
# algorithm all 0.2912 * 522 = 152 / 522

library(tidyverse)
library(infer)

colonoscopy <- rbind(
    rep_slice_sample(tibble(method = "Routine", quality = "High", detected = "Yes"), n=61, replace=TRUE),
    rep_slice_sample(tibble(method = "Routine", quality = "High", detected = "No"), n=293 - 61, replace=TRUE),
    rep_slice_sample(tibble(method = "Computer-aided", quality = "High", detected = "Yes"), n=77, replace=TRUE),
    rep_slice_sample(tibble(method = "Computer-aided", quality = "High", detected = "No"), n=292 - 77, replace=TRUE),
    rep_slice_sample(tibble(method = "Routine", quality = "Low", detected = "Yes"), n=48, replace=TRUE),
    rep_slice_sample(tibble(method = "Routine", quality = "Low", detected = "No"), n=243 - 48, replace=TRUE),
    rep_slice_sample(tibble(method = "Computer-aided", quality = "Low", detected = "Yes"), n=75, replace=TRUE),
    rep_slice_sample(tibble(method = "Computer-aided", quality = "Low", detected = "No"), n=230 - 75, replace=TRUE)
)

# colonoscopy <- colonoscopy[sample(nrow(colonoscopy)),c("method", "quality", "detected")]
colonoscopy <- colonoscopy[sample(nrow(colonoscopy)),c("method", "detected")]

write_csv(colonoscopy, file = "data/colonoscopy.csv")

obs_diff <- colonoscopy %>%
    specify(detected ~ method, success = "Yes") %>%
    calculate(stat = "diff in props", order = c("Computer-aided", "Routine"))

null_dist_random <- colonoscopy %>%
    specify(detected ~ method, success = "Yes") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "diff in props", order = c("Computer-aided", "Routine"))

null_dist_random %>%
    visualize() +
    shade_p_value(obs_stat = obs_diff, direction = "two-sided")

obs_z <- colonoscopy %>%
    specify(detected ~ method, success = "Yes") %>%
    calculate(stat = "z", order = c("Computer-aided", "Routine"))

null_dist_normal <- colonoscopy %>%
    specify(detected ~ method, success = "Yes") %>%
    hypothesize(null = "independence") %>%
    generate(reps = 1000, type = "permute") %>%
    calculate(stat = "z", order = c("Computer-aided", "Routine"))

null_dist_normal %>%
    visualize(method = "both") +
    shade_p_value(obs_stat = obs_z, direction = "two-sided")

null_dist_normal %>%
    get_p_value(obs_stat = obs_z, direction = "two-sided")

colonoscopy %>%
    specify(response = detected, success = "Yes") %>%
    calculate(stat = "prop")

boot_dist_routine <- colonoscopy %>%
    filter(method == "Routine") %>%
    specify(response = detected, success = "Yes") %>%
    generate(reps = 1000, type = "bootstrap") %>%
    calculate(stat = "prop")

boot_ci_routine <- boot_dist_routine %>%
    get_confidence_interval(level = 0.95)

boot_dist_routine %>%
    visualize() +
    shade_confidence_interval(endpoints = boot_ci_routine)

boot_dist_routine %>%
    visualize(method = "both")

obs_p_routine <- colonoscopy %>%
    filter(method == "Routine") %>%
    specify(response = detected, success = "Yes") %>%
    calculate(stat = "prop")

normal_dist_routine <- colonoscopy %>%
    filter(method == "Routine") %>%
    specify(response = detected, success = "Yes") %>%
    assume(distribution = "z")

normal_ci_routine <- normal_dist_routine %>%
    get_confidence_interval(level = 0.95, point_estimate = obs_p_routine)

normal_dist_routine %>%
    visualize() +
    shade_confidence_interval(endpoints = normal_ci_routine)
