# Database setup
library(DBI)
library(RSQLite)

con <- dbConnect(SQLite(), "app_state.db")

# Create a table to store the state
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS state (
    id INTEGER PRIMARY KEY,
    state_data TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
  )
")
# dbDisconnect(con)
