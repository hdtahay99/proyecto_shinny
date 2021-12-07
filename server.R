dataset <- 
    read.csv('weekly_assets_yf.csv',
             stringsAsFactors = F,
             header = T)


click_output <- NULL


server <- function(input, output, session) {
  plot1 <- qplot(rnorm(500),fill=I("red"),binwidth=0.2,title="plotg")
  output$plot<-renderPlot({plot1})
    
    output$output_range_year <- renderUI({
        min_year <- dataset %>% summarise(value = min(Year), .groups = 'drop')
        max_year <-
            dataset %>% summarise(value = max(Year), .groups = 'drop')
        sliderInput(
            "slide_range_year",
            "Select a range:",
            min = min_year$value,
            max = max_year$value ,
            value = c(2000, 2021)
        )
    })

    
    output$output_list_common_name <- renderUI({
        list_common_name <- dataset %>% distinct(common_name)
        items_common_name <- as.character(list_common_name$common_name)
        checkboxGroupInput("rdb_list_company",
                     "Select Company:",
                     choices = items_common_name)
    })
    
    
    output$output_list_type <- renderUI({
        list_type <- dataset %>% distinct(type)
        items_type <- as.character(list_type$type)
        selectInput("chk_list_type",
                           "Select a Type:",
                            choices = items_type, 
                            multiple = TRUE)
    })
    
    observe({
      checked_type <- input$chk_list_type
      selected_range <- input$slide_range_year
      selected_common_name <- input$rdb_list_company
      count_company <- 0
      total_Volume <- 0
      count_data <- 0
      queryString <- ""
      
      if (!is.null(selected_range) &
          !is.null(selected_common_name)) {
        query <- parseQueryString(session$clientData$url_search)
        if (is.null(query$minYear)) {
          queryString <-
            paste0(
              "?minYear=",
              selected_range[1],
              "&maxYear=",
              selected_range[2],
              "&common_name=",
              selected_common_name
            )
        }
        else{
          queryString <-
            paste0(
              "?minYear=",
              query$minYear,
              "&maxYear=",
              query$maxYear,
              "&common_name=",
              query$common_name
            )
        }
        
        updateQueryString(queryString)
        
        if (!is.null(query$minYear) &
            !is.null(query$maxYear) &
            !is.null(query$common_name)) {
          updateSliderInput(session,
                            "slide_range_year",
                            value = c(query$minYear, query$maxYear))
          
          updateRadioButtons(session, "rdb_list_company",
                             selected = query$common_name)
        }
        
        total_Volume <-
          dataset %>% filter(Year >= selected_range[1] &
                               Year <= selected_range[2]) %>% filter(common_name == selected_common_name) %>% 
                                                              summarise(value = sum(Volume), .groups = 'drop')
        total_Volume <- total_Volume$value
        count_data <-
          dataset %>% filter(Year >= selected_range[1] &
                               Year <= selected_range[2]) %>% filter(common_name == selected_common_name)  %>% nrow()
        
      }
      
      if (!is.null(checked_type) &
          !is.null(selected_range) &
          !is.null(selected_common_name)) {
 
        
        total_Volume <-
          dataset %>% filter(type %in% checked_type) %>% filter(Year >=
                                                                          selected_range[1] &
                                                                          Year <= selected_range[2]) %>% 
                                                                          filter(common_name == selected_common_name) %>% summarise(value = sum(Volume), .groups = 'drop')
        count_data <-
          dataset %>% filter(type %in% checked_type) %>% filter(Year >=
                                                                          selected_range[1] &
                                                                          Year <= selected_range[2]) %>% 
                                                                          filter(common_name == selected_common_name) %>% nrow()
        
      }
        
        count_company <-
            dataset %>% distinct(common_name) %>% nrow() - 2
      
        
        output$Companies <- renderValueBox({
            valueBox(
                formatC(count_company , format = "d", big.mark = ','),
                paste('Total Companies'),
                icon = icon("share-alt", lib = 'glyphicon'),
                color = "red"
            )
            
        })
        
        output$Avarage <- renderValueBox({
            valueBox(
                prettyNum(total_Volume , big.mark = ','),
                'Volume',
                icon = icon("usd", lib = 'glyphicon'),
                color = "green"
            )
            
        })
        
        output$Data <- renderValueBox({
            valueBox(
                formatC(count_data, format = "d", big.mark = ','),
                paste('Data'),
                icon = icon("ok", lib = 'glyphicon'),
                color = "purple"
            )
            
        })
        
        output$urlText <- renderText({
            paste(
                "URL Components: ",
                session$clientData$url_protocol,
                session$clientData$url_hostname,
                session$clientData$url_pathname,
                queryString,
                "\n"
            )
        })
        
    })
    
    ploteo <- reactive({
      checked_type <- input$chk_list_type
      selected_range <- input$slide_range_year
      selected_common_name <- input$rdb_list_company
      
      if (!is.null(checked_type) &
          !is.null(selected_range) &
          !is.null(selected_common_name)) {
        graficado <-
          dataset %>% filter(Year >= selected_range[1] &
                               Year <= selected_range[2]) %>% filter(common_name == selected_common_name)
      }
      if (!is.null(checked_type) &
          !is.null(selected_range) &
          !is.null(selected_common_name)) {
        graficado <-
          dataset %>% filter(type %in% checked_type) %>% filter(Year >= selected_range[1] &
                                                                          Year <= selected_range[2]) %>% 
                                                                          filter(common_name == selected_common_name)
      }
      else{
        if (is.null(checked_type) &
            !is.null(selected_range) &
            !is.null(selected_common_name)) {
          graficado <-
            dataset  %>% filter(Year >= selected_range[1] &
                                  Year <= selected_range[2]) %>% 
                                  filter(common_name == selected_common_name)
        }
        else{
          graficado <-
            dataset %>% filter(Year >= 2000 &
                                 Year <= 2021) %>% filter(common_name == "AMD")
        }
      }
      
      if (!is.null(input$mouse_brush)) {
        df <-
          brushedPoints(graficado,
                        input$mouse_brush,
                        xvar = 'Year',
                        yvar = 'Volume')
        out <- df %>%
          select(Year, Volume)
        
        click_output <<- out %>% dplyr::distinct()
        output$table_output = DT::renderDataTable({
          brks <-
            quantile(click_output,
                     probs = seq(.05, .95, .05),
                     na.rm = TRUE)
          clrs <-
            round(seq(255, 40, length.out = length(brks) + 1), 0) %>%
            {
              paste0("rgb(255,", ., ",", ., ")")
            }
          
          datatable(click_output) %>% formatStyle(
            'Volume')
        })
      }
      
      return(graficado)
      
    })
    
    output$render_plot3 <- renderPlot({
      ggplot(data = ploteo(), aes(x=Volume, y=..density..,fill=common_name))+
        geom_histogram()+
        geom_density()
      
    })
    
    output$render_plot4 <- renderPlot({
      ggplot(data = ploteo(),
             aes(x = Year , y = Close))  +
        geom_line(aes(colour = factor(common_name))) +
        geom_point(aes(colour = factor(common_name))) +
        labs(colour = "common_name")
    })
    
    output$render_plot <- renderPlot({
        ggplot(data = ploteo(),
               aes(x = Year , y = Volume))  +
        geom_point(aes(colour = factor(common_name))) +
        labs(colour = "common_name")
    })
    
    output$mmap <- renderLeaflet({
      leaflet() %>%
        addTiles(
          urlTemplate = "//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        ) %>%
        addMarkers(data = ploteo(), lng = ~hq_aprox_location_lon,
                   lat = ~hq_aprox_location_lat)
    })
}