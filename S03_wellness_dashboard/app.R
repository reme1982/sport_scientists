library(shiny)
library(tidyverse)
library(scales)

# ── Data ──────────────────────────────────────────────────────────────────────
data_raw <- read.csv("data/data_wellness.csv") %>%
  select(Name, Date, Value, Metric) %>%
  mutate(Date = as.Date(Date))

players  <- sort(unique(data_raw$Name))
metrics  <- sort(unique(data_raw$Metric))

# Threshold reference: for Sleep higher = better, for Fatigue lower = better
# We invert Fatigue so the wellness score is always "higher = better"
INVERT_METRICS <- c("Fatigue", "Stress", "Soreness")

zone_color <- function(score) {
  case_when(score >= 7  ~ "#2ecc71",   # green
            score >= 4  ~ "#f39c12",   # amber
            TRUE        ~ "#e74c3c")   # red
}

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background-color: #f4f6f9; font-family: 'Segoe UI', sans-serif; }
    .well { background: #fff; border: 1px solid #dee2e6; border-radius: 8px; }
    h2 { color: #2c3e50; font-weight: 700; }
    .metric-box { background: #fff; border-radius: 8px; padding: 16px;
                  margin-bottom: 12px; border-left: 5px solid #3498db;
                  box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
    .metric-value { font-size: 2rem; font-weight: 700; }
    .metric-label { font-size: 0.85rem; color: #7f8c8d; text-transform: uppercase; }
  "))),

  titlePanel(
    div(h2("Wellness Monitoring Dashboard"),
        p("Daily player wellness tracking — Sleep & Fatigue", style = "color:#7f8c8d"))
  ),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      selectInput("player", "Player",
                  choices  = c("All players", players),
                  selected = players[1]),

      checkboxGroupInput("metrics", "Metrics",
                         choices  = metrics,
                         selected = metrics),

      dateRangeInput("dates", "Date Range",
                     start = min(data_raw$Date),
                     end   = max(data_raw$Date),
                     min   = min(data_raw$Date),
                     max   = max(data_raw$Date)),

      radioButtons("chart_type", "Chart Type",
                   choices  = c("Line" = "line", "Bar" = "bar"),
                   selected = "line"),

      hr(),
      p("Score guide:", style = "font-weight:600; margin-bottom:4px"),
      div(style = "display:flex; gap:8px; flex-wrap:wrap;",
          div(style = "background:#2ecc71; color:white; padding:2px 10px; border-radius:12px; font-size:0.8rem", "7–10 Good"),
          div(style = "background:#f39c12; color:white; padding:2px 10px; border-radius:12px; font-size:0.8rem", "4–6 Caution"),
          div(style = "background:#e74c3c; color:white; padding:2px 10px; border-radius:12px; font-size:0.8rem", "0–3 Alert"))
    ),

    mainPanel(
      width = 9,

      # KPI summary cards
      uiOutput("kpi_cards"),

      br(),

      # Main trend chart
      plotOutput("trend_plot", height = "380px"),

      br(),

      # Player comparison (only when "All players" selected)
      conditionalPanel(
        condition = "input.player == 'All players'",
        plotOutput("compare_plot", height = "280px")
      )
    )
  )
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  filtered <- reactive({
    df <- data_raw %>%
      filter(
        Metric %in% input$metrics,
        Date   >= input$dates[1],
        Date   <= input$dates[2]
      )
    if (input$player != "All players") {
      df <- df %>% filter(Name == input$player)
    }
    df
  })

  # KPI cards: latest average per metric
  output$kpi_cards <- renderUI({
    df <- filtered()
    if (nrow(df) == 0) return(NULL)

    latest <- df %>%
      filter(Date == max(Date)) %>%
      group_by(Metric) %>%
      summarise(avg = round(mean(Value, na.rm = TRUE), 1), .groups = "drop")

    cards <- map(seq_len(nrow(latest)), function(i) {
      m   <- latest$Metric[i]
      val <- latest$avg[i]
      clr <- zone_color(val)
      div(class = "metric-box",
          style = paste0("border-left-color:", clr),
          div(class = "metric-value", style = paste0("color:", clr), val),
          div(class = "metric-label", m),
          div(style = "font-size:0.78rem; color:#95a5a6",
              paste("Latest avg ·", format(max(df$Date), "%b %d"))))
    })

    fluidRow(map(cards, ~ column(3, .x)))
  })

  # Trend chart
  output$trend_plot <- renderPlot({
    df <- filtered()
    if (nrow(df) == 0) return(NULL)

    # Group by player if showing all
    aes_group <- if (input$player == "All players") "Name" else "Metric"

    df_agg <- df %>%
      group_by(Date, Metric, Name) %>%
      summarise(Value = mean(Value), .groups = "drop")

    p <- ggplot(df_agg, aes(x = Date, y = Value,
                             color = if (input$player == "All players") Name else Metric,
                             group = interaction(Name, Metric)))

    if (input$chart_type == "line") {
      p <- p + geom_line(size = 1) + geom_point(size = 2.5)
    } else {
      p <- p + geom_col(aes(fill = if (input$player == "All players") Name else Metric),
                        position = "dodge", alpha = 0.85)
    }

    p +
      geom_hline(yintercept = c(4, 7), linetype = "dashed", color = "gray70", size = 0.4) +
      annotate("rect", xmin = -Inf, xmax = Inf, ymin = 7, ymax = 10,
               alpha = 0.04, fill = "#2ecc71") +
      annotate("rect", xmin = -Inf, xmax = Inf, ymin = 4, ymax = 7,
               alpha = 0.04, fill = "#f39c12") +
      annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = 4,
               alpha = 0.04, fill = "#e74c3c") +
      scale_y_continuous(limits = c(0, 10.5), breaks = seq(0, 10, 2)) +
      scale_color_brewer(palette = "Set1") +
      scale_fill_brewer(palette = "Set1") +
      facet_wrap(~Metric) +
      labs(title = "Wellness Trend", x = NULL, y = "Score (0–10)",
           color = NULL, fill = NULL) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom",
            panel.grid.minor = element_blank(),
            strip.text = element_text(face = "bold"))
  })

  # Player comparison heatmap (when all players selected)
  output$compare_plot <- renderPlot({
    df <- data_raw %>%
      filter(
        Metric %in% input$metrics,
        Date   >= input$dates[1],
        Date   <= input$dates[2]
      ) %>%
      group_by(Name, Metric) %>%
      summarise(avg_score = round(mean(Value, na.rm = TRUE), 1), .groups = "drop")

    ggplot(df, aes(x = Metric, y = Name, fill = avg_score)) +
      geom_tile(color = "white", size = 0.8) +
      geom_text(aes(label = avg_score), size = 4.5, fontface = "bold") +
      scale_fill_gradient2(low = "#e74c3c", mid = "#f39c12", high = "#2ecc71",
                           midpoint = 5, limits = c(1, 10)) +
      labs(title = "Player Average Wellness — Period Summary",
           x = NULL, y = NULL, fill = "Avg Score") +
      theme_minimal(base_size = 13) +
      theme(panel.grid = element_blank())
  })
}

shinyApp(ui = ui, server = server)
