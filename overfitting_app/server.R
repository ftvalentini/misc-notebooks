library(tidyverse)
library(shiny)
library(shinythemes)
library(glue)

server = function(input, output, session) {
  
  randomData = reactive({
    make_data(seed=RANDOM_SEED, n_rows=input$n, coef_value=input$coef_value
              ,degree=input$degree_dgp, error_size=input$error_size)
  })
  TestIdx = reactive({
    set.seed(RANDOM_SEED)
    sample(nrow(randomData()), TESTDATA_PROPORTION*nrow(randomData()), rep=F)
  })
  Models = reactive({
    train_models(randomData(), TestIdx(), complexity_vec=COMPLEXITIES)
  })
  Metrics = reactive({
    eval_models(Models(), randomData(), TestIdx())
  })
  
  output$plot_performance = renderPlotly({
    plot_performance(Metrics(), complexity_vec=COMPLEXITIES)
  })
  
  output$plot_data = renderPlotly({
    plot_data(randomData(), TestIdx(), Models()
              ,input$degree_fitted, input$coef_value,input$degree_dgp) 
  })
  
}
