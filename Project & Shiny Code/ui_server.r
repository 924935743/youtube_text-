library(shiny)
library(tm)
library(tidytext)
library(wordcloud)
library(memoise)




ui<- fluidPage(
  titlePanel("Word Cloud of Tags"),
    
  sidebarLayout(
      sidebarPanel(
      selectInput("selection", "Choose a country:",
                  choices = names(tag_countries)),
      actionButton("update", "Change"),
      hr(),
      sliderInput("freq",
                  "Minimum Frequency:",
                  min = 100,  max = 1000, value = c(100,200)),
      sliderInput("max","Number of Word:",
                  2,300,2,step=5,
                  animate = animationOptions(interval=1000,loop=T))
    ),

    # Show Word Cloud
    mainPanel(
      plotOutput("plot")
    )
  )
)


server<-function(input, output, session) {
  terms <- reactive({
    input$update
    isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        getTermMatrix(input$selection)
      })
    })
  })
  
  # Make the wordcloud drawing predictable during a session
  wordcloud_rep <- repeatable(wordcloud)
  
  output$plot <- renderPlot({
    v <- terms()
    wordcloud_rep(names(v), v, scale=c(4,0.5),
                  min.freq = input$freq, max.words=input$max,
                  colors=brewer.pal(8, "Dark2"))
  })
}

shinyApp(ui, server)


