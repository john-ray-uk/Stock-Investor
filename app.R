# Load packages ----
library(shiny)
library(bslib)
library(quantmod)

# Source helpers ----
source("helpers.R")
light <- bs_theme()
dark <- bs_theme(bg = "black", fg = "white", primary = "green")
prediction <- 0
shinyLink <- function(to, label) {
  tags$a(
    class = "shiny__link",
    href = to,
    label
  )
}
# User interface ----
ui <- page_sidebar(
  title = tags$span("Stock Investor, by", shinyLink(to = "https://www.johnray.co.uk/", label = "John Ray")),
  theme = light,
  sidebar = sidebar(
    helpText(
      "Welcome to Stock Investor!", br(), br(), "Please input an appropriate Stock Ticker to 
      observe any trends. Visit ", 
      shinyLink(to = "https://finance.yahoo.com/lookup/", label = "this page"), "for a cohesive list 
      of the Stock Tickers that this program uses."),
    textInput("symb", "Symbol", "RCH.L"),
    dateRangeInput(
      "dates",
      "Date range",
      start = "2013-01-01",
      end = as.character(Sys.Date())),
    checkboxInput(
      "log",
      "Change to log scale",
      value = FALSE
    ),
    checkboxInput(
      "adjust",
      "Adjust prices for inflation",
      value = TRUE
    ),
    checkboxInput(
      "truncate",
      "Truncate (round down) trend rate",
      value = TRUE
    ),
    checkboxInput(
      "dark_mode",
      "Dark mode",
      value = FALSE
    )    
  ),
  navset_card_underline(
    nav_panel("Graph",
              uiOutput("trends"),
              card(
                card_header("Historical Trends in Price over Time"),
                plotOutput("plot")
              )),
    
    nav_panel("Graph settings",  card(
      card_header("Choose Graph display settings:"),
      helpText("Only the option selected earliest in the list is shown (e.g 
      selecting Bollinger Bands & CCI will only show Bollinger Bands on the graph). 
      Please see the README.md file for further details and information on the options."),
      checkboxGroupInput(
        "checkGroup", "Settings:",
        choices = list("Add Bollinger Bands" = "addBBands()",
                       "Add CCI" = "addCCI()",
                       "Add WWDMI" = "addADX()",
                       "Add Average True Range" = "addATR()",
                       "Chaiken Money Flow" = "addCMF()",
                       "Add Chande Momentum Oscillator" = "addCMO()",
                       "Add Double Exponential Moving Average" = "addDEMA()",
                       "Add Detrended Price Oscillator" = "addDPO()",
                       "Add Exponential Moving Average" = "addEMA()",
                       "Add Price Envelope" = "addEnvelope()",
                       "Add EVWMA" = "addEVWMA()",
                       "Add Options and Futures Expiration" = "addExpiry()",
                       "Add Moving Average Convergence Divergence" = "addMACD()",
                       "Add Momentum" = "addMomentum()",
                       "Add Rate of Change" = "addROC()",
                       "Add Relative Strength Indicator" = "addRSI()",
                       "Add Parabolic Stop and Reverse" = "addSAR()",
                       "Add Simple Moving Average" = "addSMA()",
                       "Add Stocastic Momentum Index" = "addSMI()",
                       "Add Triple Smoothed Exponential Oscillator" = "addTRIX()",
                       "Add Volume bought" = "addVo()",
                       "Add Weighted Moving Average" = "addWMA()",
                       "Add Williams %R" = "addWPR()",
                       "Add ZLEMA" = "addZLEMA()"),
        selected = character(0)
      )
    )),
    
    nav_panel(
      "About the program",
      markdown(
          paste(
            "About the program:", br(), br(),
            "This program 
            runs as an R 'Shiny App', and uses the R Shinyapp package for its 
            general UI/Server format, R's Bslib package for Bootstrap addons 
            (like the arrow icons, and background themes), and R's old Quantmod 
            package to easily collect financial data in a straightforward format.",
            br(),br(),"Information is collected from ",
            shinyLink(to = "https://finance.yahoo.com/lookup/", label = "Yahoo Finance"),
            " with the Federal Reserve of St. Louis used to calibrate prices to inflation.", br(),br(), 
            "Additionally, this program is heavily built upon the similar 
            Stock Visualiser program from ",
            shinyLink(to = "https://shiny.posit.co/r/getstarted/shiny-basics/lesson6/", label = "Shiny's official 'Get Started' tutorial"), 
            ", so thanks to them too. The complete UI, the graph's settings 
            and server-side code, the dark mode, and the trend rate code was all done by myself, 
            but the log-scale code (including the additional helpers.R file), was copied from the tutorial.", 
            br(), br(), "You can see the full code for this app (consisting of a central app.R 
            file and an additional helpers.R file) on my Open-Source 
            GitHub page ", shinyLink(to = "https://github.com/john-ray-uk/Stock-Investor", label = "HERE"), " .", br(), br(),
            "Thanks for reading, and happy investing!", br(), br(), "John Ray - 2025")
      )
    )))


