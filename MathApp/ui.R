# ui.R

shinyUI(fluidPage(
  
  titlePanel("Addition and Multiplication Tables and Plots"),
  
  sidebarLayout(
    sidebarPanel(
      helpText(strong("Create addition and multiplication tables and plots 
for numbers 1 through 12!"), p()),
      
      sliderInput('intSlider', 
                  label = "Select a number to add and/or multiply by",
                  min = 1, max = 12, value = 1
      ),
      br(),
      radioButtons("radioOperation", 
                  label = "Select the desired mathematical operation:",
                  choices = list(
                    "Addition" = 1,
                    "Multiplication" = 2,
                    "Both" = 3
                    )
      )
      ), #end sidebarPanel
    
    mainPanel(
      tabsetPanel(
        tabPanel("Table", 
                 fluidRow(
                   h4(textOutput("tableText")),
                   p(),
                   dataTableOutput("myTable"))),
        
        tabPanel("Plot", 
                 fluidRow(
                   h4(textOutput("plotText")),
                   p(),
                   plotOutput(outputId = "mainPlot")
                   )),
        
        tabPanel("About",
                 fluidRow(
                   #About.md in same directory as ui.R and server.R
                   includeMarkdown("About.md")))
        )
      ) # end  mainPanel
    ) # end sidebarLayout  
  ) # end fluidPage 
) # end shinyUI

