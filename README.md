# **Stock Investor**
This is the GitHub page for my Stock Investor program! This program uses R's "Shiny App" framework to make a neat and basic web application. The program is heavily built upon the Stock Visualiser program from 
[Shiny's official 'Get Started' tutorial]("https://shiny.posit.co/r/getstarted/shiny-basics/lesson6/), especially with regards to the helpers.R file and the log-scale code. The entirety of the User Interface,
the graph's main settings and server-side code, the dark mode, and the trend rate code was all done by myself.

This program enables the user to input Stock Tickers and a date range to show a graph of how the input company's stocks have varied over time. It is highly customisable, and enables all available addons 
from the QuantMod library to be added to the graph (such as Bollinger Bands, the Rate of Change of Stock, the Volume of stocks, etc.), and can be corrected for inflation or put on a log-scale.

This program uses Financial Information collected from [Yahoo Finance](https://finance.yahoo.com/lookup/) as part of R's [QuantMod](https://www.quantmod.com/) package. Further data from the Federal Reserve of
St. Louis used to calibrate prices to inflation (specifically USD inflation, hence the stock values are relative to the US dollar).

For the program to function correctly, three R packages must be downloaded: QuantMod (for quantitative trading), BSlib (for Bootstrap CSS & HTML formatting, as well as icons), and, of course, Shiny itself for the 
basic web application. An additional installation of Yahoo Finance data may also be required.

This has been a really fun project to work on (beside all the annoying bugs), and at some point I may repeat it with machine-learning to predict trends in stock prices. We'll see. For now, I hope you enjoy it, 
this program marks a lot of firsts for me; it's my first Web Application, my first R program, and my first insight into the Bootstrap CSS framework. Hopefully, many more (and better) Web Apps and R projects are to come! :)

