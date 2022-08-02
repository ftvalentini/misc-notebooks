library(tidyverse)
library(shiny)
library(shinythemes)
library(glue)
library(plotly)

# param -------------------------------------------------------------------

RANDOM_SEED = 42
COMPLEXITIES = 1:20
TESTDATA_PROPORTION = 0.8

# helpers ---------------------------------------------------------------

# MSE
mse = function(a, b) sum((a - b)**2) / length(b)

# return conditional mean of a polynomic DGP with data x, coef and degree
dgp = function(x, period) {
  res = x + sin(period * x) 
  return(res)
}

# make random data
make_data = function(seed, n_rows, complexity, error_size) {
  set.seed(seed)
  x = runif(n_rows, 0, 1)
  f_x = dgp(x, period=complexity)
  epsilon_sd = error_size * (max(f_x) - min(f_x)) 
  epsilon = rnorm(n_rows, mean=0, sd=epsilon_sd) # 'error' es una proporcion del rango de y
  y = f_x + epsilon
  dat = data.frame(x=x, y=y)
  return(dat)
}

# train many models according to flexibility
train_models = function(dat, test_idx, complexity_vec) {
  models = complexity_vec %>%
    map(function(f) loess(y ~ x, data=dat[-test_idx,], span=1/f, 
                          control=loess.control(surface="direct")))
  return(models)
}

# eval many fitted models according to flexibility
eval_models = function(models, dat, test_idx) {
  preds = models %>% map(function(m) predict(m, dat))
  preds_train = preds %>% map(function(x) x[-test_idx])
  preds_test = preds %>% map(function(x) x[test_idx])
  mses_train = preds_train %>% map_dbl(function(p) mse(dat$y[-test_idx], p))
  mses_test = preds_test %>% map_dbl(function(p) mse(dat$y[test_idx], p))
  out = list(train=mses_train, test=mses_test)
  return(out)
}

# plot performance by flexibility
plot_performance = function(models_results, complexity_vec) {
  gdat = data.frame(
    flexibility = complexity_vec
    ,mse_train = models_results$train
    ,mse_test = models_results$test
  ) %>%
    gather(metric, value, -flexibility) 
  g = ggplot(gdat, aes(x=flexibility, y=value, color=metric)) +
    geom_line(size=0.8, alpha=0.8) +
    theme_minimal() +
    theme(legend.title=element_blank()) +
    labs(caption="MSE", y=NULL, x="Model flexibility") +
    NULL
  return(g)
}

# plot DGP and fitted curve
plot_data = function(dat, test_idx, models, flexibility_fitted, period) {
  gdat = dat %>%
    slice(-test_idx) %>%
    mutate(fitted = predict(models[[flexibility_fitted]], x))
  labels = c("DGP", glue("Fitted (smooth.=", round(1/flexibility_fitted, 3), ")"))
  g = ggplot(gdat, aes(x=x)) +
    geom_point(aes(y=y), color="black", shape=21, alpha=0.5, cex=0.8) +
    stat_function(
      aes(color=labels[1]), fun=function(x) dgp(x, period), cex=1
    ) +
    geom_line(aes(y=fitted, color=labels[2]), size=0.5) +
    theme_minimal() +
    scale_color_manual(
      values = c("navy", "red") %>% setNames(labels)
    ) +
    theme(
      legend.title=element_blank()
      ,axis.text.x=element_blank()
      ,axis.text.y=element_blank()
    ) +
    labs(
      caption=glue("Training data ({100-TESTDATA_PROPORTION*100}% of all data)")
    ) +
    NULL
    return(g)
}


# TEXT OF APP -------------------------------------------------------------

appText = function() {
  div(
    p(
      "As explained in "
      ,a("this post", href="http://ftvalentini.github.io/misc-notebooks/bias-variance.html")
      ,", the size and shape of the bias-variance trade-off in any supervised problem is determined by:" 
      ,tags$ul(
        tags$li("the flexibility of the modelling method")
        ,tags$li("the complexity of the data generating process")
        ,tags$li("the irreducible variability of the target variable")
      )
    )
    ,hr()
    ,p(
      "In this example, we assume a sinusoidal data generating process (DGP) such that \\(y = f(X) + \\epsilon\\) and \\(f(X) = X + \\sin(\\beta X) \\). "
    )
    ,p(
      "The periodicity \\(\\beta\\) of the function defines the complexity of the DGP: "
      ,"the larger (smaller) it is, the more (less) complex it is. "
    )
    ,p(  
      "The irreducible error is given by \\(Var(\\epsilon)\\)."
      ,"When it is larger (smaller), the prediction error of the fitted model on test data is larger (smaller)."
      ,"In this example, the variance of the error is defined in the second slider as a proportion of the range of the true outcome \\(y\\)."
    )
    ,p(
      "We assume we fit a local regression (LOESS) on \\(X\\) in order to predict \\(y\\)."
      ,"The degree of smoothing \\(\\alpha\\) defines the flexibility of the model: "
      ,"the larger (smaller) it is, the less (more) flexible it is. Therefore, the flexibility is given by \\(1 / \\alpha\\)."
    )
    ,p(
      "On the leftmost plot the MSE of all flexibilities 1 through 20 are plotted. "
      ,"On the rightmost plot only one fitted model is shown, with the flexibility as fixed in the third slider."
    )
    ,p(
      "Data is generated at random each time any of the sliders’ values is modified, except for the smoothing degree of the fitted LOESS."
    )
  )  
  
}



