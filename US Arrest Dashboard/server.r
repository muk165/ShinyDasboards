## Shiny Server component for dashboard

function(input, output, session){
  
  
    # scatter plot the mtcars dataset - mpg vs hp
    output$graph <- renderPlot({
      ggplot(data = mtcars, aes(x = mpg, y = hp)) +
        geom_point()
    })
    
    
    # # To display the mtcars dataset on the left side in the app
    # output$data <- renderTable({
    #  head(mtcars)
    # })
    #brushed points
    output$data_brush <-  renderTable({
      n = nrow(brushedPoints(mtcars, brush = input$plot_brush)) # row count will be 0 when no selection made by the brush
      if(n==0)  
        return()
      else
        brushedPoints(mtcars, brush = input$plot_brush) # return rows
      # argument allRows = TRUE can also be used
      ## It will add another column (selected_) to the actual dataset. True indicates that data point 
      # corresponding to that row was under the brush. False means data corresponding to that row wasn't selected by brush
    })
  
  
  #visitor counter
  output$counter <- 
    renderText({
      if (!file.exists("counter.Rdata")) 
        counter <- 0
      else
        load(file="counter.Rdata")
      counter  <- counter + 1
      save(counter, file="counter.Rdata")     
      paste("Hits: ", counter)
    })
  
  
  #interactive scatter plot
  output$x1 = DT::renderDataTable(cars, server = FALSE)
  
  # highlight selected rows in the scatterplot
  output$x2 = renderPlot({
    s = input$x1_rows_selected
    # cars %>% 
    #   ggplot(aes(speed,dist)) +
    #   geom_point()
    plot(cars)
    if (length(s)) {
      points(cars[s,,drop = FALSE], pch = 19, cex = 2)
    }
  })
  
  
  # Data table Output
  output$dataT <- renderDataTable(my_data)
  
  
  # Rendering the box header  
  output$head1 <- renderText(
    paste("5 states with high rate of", input$var2, "Arrests")
  )
  
  # Rendering the box header 
  output$head2 <- renderText(
    paste("5 states with low rate of", input$var2, "Arrests")
  )
  
  
  # Rendering table with 5 states with high arrests for specific crime type
  output$top5 <- renderTable({
    
    my_data %>% 
      select(State, input$var2) %>% 
      arrange(desc(get(input$var2))) %>% 
      head(5)
    
  })
  
  # Rendering table with 5 states with low arrests for specific crime type
  output$low5 <- renderTable({
    
    my_data %>% 
      select(State, input$var2) %>% 
      arrange(get(input$var2)) %>% 
      head(5)
    
    
  })
  
  
  # For Structure output
  output$structure <- renderPrint({
    my_data %>% 
      str()
  })
  
  
  # For Summary Output
  output$summary <- renderPrint({
    my_data %>% 
      summary()
  })
  
  # For histogram - distribution charts
  output$histplot <- renderPlotly({
    p1 = my_data %>% 
      plot_ly() %>% 
      add_histogram(x=~get(input$var1)) %>% 
      layout(xaxis = list(title = paste(input$var1)))
    
    
    p2 = my_data %>%
      plot_ly() %>%
      add_boxplot(x=~get(input$var1)) %>% 
      layout(yaxis = list(showticklabels = F))
    
    # stacking the plots on top of each other
    subplot(p2, p1, nrows = 2, shareX = TRUE) %>%
      hide_legend() %>% 
      layout(title = "Distribution chart - Histogram and Boxplot",
             yaxis = list(title="Frequency"))
  })
  
  
  ### Bar Charts - State wise trend
  output$bar <- renderPlotly({
    my_data %>% 
      plot_ly() %>% 
      add_bars(x=~State, y=~get(input$var2)) %>% 
      layout(title = paste("Statewise Arrests for", input$var2),
             xaxis = list(title = "State"),
             yaxis = list(title = paste(input$var2, "Arrests per 100,000 residents") ))
  })
  
  
  ### Scatter Charts 
  output$scatter <- renderPlotly({
    p = my_data %>% 
      ggplot(aes(x=get(input$var3), y=get(input$var4))) +
      geom_point() +
      geom_smooth(method=get(input$fit)) +
      labs(title = paste("Relation b/w", input$var3 , "and" , input$var4),
           x = input$var3,
           y = input$var4) +
      theme(  plot.title = element_textbox_simple(size=10,
                                                  halign=0.5))
    
    
    # applied ggplot to make it interactive
    ggplotly(p)
    
  })
  
  
  ## Correlation plot
  output$cor <- renderPlotly({
    my_df <- my_data %>% 
      select(-State)
    
    # Compute a correlation matrix
    corr <- round(cor(my_df), 1)
    
    # Compute a matrix of correlation p-values
    p.mat <- cor_pmat(my_df)
    
    corr.plot <- ggcorrplot(
      corr, 
      hc.order = TRUE, 
      lab= TRUE,
      outline.col = "white",
      p.mat = p.mat
    )
    
    ggplotly(corr.plot)
    
  })
  
  
  # Choropleth map
  output$map_plot <- renderPlot({
    new_join %>% 
      ggplot(aes(x=long, y=lat,fill=get(input$crimetype) , group = group)) +
      geom_polygon(color="black", size=0.4) +
      scale_fill_gradient(low="#73A5C6", high="#001B3A", name = paste(input$crimetype, "Arrest rate")) +
      theme_void() +
      #labs(title = paste(input$crimetype , " Arrests per 100,000 residents by state")) +
      theme(
        plot.title = element_textbox_simple(face="bold", 
                                            size=20,
                                            halign=0.5),
       # legend.position = c(0.2, 0.1),
        legend.direction = "horizontal"
        
      ) +
      geom_text(aes(x=x, y=y, label=abb), size = 4, color="white")
    
    
    
  })
  
  
  
}

