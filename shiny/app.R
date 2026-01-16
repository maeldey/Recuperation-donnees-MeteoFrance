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
    verbatimTextOutput("clicked_id"), # Export points
    actionLink(inputId = 'download_points', label = 'Télécharger les points de gille SAFRAN')
  ), 
  # Main panel
  card(
    # Explaination text
    tags$p(
      paste0(
        "Zoomez et sélectionnez le ou les points de grille ",
        "dont vous souhaitez récupérer les données météorologiques."
      )
    ),
    # Map
    leafletOutput("map"),
    # Data
    DTOutput("table")
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
      # Change points style
      addCircleMarkers(
        layerId = ~ID,
        stroke = FALSE,
        fillOpacity = 1,
        color = input$color
      )
  })
  
  # Get points clicked id
  observeEvent(input$map_marker_click, {
    # Save data of the point
    click <- input$map_marker_click
    # Print its id
    output$clicked_id <- renderPrint({
      paste(as.character(click$id))
    })
  })
}

shinyApp(ui, server)
