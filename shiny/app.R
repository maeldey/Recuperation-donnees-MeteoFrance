#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


# List of required packages ----------------------------------------------------
required_packages <- c("tidyverse", 
                       "sf", 
                       "shiny", 
                       "leaflet", 
                       "colourpicker", 
                       "DT")

# Check and install missing packages
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}
library(tidyverse)
library(shiny)
library(sim2MeteoFrance)
library(bslib)

# SIM2 data : points location import -------------------------------------------

# Points location import
sim2_points <- recuperation_points_de_grille_SAFRAN()


# User chose one or several points to import data from the user interface
# User interface construction : page with a sidebar
ui <- page_sidebar(
  # Title of the interface (in french)
  title = "Points de grille SAFRAN de Météo-France",
  # Sidebar
  sidebar = sidebar(
    # Sidebar setting
    width = "15%",
    title = "Options",
    # Colour picker
    colourInput(
      inputId = "color",
      label = "Couleur des points :",
      value = "orange"
    ),
    # Display selected points
    br("Identifiant du point sélectionné : "),
    verbatimTextOutput("clicked_id"), 
    # Export points
    actionLink(inputId = 'download_points', label = 'Télécharger les points de gille SAFRAN')
  ), 
  # Main panel
  card(
    full_screen = TRUE,
    # Explanation text
    tags$p(
      paste0(
        "Zoomez et sélectionnez le ou les points de grille ",
        "dont vous souhaitez récupérer les données météorologiques."
      )
    ),
    # Map
    leafletOutput("map", height = "100%")
  )
)


# Server get action made by the user
server <- function(input, output, session) {
  # Generate map with Leaflet library
  output$map <- renderLeaflet({
    sim2_points %>% 
      leaflet() %>%
      # Add map's background
      addTiles() %>%
      # Change background to OpenTopoMap
      addProviderTiles(providers$OpenTopoMap) %>%
      # DIsplay polygons
      addPolygons(
        layerId = ~ID,
        stroke = TRUE,
        opacity = 1,
        fillColor = input$color,
        fillOpacity = 0.3,
        color = input$color
      )
  })
  
  # Update on click
  # Saving locally selected cells
  selected_id <- reactiveVal(NULL)
  
  observeEvent(input$map_shape_click, {
    # Save data of the point
    selected_id(input$map_shape_click$id)
  })
  
  # Print their id
  output$clicked_id <- renderPrint({
    paste(selected_id())
  })
}

shinyApp(ui, server)
