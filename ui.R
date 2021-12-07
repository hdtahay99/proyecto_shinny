library(shiny)
require(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)
library(leaflet)
library(googleway)



ui <- dashboardPage(
    title = 'Historical Stock Data by Company', skin = 'purple',
    dashboardHeader(title = "Historical Stock Data by Company", titleWidth = 335),
    dashboardSidebar(width = 335,sidebarMenu(
    menuItem(
        "Dashboard",
        tabName = "dashboard",
        icon = icon("mortar-board")),
    menuItem(
        "readme",
        tabName = "readme",
        icon = icon("dashboard")),
    uiOutput("output_range_year"),
    uiOutput("output_list_type"),
    uiOutput("output_list_common_name")
)),


    dashboardBody(
        tabItems(
            tabItem(tabName = "readme",
                    fluidPage(
                        tags$iframe(src = './readme.html', 
                                    width = '100%', height = '800px', 
                                    frameborder = 0, scrolling = 'auto'
                        )
                    )
            ),
        tabItem(tabName = "dashboard",
        tabsetPanel(
            fluidRow(
                tabBox(id = "tabset1", height = "650px", width=12, title = "Dashboard",  ## change box size here
                       tabPanel("Data",
                                fluidRow(
                                    valueBoxOutput("Companies"),
                                    valueBoxOutput("Avarage"),
                                    valueBoxOutput("Data"),
                                    box(
                                        title = "Density",
                                        status = "success",
                                        solidHeader = TRUE,
                                        plotOutput("render_plot3", height = "250px")
                                    ),
                                    box(
                                        title = "Behavior",
                                        status = "success",
                                        solidHeader = TRUE,
                                        plotOutput("render_plot4", height = "250px")
                                    ),
                                    box(
                                        title = "Volume",
                                        status = "success",
                                        solidHeader = TRUE,
                                        plotOutput("render_plot", height = "250px",
                                                   brush = 'mouse_brush')
                                    ),

                                    box(
                                        title = "Brush Data",
                                        status = "success",
                                        solidHeader = TRUE,
                                        DT::dataTableOutput('table_output', height = "250px")
                                    )
                                )
                       ),
                       tabPanel("URL Parameters",
                                fluidRow(
                                    box(
                                        title = "URL Components",
                                        status = "success",
                                        solidHeader = TRUE,
                                        verbatimTextOutput("urlText"),
                                        height="250px",
                                        width=12
                                ))),
                       
                       tabPanel("Map",
                                fluidRow(leafletOutput("mmap", height = "700px")
                                    ))
                ))))
    )))

