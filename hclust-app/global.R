
library(tidyverse)
library(glue)
library(factoextra)
library(amap)
library(ggridges)
library(plotly)
library(shinythemes)

# inputs ------------------------------------------------------------------

VARIABLES = c("densidad","pib_capita" ,"uhc","exp_vida","porc_14","porc_65"
              ,"pob","porc_urban")
NORMALIZATIONS = c("mean-sd","min-max","median-iqr")
DISTANCES = c("euclidean", "manhattan", "pearson")
LINKAGES = c("ward.D2", "single", "complete", "average", "median", "centroid")

# data --------------------------------------------------------------------

dat = read_csv("data/worldbank.csv")

# functions ---------------------------------------------------------------

z_scale = function(x) (x - mean(x)) / sd(x)

minmax = function(x) (x - min(x)) / (max(x) - min(x))

rob_scale = function(x) (x - median(x)) / IQR(x)

select_vars = function(data, variables) {
  out = data %>% select(all_of(variables))
  return(out)
}

normalize_data = function(data, norm_type) {
  if (norm_type == "mean-sd") {
    out = data %>% mutate_all(z_scale)
  }
  if (norm_type == "min-max") {
    out = data %>% mutate_all(minmax)
  }
  if (norm_type == "median-iqr") {
    out = data %>% mutate_all(rob_scale)
  }
  return(out)
}

diss_matrix = function(data, distance_metric) {
  amap::Dist(data, method=distance_metric)
}

elbow_plot = function(data, diss_obj, distance_metric, linkage) {
  fviz_nbclust(data, FUNcluster=hcut, method="wss", k.max=20
               ,diss=diss_obj, hc_metric=distance_metric, hc_method=linkage) +
    labs(title=NULL)
}

gap_plot = function(data, diss_obj, distance_metric, linkage) {
  fviz_nbclust(data, FUNcluster=hcut, method="gap", k.max=20
               ,diss=diss_obj, hc_metric=distance_metric, hc_method=linkage
               ,nstart=50, nboot=30, print.summary=F) +
    labs(title=NULL)
}

avg_silhouette_plot = function(data, diss_obj, distance_metric, linkage) {
  fviz_nbclust(data, FUNcluster=hcut, method="silhouette", k.max=20
               ,diss=diss_obj, hc_metric=distance_metric, hc_method=linkage
               ,print.summary=F) +
    labs(title=NULL)
}

cophenetic_distances = function(diss) {
  out = LINKAGES %>% 
    map(function(x) hclust(diss, method=x)) %>% 
    setNames(LINKAGES) %>% 
    map_dfr(function(x) cor(diss, cophenetic(x))) 
  return(out)
}


hc_cut = function(data, k, distance_metric, linkage) {
  # no puedo usar el diss obj porque no puedo agregarle labels
  data = as.data.frame(data)
  rownames(data) = dat$country
  hc = hcut(data, k=k, hc_method=linkage, hc_metric=distance_metric, stand=F)
  return(hc)
}

hc_details = function(hc) {
  silinfo = hc$silinfo$widths
  out = bind_cols(country = rownames(silinfo), silinfo)
  # indicador de outlier
  outlier_countries = out %>% 
    group_by(cluster) %>% 
    filter(n() == 1) %>% 
    pull(country)
  out = out %>% 
    mutate(outlier = ifelse(country %in% outlier_countries, 1, 0))
  return(out)  
}

silhouette_plot = function(hc) {
  fviz_silhouette(hc, label=T, print.summary=F) +
    theme(axis.text.x=element_text(angle=-90, size=4))
}

cluster_boxplots = function(data, cluster_details) {
  gdat = bind_cols(country=dat$country, data) %>% 
    left_join(cluster_details, by="country") %>% 
    filter(outlier == 0) %>% 
    pivot_longer(-c(country, cluster), names_to="variable", values_to="value")
  ggplot(gdat, aes(x=variable, y=value, color=cluster)) +
    facet_wrap(~cluster, ncol=2) +
    geom_boxplot() +
    theme_minimal() +
    theme(axis.text.x=element_text(angle=-90)) +
    NULL
}

cluster_densities = function(data, cluster_details) {
  gdat = bind_cols(country=dat$country, data) %>% 
    left_join(cluster_details, by="country") %>% 
    filter(outlier == 0) %>% 
    pivot_longer(-c(country, cluster), names_to="variable", values_to="value") %>% 
    filter(variable %in% VARIABLES)
  ggplot(gdat, aes(x=value, y=variable, color=cluster, point_color=cluster
                   , fill=cluster)) +
    geom_density_ridges(
      alpha=0.5, scale=1
      ,jittered_points=T, position=position_points_jitter(height=0)
      ,point_shape="|", point_size=2
    ) +
    # theme_minimal() +
    NULL
}




# AGREGAR HEATMAP
