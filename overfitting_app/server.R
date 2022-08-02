library(tidyverse)
library(shiny)
library(shinythemes)
library(glue)

server = function(input, output, session) {
  
  randomData = reactive({
    make_data(seed=RANDOM_SEED, n_rows=input$n
              ,complexity=input$complexity_dgp, error_size=input$error_size)
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
  
  # NOTE plotly stopped working with aes_function 2022-08
  # output$plot_data = renderPlotly({
  output$plot_data = renderPlot({
    plot_data(randomData(), TestIdx(), Models()
              ,input$flexibility_fitted, input$complexity_dgp) 
  })
  
}