# Server logic
server <- function(input, output, session) {

  observe(session$setCurrentTheme(
    if (isTRUE(input$dark_mode)) dark
    else light
  ))
  
  graph_colour <- reactive({
      if (isTRUE(input$dark_mode)) "black"
      else "white"
  })
  
  truncate <- reactive({
    if (isTRUE(input$truncate)) {
      paste(percIncr(), " % (truncated)")
    }
    else {
      paste(actualpercIncr(), " %")
    }
  })

  dataInput <- reactive({
    getSymbols(input$symb, src = "yahoo",
               from = input$dates[1],
               to = input$dates[2],
               auto.assign = FALSE)
  })

  percIncr <- reactive({
    cr <- tryCatch(Cl(Stock()))
    first <- as.numeric(first(cr))
    last <- as.numeric(last(cr))
    trunc((last/first)*100 - 100)
  }) 

  actualpercIncr <- reactive({
    cr <- tryCatch(Cl(Stock()))
    first <- as.numeric(first(cr))
    last <- as.numeric(last(cr))
    ((last/first)*100 - 100)
  }) 
  
  
  trend_colour <- reactive({
    if (percIncr() > 100){
      "green"
    }
    else if (percIncr() > 10) {
      "teal"
    }
    else if (percIncr() < -100) {
      "darkred"
    }
    else if (percIncr() < -10) {
      "red"
    }
    else{
      "orange"
    }
    
  })

  trend_icon <- reactive({
    if (percIncr() > 100){
      "arrow-up"
    }
    else if (percIncr() > 10) {
      "arrow-up-right"
    }
    else if (percIncr() < -100) {
      "arrow-down"
    }
    else if (percIncr() < -10) {
      "arrow-down-right"
    }
    else{
      "arrow-down-up"
    }
    
  })
  
  output$trends <- renderUI({
    txt <- truncate()
    value_box(
      title = "Percentage increase:",
      value = txt,
      showcase = bsicons::bs_icon(trend_icon()),
      theme = trend_colour()
    )
  })
  
  Stock <- reactive({
    if (!input$adjust) return(dataInput())
    else adjust(dataInput())
  })

  output$plot <- renderPlot({
    data <- dataInput()
    req(Stock()) 
    gc <- chartTheme(graph_colour()) 

    addOns <- {
      choice <- input$checkGroup
      if (is.null(choice)){
        NULL
      } else {
        choice <- as.character(choice)
      }
    }
    
    
    if (is.null(addOns)) {
      chartSeries(Stock(), theme = gc,
                  type = "auto", log.scale = input$log, TA = NULL)      
    }
    else {
      chartSeries(Stock(), theme = gc,
                  type = "auto", log.scale = input$log, TA = addOns)      
    }
  })
  
}

# Run the app
shinyApp(ui, server)