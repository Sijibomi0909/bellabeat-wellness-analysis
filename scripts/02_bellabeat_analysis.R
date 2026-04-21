install.packages("tidyverse")
install.packages("lubridate")
install.packages("janitor")
install.packages("scales")
install.packages("patchwork")
install.packages("viridis")

# ============================================================
# BELLABEAT WELLNESS ANALYSIS
# Analyst: Oluwasijibomi Oderinde
# Date: April 2026
# ============================================================

# Load libraries
library(tidyverse)
library(lubridate)
library(janitor)
library(scales)
library(patchwork)
library(viridis)

# ------------------------------------------------------------
# Import the cleaned data
# ------------------------------------------------------------
daily <- read_csv("02_Cleaned_Data/daily_activity_clean.csv")
sleep <- read_csv("02_Cleaned_Data/sleep_clean.csv")

# Clean column names
daily <- clean_names(daily)
sleep <- clean_names(sleep)

# Convert dates
daily <- daily %>%
  mutate(activity_date = mdy(activity_date))

sleep <- sleep %>%
  mutate(sleep_date = mdy_hms(sleep_date),
         sleep_date = as.Date(sleep_date))

# Quick check
glimpse(daily)
glimpse(sleep)

# ------------------------------------------------------------
# Create output folder for visuals
# ------------------------------------------------------------
dir.create("03_Insights_and_Visuals", showWarnings = FALSE)

# ------------------------------------------------------------
# Chart 1: Activity Intensity Breakdown
# ------------------------------------------------------------
intensity_summary <- daily %>%
  summarise(
    very_active = sum(very_active_minutes) / n(),
    fairly_active = sum(fairly_active_minutes) / n(),
    lightly_active = sum(lightly_active_minutes) / n(),
    sedentary = sum(sedentary_minutes) / n()
  ) %>%
  pivot_longer(everything(), names_to = "intensity", values_to = "avg_minutes") %>%
  mutate(intensity = factor(intensity, 
                            levels = c("sedentary", "lightly_active", 
                                       "fairly_active", "very_active")))

plot1 <- intensity_summary %>%
  ggplot(aes(x = intensity, y = avg_minutes, fill = intensity)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = paste0(round(avg_minutes), " min")), 
            vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("sedentary" = "#D3D3D3",
                               "lightly_active" = "#A8D8EA",
                               "fairly_active" = "#F4A261",
                               "very_active" = "#E76F51")) +
  labs(
    title = "The Average Day: Mostly Sitting",
    subtitle = "Sedentary minutes dominate—but that's where opportunity hides",
    x = "",
    y = "Average Minutes per Day"
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 18))

print(plot1)
ggsave("03_Insights_and_Visuals/plot1_intensity_breakdown.png", 
       plot1, width = 8, height = 6, dpi = 300)

# ------------------------------------------------------------
# Chart 2: Steps vs Calories
# ------------------------------------------------------------
plot2 <- daily %>%
  ggplot(aes(x = total_steps, y = calories)) +
  geom_point(alpha = 0.4, color = "#2A9D8F") +
  geom_smooth(method = "lm", se = TRUE, color = "#E76F51", linewidth = 1.2) +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Steps = Calories Burned (No Surprise)",
    subtitle = "Every 1,000 steps adds about 50 calories",
    x = "Total Steps",
    y = "Calories Burned"
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 18))

print(plot2)
ggsave("03_Insights_and_Visuals/plot2_steps_vs_calories.png", 
       plot2, width = 8, height = 6, dpi = 300)

# ------------------------------------------------------------
# Chart 3: Sleep vs Next Day Steps
# ------------------------------------------------------------
sleep_activity <- sleep %>%
  left_join(daily, by = c("user_id", "sleep_date" = "activity_date")) %>%
  filter(!is.na(total_steps))

plot3 <- sleep_activity %>%
  filter(total_minutes_asleep < 720) %>%
  ggplot(aes(x = total_minutes_asleep, y = total_steps)) +
  geom_point(alpha = 0.4, color = "#264653") +
  geom_smooth(method = "loess", se = TRUE, color = "#E9C46A", linewidth = 1.2) +
  scale_x_continuous(breaks = seq(0, 720, 120)) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Sleep and Steps: The Sweet Spot",
    subtitle = "6-8 hours of sleep = more steps the next day",
    x = "Minutes Asleep",
    y = "Steps (Next Day)"
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 18))

print(plot3)
ggsave("03_Insights_and_Visuals/plot3_sleep_vs_steps.png", 
       plot3, width = 8, height = 6, dpi = 300)

# ------------------------------------------------------------
# Chart 4: User Segmentation
# ------------------------------------------------------------
user_segments <- daily %>%
  group_by(user_id) %>%
  summarise(
    avg_steps = mean(total_steps),
    days_tracked = n()
  ) %>%
  mutate(segment = case_when(
    avg_steps >= 10000 ~ "High (10k+)",
    avg_steps >= 7000 ~ "Moderate (7-10k)",
    avg_steps >= 4000 ~ "Low (4-7k)",
    TRUE ~ "Sedentary (<4k)"
  ))

segment_counts <- user_segments %>%
  count(segment) %>%
  mutate(segment = factor(segment, 
                          levels = c("Sedentary (<4k)", "Low (4-7k)", 
                                     "Moderate (7-10k)", "High (10k+)")))

plot4 <- segment_counts %>%
  ggplot(aes(x = segment, y = n, fill = segment)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = paste0(n, " users")), vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("#E76F51", "#F4A261", "#2A9D8F", "#264653")) +
  labs(
    title = "User Segmentation: The 10k Club Is Small",
    subtitle = "Only 7 of 33 users average 10,000+ steps daily",
    x = "",
    y = "Number of Users"
  ) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold", size = 18))

print(plot4)
ggsave("03_Insights_and_Visuals/plot4_user_segments.png", 
       plot4, width = 8, height = 6, dpi = 300)

# ------------------------------------------------------------
# Combined Dashboard
# ------------------------------------------------------------
dashboard <- (plot1 + plot2) / (plot3 + plot4) +
  plot_annotation(
    title = "Bellabeat Wellness Insights: What the Data Tells Us",
    theme = theme(plot.title = element_text(face = "bold", size = 22, hjust = 0.5))
  )

print(dashboard)
ggsave("03_Insights_and_Visuals/dashboard_combined.png", 
       dashboard, width = 16, height = 12, dpi = 300)

# Done!
cat("\n\n ========== ANALYSIS COMPLETE ========== \n")
cat("Check the '03_Insights_and_Visuals' folder for your charts.\n")

