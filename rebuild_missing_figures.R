# Rebuild only missing knitr figure files referenced by index.html
suppressPackageStartupMessages({
  library(DemoKin)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
})

options(scipen = 999999)

out_dir <- file.path('index_files', 'figure-html')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

save_plot <- function(name, plot_obj, width_in, height_in, dpi = 96) {
  ggsave(
    filename = file.path(out_dir, name),
    plot = plot_obj,
    width = width_in,
    height = height_in,
    dpi = dpi,
    units = 'in'
  )
}

save_base <- function(name, width_px, height_px, expr) {
  png(filename = file.path(out_dir, name), width = width_px, height = height_px)
  force(expr)
  dev.off()
}

# Chunk 5
p5 <- swe_px %>%
  as.data.frame() %>%
  select(px = `2018`) %>%
  mutate(ages = 1:nrow(swe_px) - 1) %>%
  ggplot() +
  geom_line(aes(x = ages, y = 1 - px)) +
  scale_y_log10()
save_plot('5-1.png', p5, width_in = 7, height_in = 5)

# Chunk 7
p7 <- swe_asfr %>%
  as.data.frame() %>%
  select(fx = `2018`) %>%
  mutate(age = 1:nrow(swe_asfr) - 1) %>%
  ggplot() +
  geom_line(aes(x = age, y = fx))
save_plot('7-1.png', p7, width_in = 7, height_in = 5)

# Chunks 10 and 15 setup
swe_surv_2018 <- DemoKin::swe_px[, '2018']
swe_asfr_2018 <- DemoKin::swe_asfr[, '2018']
swe_2018 <- kin(p = swe_surv_2018, f = swe_asfr_2018, time_invariant = TRUE)

load('data/brazil_data.RData')

country_fert <- brazil_data %>%
  select(age, year, fx) %>%
  pivot_wider(names_from = year, values_from = fx) %>%
  select(-age) %>%
  as.matrix()

country_surv <- brazil_data %>%
  select(age, year, px) %>%
  pivot_wider(names_from = year, values_from = px) %>%
  select(-age) %>%
  as.matrix()

br_2023_keyfitz <- kin(p = country_surv, f = country_fert, time_invariant = TRUE)

# Chunk 10
save_base('10-1.png', width_px = 1152, height_px = 960, {
  swe_2018$kin_summary %>%
    filter(age_focal == 5) %>%
    select(kin, count = count_living) %>%
    plot_diagram(rounding = 2)
})

# Chunk 15
save_base('15-1.png', width_px = 1152, height_px = 960, {
  br_2023_keyfitz$kin_summary %>%
    filter(age_focal == 5) %>%
    select(kin, count = count_living) %>%
    plot_diagram(rounding = 2)
})

# Chunks 28-32 setup
br_asfr_2023 <- brazil_data %>%
  select(age, year, fx) %>%
  pivot_wider(names_from = year, values_from = fx) %>%
  select(-age) %>%
  as.matrix()

br_surv_2023 <- brazil_data %>%
  select(age, year, px) %>%
  pivot_wider(names_from = year, values_from = px) %>%
  select(-age) %>%
  as.matrix()

output_kin <- c('c', 'd', 'gd', 'ggd', 'ggm', 'gm', 'm', 'n', 'a', 's')
br_2023 <- kin(p = br_surv_2023, f = br_asfr_2023, output_kin = output_kin, time_invariant = TRUE)

# Chunk 28
p28 <- br_2023$kin_summary %>%
  rename_kin() %>%
  ggplot() +
  geom_line(aes(age_focal, count_living)) +
  theme_bw() +
  labs(x = 'Age of focal', y = 'Number of living female relatives') +
  facet_wrap(~kin_label)
save_plot('28-1.png', p28, width_in = 8, height_in = 6)

# Chunk 29
counts <- br_2023$kin_summary %>%
  group_by(age_focal) %>%
  summarise(count_living = sum(count_living), .groups = 'drop')

p29 <- br_2023$kin_summary %>%
  select(age_focal, kin, count_living) %>%
  rename_kin() %>%
  ggplot(aes(x = age_focal, y = count_living)) +
  geom_area(aes(fill = kin_label), colour = 'black') +
  geom_line(data = counts, size = 2) +
  labs(x = 'Age of focal', y = 'Number of living female relatives', fill = 'Kin') +
  coord_cartesian(ylim = c(0, 6)) +
  theme_bw() +
  theme(legend.position = 'bottom')
save_plot('29-1.png', p29, width_in = 7, height_in = 5)

# Chunk 30
p30 <- br_2023$kin_full %>%
  rename_kin() %>%
  filter(age_focal == 35) %>%
  ggplot() +
  geom_line(aes(age_kin, living)) +
  labs(x = 'Age of kin', y = 'Expected number of living relatives') +
  theme_bw() +
  facet_wrap(~kin_label)
save_plot('30-1.png', p30, width_in = 8, height_in = 6)

# Chunk 31
loss1 <- br_2023$kin_summary %>%
  filter(age_focal > 0) %>%
  group_by(age_focal) %>%
  summarise(count_dead = sum(count_dead), .groups = 'drop')

