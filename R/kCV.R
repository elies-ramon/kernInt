## K-fold cross- validation (classification)
#' @keywords internal
#' @importFrom kernlab ksvm cross
#' @importFrom stats na.omit

kCV.class <- function(COST, K, Yresp, k, R, prob, classimb) {

  # on Y és el vector resposta, i K.train la submatriu amb els individus de training
  min.error <- Inf

  for (c in COST) {

    outer.error <- vector(mode="numeric",length=R)
    for (o in 1:R) {
      unordered <- sample.int(nrow(K))
      Kmatrix <- K[unordered,unordered]
      Y <- Yresp[unordered]
      K.model <- ksvm(Kmatrix, Y, type="C-svc",kernel="matrix",prob.model=prob,class.weights=classimb,C=c,cross=k) # Rular el mètode
      outer.error[o] <- cross(K.model) # La mitjana dels errors és l'error de CV
    }
    v.error <- mean(outer.error)
    print(v.error)
    if (min.error > v.error) {
        min.error <- v.error
        best.cost <- c
      }
    }
  best.hyp <- data.frame(cost=best.cost,epsilon=NA,nu=NA, error= min.error)
  print(best.hyp)

  return(best.hyp)
}



## K-fold cross- validation (one-class SVM)
#' @keywords internal
#' @importFrom kernlab ksvm cross

kCV.one <- function(K, Yresp, NU, k=k, R=k) {
  min.error <- Inf
  for (nu in NU) {
    outer.error <- vector(mode="numeric",length=R)
    for (o in 1:R) {
      unordered <- sample.int(nrow(K))
      Kmatrix <- K[unordered,unordered]
      Y <- Yresp[unordered]
      K.model <- ksvm(Kmatrix, Y, type="one-svc", kernel="matrix",nu=nu,cross=k) # Rular el mètode
      outer.error[o] <- cross(K.model) # La mitjana dels errors és l'error de CV
    }
    v.error <- mean(outer.error)
    print(v.error)
    if (min.error > v.error) {   # < o <= ???
      min.error <- v.error
      best.h1 <- nu
    }
  }
  best.hyp <- data.frame(cost=NA,epsilon=NA,nu=best.h1, error= min.error)
  return(best.hyp)
}


## K-fold cross-validation (regression SVM)
#' @keywords internal
#' @importFrom kernlab ksvm cross

kCV.reg <- function(EPS, COST, K, Yresp, k, R) {
  min.error <- Inf
  for (e in EPS) {
    for (c in COST){
      outer.error <- vector(mode="numeric",length=R)
      for (o in 1:R) {
        unordered <- sample.int(nrow(K))
        Kmatrix <- K[unordered,unordered]
        Y <- Yresp[unordered]
        K.model <- ksvm(Kmatrix,Y,type="eps-svr",kernel="matrix",C=c,epsilon=e, cross=k) # Rular el mètode
        outer.error[o] <- cross(K.model) # La mitjana dels errors és l'error de CV
      }
      v.error <- mean(outer.error)
      print(v.error)
      if (min.error > v.error) {
        min.error <- v.error
        best.cost <- c
        best.e <- e
      }
    }
  }
  best.hyp <- data.frame(cost=best.cost,epsilon=best.e,nu=NA,error= min.error)
  return(best.hyp)
}


## Gamma hyperparameter - general kCV procedure if MKL is not being performed
#' @keywords internal
kCV.core <- function(H, kernel, method, K, ...) {
  min.error <- Inf
  if(is.null(H)) H <- 0
  for (h in H) {
    if(h==0) h <- NULL ## molt lleig això
    print(h)
    Kmatrix <- hyperkSelection(K=K,h=h,kernel=kernel)
    # Y <- Yresp
    if(method == "svc") {
      bh <- kCV.class(K=Kmatrix, ...) ## calls svm classification
    } else if(method == "svr") { ## smv calls regression
      bh <- kCV.reg(K=Kmatrix, ...)
    } else { ## calls one-class svm
      bh <- kCV.one(K=Kmatrix, ...)
    }
    if (min.error > bh$error) {
      best.h <- h
      best.cost <- bh$cost
      best.e <- bh$epsilon
      best.nu <- bh$nu
      min.error <- bh$error
    }
  }
  if(is.null(h)) {
    best.hyp <- data.frame(cost=best.cost,epsilon=best.e,nu=best.nu,error= min.error)
  } else{
    best.hyp <- data.frame(h=best.h,cost=best.cost,eps=best.e,nu=best.nu,error= min.error)
  }

  return(best.hyp)
}

#' @keywords internal
kernHelp <- function(x) {
  nhxh <- sapply(x,length) # Nombre d'hiperparàmetres per tipus de dada
  nulls <- which(nhxh==0)
  nhxh[nulls] <- 1
  x[nulls] <- 0
  return(list(hyp=unlist(x),number=nhxh))
}

## kCV procedure if MKL is being performed
#' @keywords internal
#' @importFrom methods is

kCV.MKL <- function(ARRAY, COEFF, KERNH, kernels, method, ...) {
  min.error <- Inf
  if(!is(COEFF,"matrix")) COEFF <- matrix(COEFF,ncol=length(COEFF),byrow=TRUE)
  d <- nrow(COEFF)
  d2 <- ncol(COEFF)

  if(is.null(KERNH))  KERNH <- rep(0,d2)

  hp <- kernHelp(KERNH)
  unliH <- hp$hyp
  nhxh<- hp$number
  nhyp <- sum(nhxh) # Nombre total d'hiperparàmetres
  chlp <- cumsum(nhxh)
  ARRAY2 <- array(0,dim=c(dim(ARRAY)[1],dim(ARRAY)[2],nhyp))
  for(k in 1:nhyp) {
    j <- as.numeric(which(k <= chlp)[1])
    ARRAY2[,,k] <- hyperkSelection(ARRAY[,,j],h=unliH[k],kernel=kernels[j])
  }
  code <- rep(1:d2, nhxh)
  indexes <- expand.grid(split(1:nhyp,code))

  for(i in 1:d) {
    for(k in 1:nrow(indexes)) {
      Kmatrix <- KInt(ARRAY2[,,as.numeric(indexes[k,])],coeff=COEFF[i,])
      if(method == "svc") {
        bh <- kCV.class(Kmatrix,...) ## calls svm classification
      } else if(method == "svr") { ## smv  regression
        bh <- kCV.reg(Kmatrix,...)
      } else { ## calls one-class svm
        bh <- kCV.one(Kmatrix,...)
      }
      if (min.error > bh$error) {
        ii <- indexes[k,]
        best.cost <- bh$cost
        best.e <- bh$epsilon
        best.nu <- bh$nu
        best.coeff <- COEFF[i,]
        min.error <- bh$error
      }
    }
  }
  best.h <- unliH[as.numeric(ii)]
  best.hyp <- list(coeff=best.coeff,h=best.h,cost=best.cost,eps=best.e,nu=best.nu,error= min.error)
  return(best.hyp)
}
