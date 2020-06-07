library(tidyverse)
library(shiny)
library(shinythemes)
library(glue)
library(plotly)

# param -------------------------------------------------------------------

RANDOM_SEED = 25
COMPLEXITIES = 1:20
TESTDATA_PROPORTION = 0.2
BETAS_VALUE = 0.1

# helpers ---------------------------------------------------------------

# MSE
mse = function(a, b) sum((a - b)**2) / length(b)
# minmax
minmax = function(x) (x - min(x)) / (max(x) - min(x))
# return conditional mean of a polynomic DGP with data x, coef and degree
dgp = function(x, betas, degree) {
  mat = rep(list(x), degree+1) %>%
    map2(0:degree, function(x,y) x**y) %>%
    bind_cols() %>%
    as.matrix()
  return(mat%*%betas)
}

# make random data
make_data = function(seed, n_rows, degree, error_size) {
  set.seed(seed)
  x = runif(n_rows, -100, 100)
  betas = rep(BETAS_VALUE, degree+1)
  media = dgp(x, betas=betas, degree=degree)
  y = rnorm(n_rows, media, error_size*max(media))
  dat = data.frame(x=x, y=y)
  return(dat)
}

# train many models according to flexibility
train_models = function(dat, test_idx, complexity_vec) {
  models = complexity_vec %>%
    map(function(f) lm(y ~ poly(x,f), data=dat[-test_idx, ]))
  return(models)
}

# eval many fitted models according to flexibility
eval_models = function(models, dat, test_idx) {
  preds = models %>%
    map(function(m) predict(m, dat[test_idx,]))
  mses_train = models %>%
    map_dbl(function(m) mse(dat$y[-test_idx], m$fitted.values))
  mses_test = preds %>%
    map_dbl(function(p) mse(dat$y[test_idx], p))
  out = list(train=mses_train, test=mses_test)
  return(out)
}


dat = make_data(123, n_rows=200, degree=5, error_size=0.05)
mods = train_models(dat, 50:70, complexity_vec=1:20)


# plot performance by flexibility
plot_performance = function(models_results, complexity_vec) {
  gdat = data.frame(
    flexibility = complexity_vec
    ,mse_train = models_results$train
    ,mse_test = models_results$test
  ) %>%
    gather(metric, value, -flexibility) %>%
    mutate(value = minmax(value))
  g = ggplot(gdat, aes(x=flexibility, y=value, color=metric)) +
    geom_line(cex=1) +
    theme_minimal() +
    theme(legend.title=element_blank()) +
    labs(caption="Normalized with minmax", y=NULL
         ,x="Model flexibility") +
    NULL
  return(g)
}

# plot DGP and fitted curve
plot_data = function(dat, test_idx, models, degree_fitted, degree) {
  gdat = dat %>%
    slice(-test_idx) %>%
    mutate(fitted = models[[degree_fitted]]$fitted.values)
  betas = rep(BETAS_VALUE, degree+1)
  labels = c("DGP", glue("Fitted (deg.=",degree_fitted,")"))
  g = ggplot(gdat, aes(x=x)) +
    geom_point(aes(y=y), color="black", shape=21, alpha=0.5, cex=0.8) +
    stat_function(aes(color=labels[1]),fun=function(x) dgp(x, betas, degree), cex=1) +
    geom_line(aes(y=fitted, color=labels[2]), cex=1) +
    theme_minimal() +
    scale_color_manual(
      values = c("navy", "red") %>% setNames(labels)
    ) +
    theme(legend.title=element_blank()) +
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
      ,a("this post", href="XXX")
      ,", the size and shape of the bias-variance trade-off in any supervised problem is determined by:" 
      ,tags$ul(
        tags$li("the flexibility of the modelling method")
        ,tags$li("the complexity of the data generating process")
        ,tags$li("the irreducible variability of the target variable")
      )
    )
    ,hr()
    ,p(
      "In this example, we assume a polynomic data generating process (DGP) such that $y = f(X) + \\epsilon$ and $f(X) = \\beta_0 + \\beta_{1}x_1 + \\beta_{2}x_2 + ... + \\beta_{d}x_d + $. "
      ,"The degree $d$ of the polynomial defines the complexity of the DGP: "
      ,"the larger (smaller) it is, the more (less) complex it is. "
      ,"The irreducible error is given by $Var(\\epsilon)$ and its size is determined by XXX."
      ,"When the irreducible error is larger (smaller), the prediction error of the fitted model on test data is larger (smaller)."
    )
    ,p(
      "We assume we fit a polynomic function of $X$ in order to predict $y$."
      ,"The degree of the fitted polynomial defines the flexibility of the model: "
      ,"the larger (smaller) it is, the more (less) flexible it is."
    )
    ,p(
      "On the leftmost plot the MSE of all flexibilities 1 through 20 are plotted. "
      ,"On the rightmost plot only one fitted polynomial is shown, with degree as fixed in the XXX slider. "
    )
    ,p(
      "Data is generated at random each time any of the sliders’ values is modified, except for the value of the degree of the fitted polynomial."
    )
    )
}



