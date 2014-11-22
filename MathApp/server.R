#server.R
library(reshape)
library(ggplot2)
library(markdown)

df <- data.frame(x = c(1:12),
                 addition = rep("x +",12), sum = rep(NA,12),  
                 multiplication = rep("x * ",12), product = rep(NA,12),
                 stringsAsFactors = FALSE)

my.palette <- c("#D55E00", "#0072B2")

###################################
# BEGIN UTILITY FUNCTIONS
###################################
reshape.df <- function(x, newname) {
  x <- reshape::rename(x, c(variable = newname))
}

tab.heading <- function(tab, operationValue, sliderValue) {
  if (operationValue == 1) {
    paste("Addition", tab, "for Integer Value", sliderValue)
  } 
  else if (operationValue == 2) {
    paste("Multiplcation", tab, "for Integer Value ", sliderValue)
  }
  else if (operationValue == 3) {
    paste("Addition and Multiplcation", tab, "for Integer Value ", sliderValue)
  }
}
###################################
# END UTILITY FUNCTIONS
###################################

shinyServer(function(input, output) {

  calculate.df <- reactive({
    # globally change df dataframe
    for (i in 1:nrow(df)) {
      df$addition[i] <<- toString(paste("x +", toString(input$intSlider), "="))
      # recalulate the sum
      df$sum[i] <<- df$x[i] + input$intSlider
      df$multiplication[i] <<- toString(paste("x *", 
                                              toString(input$intSlider), "="))
      # recalculate the product
      df$product[i] <<- df$x[i] * input$intSlider
    }
  })

  render.table <- reactive({
    calculate.df()
    if (input$radioOperation[1] == 3) { df } 
    else if (input$radioOperation[1] == 1) { df[,1:3] }
    else if (input$radioOperation[1] == 2) { df[,c(1,4:5)] }
  })
  
  melt.df <- reactive({
    calculate.df()
    if (input$radioOperation[1] == 1) {
      dfm <- reshape::melt(df[,c(1,3)], id = "x") 
    } else if (input$radioOperation[1] == 2 ) {
      dfm <- reshape::melt(df[,c(1,5)], id = "x")
    } else if (input$radioOperation[1] == 3 ) {
      dfm <- reshape::melt(df[,c(1,3,5)], id = "x")
    }
  })
  
  create.plot <- reactive({
    dfm <- melt.df() 
    dfm <- reshape.df(dfm, "operation")
    p <- ggplot(dfm, aes(x = x, y = value, label = value))
    p <- p + scale_x_continuous(breaks = seq(0,13,1))
    p <- p + scale_y_continuous(
      limits = c(0,round(max(dfm$value) + 10, -1)),
      breaks = seq(0,round(max(dfm$value) + 10, - 1),10))
    p <- p + geom_point(aes(colour = operation), size = 4)
    p <- p + geom_line(aes(colour = operation))
    p <- p + geom_text(aes(colour = operation, label = value),
                size = 4, show_guide = FALSE,
                hjust = 0, vjust = -2)   
    p <- p + theme(legend.title = element_text(size = 14),
                   legend.text = element_text(size = 12),
                   axis.text = element_text(size = 12))
    
    # color conditional on mathematical operation
    if (input$radioOperation[1] == 1) {
      p <- p + scale_colour_manual(values = my.palette[1])
    } else if (input$radioOperation[1] == 2 ) {
      p <- p + scale_colour_manual(values = my.palette[2])
    } else if (input$radioOperation[1] == 3 ) {
      p <- p + scale_colour_manual(values = my.palette)
    }
    
    # display plot
    p
  })
  
  #---------------------------
  #BEGIN table related output
  #---------------------------
  output$tableText <- renderText({
    tab.heading("Table", input$radioOperation[1], input$intSlider)
  })
  
  output$myTable <- renderDataTable({
    render.table()
  })
  #---------------------------
  #END table related output
  #---------------------------  
  
  #---------------------------
  #BEGIN plot related output
  #---------------------------
  output$plotText <- renderText({
    tab.heading("Plot", input$radioOperation[1], input$intSlider)
  })
  
  output$mainPlot <- renderPlot({
    create.plot()
  })
  #---------------------------
  #END plot related output
  #---------------------------
}
)



