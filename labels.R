
library(ggplot2)

responses <- c("One", "Two", "Three", "Four", "Five")

# The data
df <- data.frame(
  group = c(rep("A", 5), rep("B", 5)),
  response = factor(rep(responses, 2), levels = responses),
  pct = c(
    24, 34, 39, 2, 1,
    27, 58, 10, 5, 2
  )
)

# Add label text
df$label <- paste0(df$pct, "%")
df$label1 <- ifelse(df$pct > 5, paste0(df$pct, "%"), "")
df$label2 <- ifelse(df$pct > 5, "", paste0(df$pct, "%"))

# Add fill colors
pal <- substr(viridisLite::cividis(5), 1, 7)
df$fillcolor <- pal[as.numeric(df$response)]
df$fillcolor2 <- ifelse(df$pct > 5, NA, paste0(df$fillcolor, "AA"))

# Add label colors
contrast_color <- function(color) {
  hcl <- farver::decode_colour(
    colour = color,
    to = "hcl"
  )

  ifelse(hcl[, "l"] > 50, "#000000", "#FFFFFF")
}

df$labelcolor <- contrast_color(df$fillcolor)

# Plot
plot <- ggplot(
  data = df,
  aes(x = pct, y = group, label = label, fill = fillcolor)
) +
  geom_bar(
    stat = "identity",
    position = position_stack(reverse = TRUE)
  ) +
  scale_fill_identity(
    name = "Responses",
    labels = df$response,
    breaks = df$fillcolor,
    guide = "legend"
  )

# ggplot2 alone
fig1 <- plot +
  geom_text(
    aes(label = label),
    position = position_stack(
      vjust = .5,
      reverse = TRUE
    ),
    color = df$labelcolor,
    fontface = "bold"
  ) +
  labs(title = "ggplot2 alone")

# ggrepel alone
fig2 <- plot +
  ggrepel::geom_text_repel(
    aes(label = label),
    position = position_stack(
      vjust = .5,
      reverse = TRUE
    ),
    color = df$labelcolor,
    fontface = "bold",
    show.legend = FALSE,
    direction = "y"
  ) +
  labs(title = "ggrepel alone")

# ggplot2 + ggrepel
fig3 <- plot +
  geom_text(
    aes(label = label1),
    position = position_stack(
      vjust = .5,
      reverse = TRUE
    ),
    color = df$labelcolor,
    fontface = "bold"
  ) +
  ggrepel::geom_label_repel(
    aes(label = label2),
    position = position_stack(
      vjust = .5,
      reverse = TRUE
    ),
    color = df$labelcolor,
    fill = df$fillcolor2,
    fontface = "bold",
    show.legend = FALSE,
    direction = "y"
  ) +
  labs(title = "ggplot2 + ggrepel")

pw1 <- patchwork::wrap_plots(
  fig1, fig2, fig3, ncol = 1, guides = "collect", axes = "collect"
)

ggsave("plots.svg", pw1, width = 6, height = 5)
