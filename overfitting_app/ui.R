
ui = fluidPage(
  theme=shinythemes::shinytheme("flatly")
  ,withMathJax()
  ,h2("Overfitting, bias and variance")
  ,appText()
  ,hr()
  ,column(3
          ,wellPanel(
            h4("Complexity of DGP")
            ,helpText("Degree of periodicity of DGP")
            ,sliderInput("complexity_dgp", label=NULL
                         ,min=0, max=50, value=0, step=2)
          )
  )
  ,column(3
          ,wellPanel(
            h4("Variance of DGP")
            ,helpText("Size of DGP's irreducible error")
            ,sliderInput("error_size", label=NULL
                         ,min=0, max=0.5, value=0.2, step=0.025)
          )
  )
  ,column(3
          ,wellPanel(
            h4("Flexibility of fit")
            ,helpText("\\(1 / \\alpha\\) of LOESS fitted in right plot")
            ,sliderInput("flexibility_fitted", label=NULL
                         ,min=1, max=20, value=1, step=1)
          )
  )
  ,column(3
          ,wellPanel(
            h4("Population size")
            ,helpText("Size of training+test data")
            ,sliderInput("n", label=NULL
                         ,min=600, max=3600, value=1000, step=100)
          )
  )
  ,column(6
          ,h4(strong("Training and Test MSE"))
          ,plotlyOutput("plot_performance")
          ,p("MSE")
  )
  ,column(6
          ,h4(strong("Population, DGP and Fitted Curve"))
          ,plotOutput("plot_data")
          # ,plotlyOutput("plot_data")
          # NOTE plotly stopped working with aes_function 2022-08
          ,p(glue("Training data ({100-TESTDATA_PROPORTION*100}% of all data)"))
  )
  ,column(12
          ,hr()
  )
  
)




