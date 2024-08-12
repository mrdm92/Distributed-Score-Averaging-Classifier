#x is features and must be categorical
#y is label and must be binary
game <- function(x,y)
{
  Yname <- 'lbl'
  x <- as.data.frame(x)
  m <- ncol(x)
  n <- nrow(x)
  
  est <- function(var){
    tab <- table(y, var)
  }
  
  apriori <- table(y)
  tables <- lapply(x, est)
  
  for (i in 1:length(tables)) names(dimnames(tables[[i]])) <- c(Yname,
                                                                colnames(x)[i])
  names(dimnames(apriori)) <- Yname
  structure(list(apriori = apriori, tables = tables, levels = if (is.logical(y)) c(FALSE,
                                                                                   TRUE) else levels(y)), class = 'footbal')
}

#best : win_prob, goals_for , goal_avg
#newData dosnt have label
game.predict <- function(object, newdata, type = c('win_prob','goals_for','goal_avg'), threshold = 0.001,
                            eps = 0, ...)
{
  
  type    <- match.arg(type)
  newdata <- as.data.frame(newdata)
  attribs <- match(names(object$tables), names(newdata))
  isnumeric <- sapply(newdata, is.numeric)
  islogical <- sapply(newdata, is.logical)
  newdata <- as.matrix(newdata)
  l <- 2 #number of labels
  m <- length(object$tables) # number of features
  s <- matrix(rep(0,18),nrow = l)
  colnames(s) <- c('pld',#played
                   'w',#won
                   'wp',#win probability
                   'd',#drawn
                   'l',#lost
                   'gf',#goals for
                   'ga',#goals against
                   'gavg',#goal average= gf/ga
                   'pts')#points
  rownames(s) <- names(object$apriori)
  
  pred <- matrix(rep(0,l*nrow(newdata)),ncol = l)
  colnames(pred) <- names(object$apriori)
  
  for (i in 1:nrow(newdata)) {
    ndata <- newdata[i,]
    s[] <- 0
    s[,'pld'] <- m
    for (j in 1:m) {
      
      aj <- ndata[j]
      
      if(aj %in% colnames(object$tables[[j]]))
      {
        aj.count <- object$tables[[j]][,aj]#number of records of each label from train that value of
        #of their feature jth is equal to aj
      }
      else
        next
      
      
      s[,'gf'] <- s[,'gf']+aj.count
      s[,'wp'] <- s[,'wp'] + aj.count/sum(aj.count)
      if(aj.count[1]==aj.count[2])
        s[,'d'] <- s[,'d'] + 1
      else if(aj.count[1]>aj.count[2])
        s[1,'w'] <- s[1,'w'] +1
      else # if(aj.count[1]<aj.count[2])
        s[2,'w'] <- s[2,'w'] + 1
      
    }
    s[,'l']    <- s[,'pld'] - (s[,'w']+s[,'d'])
    s[1,'ga']  <- s[2,'gf']
    s[2,'ga']  <- s[1,'gf']
    s[,'gavg'] <- s[,'gf'] / s[,'ga']
    s[,'pts']  <- 3*s[,'w'] + s[,'d']
    
    switch(type, 
           goals_for={
             pred[i,] <- s[,'gf']/sum(s[,'gf'])
           },
           win_prob={
             pred[i,] <- s[,'wp']/sum(s[,'wp'])
           },
           goal_avg={
             pred[i,] <- s[,'gavg']/sum(s[,'gavg'])
             
           },
           {
             print('type must be one of this: goal_count, game_time1,game_time2,points,goal_avg')
           }
    )
    
  }
  
  return(pred)
  
}

#x is features and must be categorical
#y is label and must be binary
game4wp <- function(x,y)
{
  x <- as.data.frame(x)
  
  est <- function(var){
    tab <- table(y, var)
  }
  
  apriori <- table(y)
  tables <- lapply(x, est)
  
  for (i in 1:length(tables)) names(dimnames(tables[[i]])) <- c('lbl',
                                                                colnames(x)[i])
  names(dimnames(apriori)) <- 'lbl'
  structure(list(apriori = apriori, tables = tables, levels = if (is.logical(y)) c(FALSE,
                                                                                   TRUE) else levels(y)), class = 'footbal')
}

#best : win_prob, goals_for , goal_avg
#newData dosnt have label
game4wp.predict <- function(object, newdata , w)
{
  
  newdata <- as.data.frame(newdata)
  newdata <- as.matrix(newdata)
  m <- length(object$tables) # number of features
  s <- c(0,0)
  names(s) <- names(object$apriori)
  
  pred <- matrix(rep(0,2*nrow(newdata)),ncol = 2)
  colnames(pred) <- names(object$apriori)
  
  pred <- apply(newdata, 1, function(ndata){
    s[] <- 0
    for (j in 1:m) {
      
      
      aj.count <- object$tables[[j]][,ndata[j]]#number of records of each label from train that value of
      #of their feature jth is equal to aj
      
      s <- s + w[j]*aj.count/sum(aj.count)
    }
    s
  })
  
  return(t(pred))
  
}

