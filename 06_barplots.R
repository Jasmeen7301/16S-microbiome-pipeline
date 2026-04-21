library(dplyr)
library(ggplot2)
library(scales)

# ── Colour palettes ───────────────────────────────────────────────────────────
# Standard colours used for aphid endosymbionts:
# Buchnera (grey)              '#DDDDDD'
# Spiroplasma                  '#0CB0A9'
# Hamiltonella defensa         '#FBAF69'
# Regiella insecticola         '#7B415E'
# Serratia symbiotica          '#118AB2'
# Serratia other               '#073B4C'
# Rickettsiella viridis        '#FFD166'
# Rickettsia                   '#BD8962'
# Wolbachia                    '#B85880'
# Arsenophonus                 '#806991'
# Pantoea                      '#86C188'
# Other non-endosymbiotic      'grey65'

# Palette for aphid samples
pal_a <- c('#DDDDDD', '#0CB0A9', 'grey65', '#FBAF69', '#7B415E', '#073B4C')

# Preview palette
show_col(pal_a, labels = FALSE)

# ── Load data ─────────────────────────────────────────────────────────────────
# Update path to your data file
my_data_a <- read.csv(file = "/path/to/your/data.txt", sep = "\t")

# Fix factor order to match input spreadsheet (overrides alphabetical sorting)
my_data_a$bacteria <- factor(
  my_data_a$bacteria,
  levels = c(
    "Buchnera aphidicola",
    "Spiroplasma",
    "Other non-endosymbiotic bacteria",
    "Hamiltonella defensa"
  )
)

# Get unique sample names
unique_aphids <- unique(my_data_a$aphid)
dput(as.character(unique_aphids))

# Rearrange facet panels — update order to match your samples
aphid_levels <- unique(c("Tilst", "Orrild", "Aarhus_KT", "Aarhus_GD"))

# ── Plot ──────────────────────────────────────────────────────────────────────
my_plot_histogram_a <- ggplot(
  my_data_a,
  aes(x = aphid, y = abundance, fill = bacteria)
) +
  geom_bar(position = "fill", stat = "identity", width = 0.7) +
  ylab("Relative Abundance") +
  theme(
    panel.background = element_blank(),
    axis.text.x = element_text(
      angle = 90, hjust = 1.0, vjust = 0.5, size = 10, face = 'bold'
    ),
    axis.text.y = element_text(size = 11, face = 'bold'),
    axis.title.x = element_text(margin = margin(t = 20), size = 10, face = "bold"),
    axis.title.y = element_text(margin = margin(r = 15), size = 10, face = "bold"),
    legend.position = "right",
    legend.text = element_text(size = 10, face = "italic"),
    legend.title = element_text(size = 10)
  ) +
  scale_fill_manual(values = pal_a)

# Display plot
my_plot_histogram_a

# ── Save plot ─────────────────────────────────────────────────────────────────
# Update output path as needed
ggplot2::ggsave(
  file.path("/path/to/output", "barplot_samples.jpeg"),
  plot = my_plot_histogram_a,
  device = "jpeg",
  width = 10,
  height = 8,
  units = "in",
  dpi = 300
)
