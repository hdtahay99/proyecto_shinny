
    
dataset <- 
    read.csv('weekly_assets_yf.csv',
             stringsAsFactors = F,
             header = T)


click_output <- NULL


server <- function(input, output, session) {
    plot1 <- qplot(rnorm(500),fill=I("red"),binwidth=0.2,title="plotgraph1")
    output$plot<-renderPlot({plot1})
    
    output$output_range_age <- renderUI({
        min_age <- dataset %>% summarise(value = min(common_name), .groups = 'drop')
        max_age <-
            dataset %>% summarise(value = max(common_name), .groups = 'drop')
        sliderInput(
            "slide_range_age",
            "Select a range:",
            min = min_age$value,
            max = max_age$value - 2,
            value = c(40, 60)
        )
    })

    
    output$output_list_gender <- renderUI({
        list_gender <- dataset %>% distinct(common_name)
        items_gender <- as.character(list_gender$common_name)
        selectInput("rdb_list_company",
                     "Select Company:",
                     choices = items_gender)
    })
    
    output$output_list_number_prods <- renderUI({
        count_prods <- dataset %>% distinct(type) %>% nrow() - 2
        min_count_prods <-
            dataset %>% summarise(value = min(type), .groups = 'drop')
        max_count_prods <-
            dataset %>% summarise(value = max(type), .groups = 'drop')
        numericInput(
            inputId = "num_list_prods",
            label = "Number of products:",
            value = count_prods,
            min = min_count_prods$value,
            max = max_count_prods$value
        )
    })
    
    output$output_list_country <- renderUI({
        list_country <- dataset %>% distinct(type)
        items_country <- as.character(list_country$type)
        checkboxGroupInput("chk_list_type",
                           "Select a Type:",
                           choices = items_country)
    })
    
    observe({
  
        
        count_company <-
            dataset %>% distinct(common_name) %>% nrow() - 2
        
        total_balance <-
          dataset %>% distinct(common_name) %>% nrow() - 2
        
        count_active <-
          dataset %>% distinct(common_name) %>% nrow() - 2
        
        output$Companies <- renderValueBox({
            valueBox(

                formatC(count_company , format = "d", big.mark = ',')
                ,
                paste('Companies')
                ,
                icon = icon("share-alt", lib = 'glyphicon')
                ,
                color = "purple"
            )
            
        })
        
        output$Avarage <- renderValueBox({
            valueBox(
                prettyNum(total_balance , big.mark = ',')
                ,
                'Avarage'
                ,
                icon = icon("usd", lib = 'glyphicon')
                ,
                color = "green"
            )
            
        })
        
        output$Data <- renderValueBox({
            valueBox(
                formatC(count_active, format = "d", big.mark = ',')
                ,
                paste('Data')
                ,
                icon = icon("ok", lib = 'glyphicon')
                ,
                color = "yellow"
            )
            
        })
        
        output$urlText <- renderText({
            paste(
                sep = "",
                "protocol: ",
                session$clientData$url_protocol,
                "\n",
                "hostname: ",
                session$clientData$url_hostname,
                "\n",
                "pathname: ",
                session$clientData$url_pathname,
                "\n",
                "port: ",
                session$clientData$url_port,
                "\n",
                "search: ",
                queryString,
                "\n"
            )
        })
        
    })
    
    
    
    output$render_plot <- renderPlot({
        ggplot(data = dataset,
               aes(x = common_name , y = type))
        
    })
    
    output$render_box_plot <- renderPlot({
        ggplot(data = dataset,
               aes(
                   x = common_name,
                   y = type,
                   fill = hq_aprox_location_lat,
                   group = 1
               )) +
            geom_boxplot() +
            facet_wrap(~ hq_aprox_location_lat)
    })
  
}