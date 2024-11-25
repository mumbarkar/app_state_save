library(shiny)
library(DBI)
library(RSQLite)
library(jsonlite)

server <- function(input, output, session) {
  # Connect to the database
  db_con <- dbConnect(SQLite(), "app_state.db")
  
  # Ensure the state table exists
  dbExecute(db_con, "
    CREATE TABLE IF NOT EXISTS state (
      id INTEGER PRIMARY KEY,
      state_data TEXT,
      timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ")
  
  # Restore the last saved state on app startup
  isolate({browser()
    result <- dbGetQuery(db_con, "SELECT state_data FROM state ORDER BY timestamp DESC LIMIT 1")
    if (nrow(result) > 0 && !is.null(result$state_data[1]) && nzchar(result$state_data[1])) {
      saved_state <- fromJSON(result$state_data[1])
      updateTextInput(session, "text", value = saved_state$text)
      updateSliderInput(session, "slider", value = saved_state$slider)
    } else {
      showNotification("No valid saved state found in the database!", type = "warning")
    }
  })
  
  # Throttled saving of app state
  throttled_state <- reactive({
    debounce({
      list(
        text = input$text,
        slider = input$slider
      )
    }, millis = 2000)  # Save every 2 seconds
  })
  
  # Save the state to the database whenever the throttled state updates
  observe({
    state <- throttled_state()
    if (!is.null(state)) {
      json_state <- toJSON(state, auto_unbox = TRUE)
      dbExecute(db_con, "INSERT INTO state (state_data) VALUES (?)", params = list(json_state))
    }
  })
  
  # Cleanup old states in the database, keeping only the last 5 states
  observe({
    dbExecute(db_con, "
      DELETE FROM state WHERE id NOT IN (
        SELECT id FROM state ORDER BY timestamp DESC LIMIT 5
      )
    ")
  })
  
  # Display current state for debugging
  output$currentState <- renderPrint({
    list(
      text = input$text,
      slider = input$slider
    )
  })
  
  # Disconnect from the database when the session ends
  onStop(function() {
    dbDisconnect(db_con)
  })
}

shinyApp(ui, server)
