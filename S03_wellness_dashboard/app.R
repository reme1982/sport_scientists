library(shiny)
library(tidyverse)
library(scales)

# ── Datos ─────────────────────────────────────────────────────────────────────
data_raw <- read.csv("data/data_wellness.csv") %>%
  select(Nombre = Name, Fecha = Date, Valor = Value, Metrica = Metric) %>%
  mutate(
    Fecha   = as.Date(Fecha),
    Metrica = recode(Metrica,
      "Sleep"   = "Sueño",
      "Fatigue" = "Fatiga",
      "Stress"  = "Estrés",
      "Soreness"= "Dolor Muscular"
    )
  )

jugadores <- sort(unique(data_raw$Nombre))
metricas  <- sort(unique(data_raw$Metrica))

color_zona <- function(puntuacion) {
  case_when(
    puntuacion >= 7 ~ "#2ecc71",   # verde
    puntuacion >= 4 ~ "#f39c12",   # ámbar
    TRUE            ~ "#e74c3c"    # rojo
  )
}

# ── Interfaz ──────────────────────────────────────────────────────────────────
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background-color: #f4f6f9; font-family: 'Segoe UI', sans-serif; }
    .well { background: #fff; border: 1px solid #dee2e6; border-radius: 8px; }
    h2 { color: #2c3e50; font-weight: 700; }
    .tarjeta-metrica { background: #fff; border-radius: 8px; padding: 16px;
                       margin-bottom: 12px; border-left: 5px solid #3498db;
                       box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
    .valor-metrica { font-size: 2rem; font-weight: 700; }
    .etiqueta-metrica { font-size: 0.85rem; color: #7f8c8d;
                        text-transform: uppercase; }
  "))),

  titlePanel(
    div(
      h2("Dashboard de Monitoreo de Wellness"),
      p("Seguimiento diario del estado físico y bienestar del plantel",
        style = "color:#7f8c8d")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      width = 3,

      selectInput("jugador", "Jugador",
                  choices  = c("Todos los jugadores", jugadores),
                  selected = jugadores[1]),

      checkboxGroupInput("metricas", "Métricas",
                         choices  = metricas,
                         selected = metricas),

      dateRangeInput("fechas", "Rango de Fechas",
                     start     = min(data_raw$Fecha),
                     end       = max(data_raw$Fecha),
                     min       = min(data_raw$Fecha),
                     max       = max(data_raw$Fecha),
                     separator = "hasta",
                     language  = "es"),

      radioButtons("tipo_grafico", "Tipo de Gráfico",
                   choices  = c("Línea" = "linea", "Barras" = "barras"),
                   selected = "linea"),

      hr(),
      p("Guía de zonas:", style = "font-weight:600; margin-bottom:4px"),
      div(
        style = "display:flex; gap:8px; flex-wrap:wrap;",
        div(style = "background:#2ecc71; color:white; padding:2px 10px;
                     border-radius:12px; font-size:0.8rem", "7–10 Bien"),
        div(style = "background:#f39c12; color:white; padding:2px 10px;
                     border-radius:12px; font-size:0.8rem", "4–6 Precaución"),
        div(style = "background:#e74c3c; color:white; padding:2px 10px;
                     border-radius:12px; font-size:0.8rem", "0–3 Alerta")
      )
    ),

    mainPanel(
      width = 9,

      # Tarjetas KPI
      uiOutput("tarjetas_kpi"),

      br(),

      # Gráfico principal de tendencia
      plotOutput("grafico_tendencia", height = "380px"),

      br(),

      # Comparación entre jugadores (solo cuando se selecciona "Todos")
      conditionalPanel(
        condition = "input.jugador == 'Todos los jugadores'",
        plotOutput("grafico_comparacion", height = "280px")
      )
    )
  )
)

# ── Servidor ──────────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  datos_filtrados <- reactive({
    df <- data_raw %>%
      filter(
        Metrica %in% input$metricas,
        Fecha   >= input$fechas[1],
        Fecha   <= input$fechas[2]
      )
    if (input$jugador != "Todos los jugadores") {
      df <- df %>% filter(Nombre == input$jugador)
    }
    df
  })

  # Tarjetas KPI: último promedio por métrica
  output$tarjetas_kpi <- renderUI({
    df <- datos_filtrados()
    if (nrow(df) == 0) return(NULL)

    ultimo_dia <- df %>%
      filter(Fecha == max(Fecha)) %>%
      group_by(Metrica) %>%
      summarise(promedio = round(mean(Valor, na.rm = TRUE), 1), .groups = "drop")

    tarjetas <- map(seq_len(nrow(ultimo_dia)), function(i) {
      m   <- ultimo_dia$Metrica[i]
      val <- ultimo_dia$promedio[i]
      clr <- color_zona(val)
      div(
        class = "tarjeta-metrica",
        style = paste0("border-left-color:", clr),
        div(class = "valor-metrica", style = paste0("color:", clr), val),
        div(class = "etiqueta-metrica", m),
        div(style = "font-size:0.78rem; color:#95a5a6",
            paste("Último promedio ·", format(max(df$Fecha), "%d %b")))
      )
    })

    fluidRow(map(tarjetas, ~ column(3, .x)))
  })

  # Gráfico de tendencia
  output$grafico_tendencia <- renderPlot({
    df <- datos_filtrados()
    if (nrow(df) == 0) return(NULL)

    df_agg <- df %>%
      group_by(Fecha, Metrica, Nombre) %>%
      summarise(Valor = mean(Valor), .groups = "drop")

    p <- ggplot(df_agg,
                aes(x     = Fecha,
                    y     = Valor,
                    color = if (input$jugador == "Todos los jugadores") Nombre else Metrica,
                    group = interaction(Nombre, Metrica)))

    if (input$tipo_grafico == "linea") {
      p <- p + geom_line(size = 1) + geom_point(size = 2.5)
    } else {
      p <- p +
        geom_col(
          aes(fill = if (input$jugador == "Todos los jugadores") Nombre else Metrica),
          position = "dodge", alpha = 0.85
        )
    }

    p +
      geom_hline(yintercept = c(4, 7), linetype = "dashed",
                 color = "gray70", size = 0.4) +
      annotate("rect", xmin = -Inf, xmax = Inf, ymin = 7, ymax = 10,
               alpha = 0.04, fill = "#2ecc71") +
      annotate("rect", xmin = -Inf, xmax = Inf, ymin = 4, ymax = 7,
               alpha = 0.04, fill = "#f39c12") +
      annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = 4,
               alpha = 0.04, fill = "#e74c3c") +
      scale_y_continuous(limits = c(0, 10.5), breaks = seq(0, 10, 2)) +
      scale_color_brewer(palette = "Set1") +
      scale_fill_brewer(palette = "Set1") +
      facet_wrap(~Metrica) +
      labs(
        title = "Tendencia de Wellness",
        x     = NULL,
        y     = "Puntuación (0–10)",
        color = NULL,
        fill  = NULL
      ) +
      theme_minimal(base_size = 13) +
      theme(
        legend.position  = "bottom",
        panel.grid.minor = element_blank(),
        strip.text       = element_text(face = "bold")
      )
  })

  # Mapa de calor de comparación entre jugadores
  output$grafico_comparacion <- renderPlot({
    df <- data_raw %>%
      filter(
        Metrica %in% input$metricas,
        Fecha   >= input$fechas[1],
        Fecha   <= input$fechas[2]
      ) %>%
      group_by(Nombre, Metrica) %>%
      summarise(prom = round(mean(Valor, na.rm = TRUE), 1), .groups = "drop")

    ggplot(df, aes(x = Metrica, y = Nombre, fill = prom)) +
      geom_tile(color = "white", size = 0.8) +
      geom_text(aes(label = prom), size = 4.5, fontface = "bold") +
      scale_fill_gradient2(
        low      = "#e74c3c",
        mid      = "#f39c12",
        high     = "#2ecc71",
        midpoint = 5,
        limits   = c(1, 10)
      ) +
      labs(
        title = "Promedio de Wellness por Jugador — Resumen del Período",
        x     = NULL,
        y     = NULL,
        fill  = "Promedio"
      ) +
      theme_minimal(base_size = 13) +
      theme(panel.grid = element_blank())
  })
}

shinyApp(ui = ui, server = server)
