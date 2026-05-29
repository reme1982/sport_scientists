# Sport Science Analytics with R

Physical performance analysis projects using GPS tracking, force plate, and wellness data — built with R as part of the **FC Barcelona Hub** diploma in Physical Data Analysis for Sport Scientists.

---

## Projects

| # | Project | Tools | Description |
|---|---|---|---|
| S01 | [GPS Session Analysis](S01_gps_session_analysis/) | tidyverse · ggrepel · patchwork | Physical load profiling by position across two training sessions (MD-3 / MD-4) — distance, HSR, player load, z-score monitoring |
| S02 | [Physical Fatigue — Metrica Tracking](S02_metrica_fatigue/) | tidyverse · zoo | Velocity computation from 25 Hz raw tracking data, effort zone classification, HSR fatigue index comparing 1st vs 2nd half |
| S03 | [Wellness Monitoring Dashboard](S03_wellness_dashboard/) | Shiny · ggplot2 | Interactive Shiny app for daily player wellness tracking — Sleep & Fatigue trends with color-coded zone alerts |

---

## Project S01 — GPS Session Analysis

Physical load monitoring for a professional football squad across two pre-match training sessions.

**Key findings:**
- Wide players (EXTREMO/LATERAL) accumulate the highest HSR distances — position-specific demand
- MD-3 shows higher load/min than MD-4 as proximity to match day increases
- Z-score heatmap identifies outliers: players overloading or underperforming vs their position group

**Tech:** `tidyverse` · `ggrepel` · `patchwork` · GPS data (23 metrics per session)

---

## Project S02 — Physical Fatigue Analysis

Velocity and fatigue analysis using **Metrica Sports Sample Game 1** — open tracking data at 25 Hz.

**Methodology:**
- Parse multi-header raw tracking CSV (Metrica format)
- Convert normalized coordinates (0–1) to real pitch meters (105 × 68 m)
- Compute velocity via Pythagorean distance between frames at 0.04 s intervals
- Apply rolling mean (k = 5) to remove sensor noise
- Classify 5 velocity zones: Walk / Jog / Run / HSR / Sprint
- Compare HSR distance per player between 1st and 2nd half

**Key finding:** Most players show a measurable drop in high-speed running in the second half — a normal but quantifiable fatigue pattern that informs substitution timing.

**Tech:** `tidyverse` · `zoo` · `patchwork` · Metrica Sports open data

---

## Project S03 — Wellness Monitoring Dashboard

An interactive Shiny application for daily wellness tracking across a squad.

**Features:**
- Filter by player, metric, and date range
- Line or bar chart visualization
- KPI summary cards with color-coded zone alerts (Green / Amber / Red)
- Player comparison heatmap across the monitoring period
- Traffic-light system: ≥ 7 = Good · 4–6 = Caution · < 4 = Alert

**Tech:** `shiny` · `tidyverse` · `scales`

---

## How to Run

```r
# Install required packages
install.packages(c("tidyverse", "zoo", "patchwork", "ggrepel",
                   "scales", "shiny", "rmarkdown"))

# S01 & S02 — Knit the RMarkdown notebooks in RStudio
# S03 — Run the Shiny app
shiny::runApp("S03_wellness_dashboard/app.R")
```

---

## Background

These projects were developed as part of the **FC Barcelona Hub — Análisis de Datos Físicos con R para Sport Scientists** diploma. They apply real-world Sport Science workflows to open datasets: GPS load monitoring, raw tracking analysis, and player wellness management.

---

## Data Sources

- **GPS data:** Anonymized training session data (fictional squad)
- **Metrica Sports tracking:** [github.com/metrica-sports/sample-data](https://github.com/metrica-sports/sample-data) — free for education and research
- **Wellness data:** Simulated daily wellness questionnaire responses

---

## Tech Stack

**R** · tidyverse · ggplot2 · Shiny · zoo · patchwork · ggrepel · rmarkdown

---

---

## Football Analytics con R — Ciencia del Rendimiento Físico

Proyectos de análisis de rendimiento físico con datos GPS, tracking y wellness — desarrollados en R durante el diplomado **FC Barcelona Hub** en Análisis de Datos Físicos para Sport Scientists.

| # | Proyecto | Herramientas | Descripción |
|---|---|---|---|
| S01 | [Análisis de Sesiones GPS](S01_gps_session_analysis/) | tidyverse · ggrepel · patchwork | Perfil de carga física por posición en dos sesiones de entrenamiento (MD-3 / MD-4) |
| S02 | [Fatiga Física — Tracking Metrica](S02_metrica_fatigue/) | tidyverse · zoo | Cálculo de velocidad desde datos de tracking a 25 Hz, zonas de esfuerzo, índice de fatiga 1T vs 2T |
| S03 | [Dashboard de Wellness](S03_wellness_dashboard/) | Shiny · ggplot2 | App interactiva para monitoreo diario de wellness con alertas por zona de color |

## Fuente de Datos

- **Tracking:** [Metrica Sports Open Data](https://github.com/metrica-sports/sample-data) — libre para educación e investigación
- **GPS:** Datos de sesiones de entrenamiento (equipo ficticio)
- **Wellness:** Cuestionario diario simulado