p31 <- br_2023$kin_summary %>%
  rename_kin() %>%
  filter(age_focal > 0) %>%
  group_by(age_focal, kin_label) %>%
  summarise(count_dead = sum(count_dead), .groups = 'drop') %>%
  ggplot(aes(x = age_focal, y = count_dead)) +
  geom_area(aes(fill = kin_label), colour = 'black') +
  geom_line(data = loss1, size = 2) +
  labs(x = 'Age of focal', y = 'Number of kin deaths experienced at each age', fill = 'Kin') +
  coord_cartesian(ylim = c(0, 0.086)) +
  theme_bw() +
  theme(legend.position = 'bottom')
save_plot('31-1.png', p31, width_in = 7, height_in = 5)

# Chunk 32
loss2 <- br_2023$kin_summary %>%
  group_by(age_focal) %>%
  summarise(count_cum_dead = sum(count_cum_dead), .groups = 'drop')

p32 <- br_2023$kin_summary %>%
  rename_kin() %>%
  group_by(age_focal, kin_label) %>%
  summarise(count_cum_dead = sum(count_cum_dead), .groups = 'drop') %>%
  ggplot(aes(x = age_focal, y = count_cum_dead)) +
  geom_area(aes(fill = kin_label), colour = 'black') +
  geom_line(data = loss2, aes(y = count_cum_dead), size = 2) +
  labs(x = 'Age of focal', y = 'Number of kin deaths experienced (cumulative)', fill = 'Kin') +
  theme_bw() +
  theme(legend.position = 'bottom')
save_plot('32-1.png', p32, width_in = 7, height_in = 5)

# Chunks 41-45 setup
source('UNWPP_data.R')

brazil_data_tv <- UNWPP_data(country = 'Brazil', start_year = 1950, end_year = 2023, sex = 'Female')

br_asfr <- brazil_data_tv %>%
  select(age, year, fx) %>%
  pivot_wider(names_from = year, values_from = fx) %>%
  select(-age) %>%
  as.matrix()

br_px <- brazil_data_tv %>%
  select(age, year, px) %>%
  pivot_wider(names_from = year, values_from = px) %>%
  select(-age) %>%
  as.matrix()

# Chunk 41
p41 <- br_px %>%
  as.data.frame() %>%
  mutate(age = 1:nrow(br_px) - 1) %>%
  pivot_longer(-age, names_to = 'year', values_to = 'px') %>%
  mutate(qx = 1 - px) %>%
  ggplot() +
  geom_line(aes(x = age, y = qx, col = year)) +
  scale_y_log10() +
  theme(legend.position = 'none')
save_plot('41-1.png', p41, width_in = 7, height_in = 5)

# Chunk 42
p42 <- br_asfr %>%
  as.data.frame() %>%
  mutate(age = 1:nrow(br_asfr) - 1) %>%
  pivot_longer(-age, names_to = 'year', values_to = 'asfr') %>%
  mutate(year = as.integer(year)) %>%
  ggplot() +
  geom_tile(aes(x = year, y = age, fill = asfr)) +
  scale_x_continuous(breaks = seq(1900, 2020, 10), labels = seq(1900, 2020, 10))
save_plot('42-1.png', p42, width_in = 7, height_in = 5)

br_pop <- UNWPP_pop(country_name = 'Brazil', start_year = 1950, end_year = 2023, sex = 'Female')

# Chunk 44
br_time_varying_1960_cohort <- DemoKin::kin(
  p = br_px,
  f = br_asfr,
  n = br_pop,
  time_invariant = FALSE,
  output_cohort = 1960,
  output_kin = c('d', 'gd', 'ggd', 'm', 'gm', 'ggm')
)

p44 <- br_time_varying_1960_cohort$kin_summary %>%
  rename_kin() %>%
  ggplot(aes(age_focal, count_living)) +
  geom_line() +
  scale_y_continuous(name = 'Expected number of living relatives', labels = seq(0, 3, .2), breaks = seq(0, 3, .2)) +
  facet_wrap(~kin_label) +
  labs(x = 'Age of Focal') +
  theme_bw()
save_plot('44-1.png', p44, width_in = 8, height_in = 6)

# Chunk 45
br_time_varying_1990_1960_cohort <- kin(
  p = br_px,
  f = br_asfr,
  n = br_pop,
  time_invariant = FALSE,
  output_cohort = c(1990, 1960),
  output_kin = c('d', 'gd', 'ggd', 'm', 'gm', 'ggm')
)

p45 <- br_time_varying_1990_1960_cohort$kin_summary %>%
  rename_kin() %>%
  mutate(cohort = as.factor(cohort)) %>%
  ggplot(aes(age_focal, count_living, color = cohort)) +
  geom_line() +
  scale_y_continuous(name = 'Expected number of living relatives', labels = seq(0, 3, .2), breaks = seq(0, 3, .2)) +
  labs(x = 'Age of Focal') +
  facet_wrap(~kin_label) +
  theme_bw()
save_plot('45-1.png', p45, width_in = 8, height_in = 6)

cat('Rebuilt figure files in', out_dir, '\n')
