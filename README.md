# Análisis de Rendimiento Físico con R

Proyectos de análisis de datos físicos en fútbol — GPS, tracking y wellness — desarrollados con R como parte del diplomado **FC Barcelona Hub: Análisis de Datos Físicos para Sport Scientists**.

🌐 **Portafolio en vivo:** [reme1982.github.io/sport_scientists](https://reme1982.github.io/sport_scientists)

---

## Proyectos

| # | Proyecto | Herramientas | Descripción |
|---|---|---|---|
| S01 | [Análisis de Sesiones GPS](S01_gps_session_analysis/) | tidyverse · ggrepel · patchwork | Perfil de carga física por posición en sesiones de entrenamiento MD-3 / MD-4 |
| S02 | [Fatiga Física — Tracking Metrica](S02_metrica_fatigue/) | tidyverse · zoo | Velocidad desde tracking a 25 Hz, zonas de esfuerzo, índice de fatiga 1T vs 2T |
| S03 | [Dashboard de Wellness](S03_wellness_dashboard/) | Shiny · ggplot2 | App interactiva de monitoreo diario — Sueño, Fatiga, alertas por zona de color |

---

## S01 — Análisis de Sesiones GPS

Monitoreo de carga física de un plantel profesional en dos sesiones pre-partido.

**Hallazgos clave:**
- Los extremos y laterales acumulan la mayor distancia HSR — demanda específica por posición
- La sesión MD-3 muestra mayor carga por minuto que MD-4, conforme se acerca el partido
- El mapa de z-scores identifica jugadores con sobrecarga o bajo rendimiento respecto a su grupo posicional

📄 [Ver notebook completo →](https://reme1982.github.io/sport_scientists/S01_gps_session_analysis/GPS_Session_Analysis.html)

**Stack:** `tidyverse` · `ggrepel` · `patchwork` · datos GPS (23 métricas por sesión)

---

## S02 — Análisis de Fatiga con Tracking Metrica Sports

Velocidad y fatiga a partir de **Metrica Sports Sample Game 1** — datos de tracking abiertos a 25 Hz.

**Metodología:**
- Parseo de CSV crudo multi-encabezado (formato Metrica)
- Conversión de coordenadas normalizadas (0–1) a metros reales (cancha 105 × 68 m)
- Cálculo de velocidad por diferencia de posición a 0.04 s (25 Hz)
- Media móvil (k = 5) para eliminar ruido del sensor
- Clasificación en 5 zonas: Caminando / Trote / Carrera / HSR / Sprint
- Comparación de distancia HSR por jugador entre 1er y 2do tiempo

**Hallazgo principal:** La mayoría de los jugadores muestra una caída medible en carreras a alta velocidad durante el segundo tiempo — un patrón de fatiga normal pero cuantificable que orienta los cambios.

📄 [Ver notebook completo →](https://reme1982.github.io/sport_scientists/S02_metrica_fatigue/Metrica_Fatigue_Analysis.html)

**Stack:** `tidyverse` · `zoo` · `patchwork` · Metrica Sports open data

---

## S03 — Dashboard Interactivo de Wellness

Aplicación Shiny para el monitoreo diario del bienestar del plantel.

**Funcionalidades:**
- Filtro por jugador, métrica y rango de fechas
- Gráfico de tendencia en línea o barras
- Tarjetas KPI con código de colores por zona (Verde / Ámbar / Rojo)
- Mapa de calor comparativo entre jugadores en el período seleccionado
- Sistema de semáforo: ≥ 7 Bien · 4–6 Precaución · < 4 Alerta

**Stack:** `shiny` · `tidyverse` · `scales`

---

## Cómo ejecutar

```r
# Instalar paquetes necesarios
install.packages(c("tidyverse", "zoo", "patchwork", "ggrepel",
                   "scales", "shiny", "rmarkdown"))

# S01 y S02 — Abrir el .Rmd en RStudio y hacer Knit
# S03 — Ejecutar la app Shiny
shiny::runApp("S03_wellness_dashboard/app.R")
```

---

## Contexto

Estos proyectos fueron desarrollados como parte del diplomado **FC Barcelona Hub — Análisis de Datos Físicos con R para Sport Scientists**. Aplican flujos de trabajo reales de Ciencia del Deporte a datos abiertos: monitoreo de carga GPS, análisis de tracking crudo y gestión del bienestar del plantel.

---

## Fuentes de Datos

- **GPS:** Datos de sesiones de entrenamiento de equipo profesional (anonimizados)
- **Tracking:** [Metrica Sports Open Data](https://github.com/metrica-sports/sample-data) — libre para educación e investigación
- **Wellness:** Respuestas simuladas de cuestionario diario de bienestar

---

## Stack Tecnológico

**R** · tidyverse · ggplot2 · Shiny · zoo · patchwork · ggrepel · rmarkdown

---

---

# Sport Science Analytics with R

Physical performance analysis projects using GPS tracking and wellness data — built with R as part of the **FC Barcelona Hub** diploma in Physical Data Analysis for Sport Scientists.

🌐 **Live portfolio:** [reme1982.github.io/sport_scientists](https://reme1982.github.io/sport_scientists)

| # | Project | Tools | Description |
|---|---|---|---|
| S01 | [GPS Session Analysis](S01_gps_session_analysis/) | tidyverse · ggrepel · patchwork | Physical load profiling by position across MD-3 / MD-4 training sessions |
| S02 | [Physical Fatigue — Metrica Tracking](S02_metrica_fatigue/) | tidyverse · zoo | Velocity from 25 Hz raw tracking, effort zones, HSR fatigue index 1st vs 2nd half |
| S03 | [Wellness Monitoring Dashboard](S03_wellness_dashboard/) | Shiny · ggplot2 | Interactive Shiny app for daily squad wellness — Sleep, Fatigue, color-coded alerts |

**Data sources:** [Metrica Sports Open Data](https://github.com/metrica-sports/sample-data) · Anonymized GPS training data · Simulated wellness questionnaire
