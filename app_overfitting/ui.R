
ui = fluidPage(
  theme=shinythemes::shinytheme("sandstone")
  ,h2("Overfitting, bias and variance")
  ,p(
    "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem "
    ,"Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem "
    ,"Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem "
  )
  ,br()
  ,column(4
          ,wellPanel(
            h4("Complexity of DGP")
            ,helpText("Degree of polynomial of DGP")
            ,sliderInput("degree_dgp", label=NULL
                         ,min=1, max=20, value=1, step=1)
          )
  )
  ,column(4
          ,wellPanel(
            h4("Variance of DGP")
            ,helpText("Size of DGP's irreducible error")
            ,sliderInput("error_size", label=NULL
                         ,min=0.05, max=0.5, value=0.05, step=0.05)
          )
  )
  ,column(4
          ,wellPanel(
            h4("Complexity of fit")
            ,helpText("Degree of polynomial fitted in rightmost plot")
            ,sliderInput("degree_fitted", label=NULL
                         ,min=1, max=20, value=1, step=1)
          )
  )
  ,column(2
          ,wellPanel(
            h4("Population size")
            ,helpText("Size of training+test data")
            ,sliderInput("n", label=NULL
                         ,min=10, max=1000, value=200, step=50)
          )
          ,wellPanel(
            h4("Coefficients' values")
            ,helpText("Value of DGP's polynomial coefficients")
            ,sliderInput("coef_value", label=NULL
                         ,min=-3, max=3, value=0.1, step=0.05)
          )
  )
  ,column(5
          ,h4("Training and Test MSE")
          ,plotlyOutput("plot_performance")
  )
  ,column(5
          ,h4("Population, DGP and Fitted Curve")
            ,plotlyOutput("plot_data")
    )
)




