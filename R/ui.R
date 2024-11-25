library(shiny)

ui <- fluidPage(
  titlePanel("Throttled Automatic State Management"),
  sidebarLayout(
    sidebarPanel(
      textInput("text", "Enter Text", "Sample Text"),
      sliderInput("slider", "Slider", min = 0, max = 100, value = 50)
    ),
    mainPanel(
      verbatimTextOutput("currentState")
    )
  )
)
