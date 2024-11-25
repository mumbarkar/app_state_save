# devtools::load_all()
source("./R/ui.R")
source("./R/server.R")
source("./R/utility.R")

# Launch the application
shinyApp(ui, server)
