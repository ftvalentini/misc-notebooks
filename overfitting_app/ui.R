
ui = fluidPage(
  theme=shinythemes::shinytheme("sandstone")
  ,withMathJax()
  ,h2("Overfitting, bias and variance")
  ,appText()
  ,hr()
  ,column(3
          ,wellPanel(
            h4("Complexity of DGP")
            ,helpText("Degree of polynomial of DGP")
            ,sliderInput("degree_dgp", label=NULL
                         ,min=1, max=20, value=1, step=1)
          )
  )
  ,column(3
          ,wellPanel(
            h4("Variance of DGP")
            ,helpText("Size of DGP's irreducible error")
            ,sliderInput("error_size", label=NULL
                         ,min=0.05, max=0.5, value=0.15, step=0.05)
          )
  )
  ,column(3
          ,wellPanel(
            h4("Flexibility of fit")
            ,helpText("Degree of polynomial fitted in right plot")
            ,sliderInput("degree_fitted", label=NULL
                         ,min=1, max=20, value=1, step=1)
          )
  )
  ,column(3
          ,wellPanel(
            h4("Population size")
            ,helpText("Size of training+test data")
            ,sliderInput("n", label=NULL
                         ,min=100, max=1000, value=500, step=50)
          )
  )
  ,column(6
          ,h4(strong("Training and Test MSE"))
          ,plotlyOutput("plot_performance")
  )
  ,column(6
          ,h4(strong("Population, DGP and Fitted Curve"))
          ,plotlyOutput("plot_data")
  )
)




