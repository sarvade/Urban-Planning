library(tidyverse)
library(sf)
library(spdep)
library(spatialreg)
library(spNNGP)
library(fastDummies)

#############################
## GET WEIGHTS
#############################

get_weights <- function(spatial) {
  rectangles_sf <- read_sf(config::get("rectangle_data")) %>%
    select(-Shape_Leng, -Shape_Area)

  rectangles_filtered <- rectangles_sf %>%
    inner_join(spatial, by = c("rectangle_" = "rectangle_id_250")) %>%
    select(geometry)

  spatial <- spatial %>%
    inner_join(rectangles_sf, by = c("rectangle_id_250" = "rectangle_"))

  neighbours <- poly2nb(rectangles_filtered)

  nb2listw(neighbours, style = "W", zero.policy = TRUE)
}

#############################
## OLS MODEL
#############################

spatial_ols <- function(data, formula) {
  lm(as.formula(formula),
    data = data
  )
}


#############################
## SPATIAL LAG
#############################

spatial_lag <- function(data, formula, weights) {
  lagsarlm(as.formula(formula),
    data = data,
    listw = weights
  )
}


#############################
## SPATIAL ERROR
#############################

spatial_error <- function(data, formula, weights) {
  errorsarlm(as.formula(formula),
    data = data,
    listw = weights
  )
}

#############################
## GAUSSIAN PROCESS
#############################

nngp <- function(data) {
  # Fit NNGP model
  af_t <- data$af_t
  coords <- data.matrix(data %>% select(x, y))
  X<-data.matrix(data %>% select(-rectangle_id_250, -x, -y, -af_t, -landcover_type_impervious_developed,-SN_rect))
  theta.alpha <- as.matrix(expand.grid(seq(0.01,1,length.out=15),seq(3,30,length.out=15)))
  colnames(theta.alpha) <- c("alpha", "phi")
  model_conjugate <- spConjNNGP(af_t ~ X,coords = coords,
                                cov.model = "exponential", sigma.sq.IG = c(2, 0.5*var(af_t)),
                                n.neighbors = 10, theta.alpha = theta.alpha,
                                k.fold = 2, score.rule = "crps", n.omp.threads = 12)
  return(model_conjugate)
  summary(model_conjugate)
}

#############################
## Predict mitigation outcome on target super neighborhood
#############################
mitigation_predict<-function(data,snb,type_decrease,type_increase,p,gp_model,lag_model,error_model,formula,weights){
  # Prepare data with mitigation strategy applied
  snb_idx<-which(data$SN_rect==snb)
  all_landcovers<-colnames(data)[grep(pattern="^landcover", x=colnames(data))]
  unchanged_landcovers<-all_landcovers[!all_landcovers%in%c(type_decrease,type_increase)]
  original<-data%>% filter(SN_rect==snb)
  other_land_sum<- rowSums(original[,unchanged_landcovers])
  mitigate<-original
  mitigate[,type_decrease]<-mitigate[,type_decrease]-p
  mitigate[,type_increase]<-mitigate[,type_increase]+p
  clip_idx<- which(mitigate[,type_decrease]<0)
  mitigate[clip_idx,type_decrease]<-0
  mitigate[clip_idx,type_increase]<-1-other_land_sum[clip_idx]
  # Average proportion of focused landcover type before and after mitigation
  show(colMeans(original[,type_increase]))
  show(colMeans(mitigate[,type_increase]))
  # Full data set after mitigation
  mitigate_full<-data
  mitigate_full[snb_idx,]<-mitigate
  # Predict temperature after mitigation with gaussian process model
  x.0 <- cbind(1,data.matrix(mitigate_full%>% select(-rectangle_id_250 ,-x, -y, -af_t, -landcover_type_impervious_developed,-SN_rect)))
  c.0 <- data.matrix(mitigate_full %>% select(x, y))
  predicted_conjugate <- predict(gp_model,
                                 X.0 = x.0, coords.0 = c.0,
                                 n.omp.threads = 12, n.report = 500)
  predicted_conjugate_temp <- predicted_conjugate$y.0.hat[snb_idx]
  # Predict tempertature after mitigation with spatial lag model
  lag_model$call$formula <- as.formula(formula)
  predicted_lag<-data.frame(predict.sarlm(lag_model, newdata = mitigate_full, listw = weights))
  # Predict tempertature after mitigation with spatial error model
  error_model$call$formula <- as.formula(formula)
  predicted_error<-data.frame(predict.sarlm(error_model, newdata = mitigate_full, listw = weights))
  
  
  
  output<-data.frame(rect_id = mitigate_full$rectangle_id_250[snb_idx],
                     X=c.0[snb_idx,1],Y=c.0[snb_idx,2],
                     temp_original = original$af_t,
                     temp_mitigated_GPR=predicted_conjugate_temp,
                     temp_mitigated_SLM=predicted_lag$fit[snb_idx],
                     temp_mitigated_SEM=predicted_error$fit[snb_idx])
  return(output)
  
  }


