###### VAR/SVAR 模型相關程式
rm(list=ls())
# 設定路徑
Path = "/Users/Andy 1/Google 雲端硬碟 (r08323004@g.ntu.edu.tw)/0 Semesters/Thesis/6_VAR_model/R"
setwd(Path)
source("code/VAR_functions.R")           # 讀取 VARsource.R 檔

inv_tol = 1e-20 #求反矩陣時做數值運算允許的最小誤差(避免singular matrix)

###### 讀取資料 ######
file = "data/df.csv"
data = read.csv(file = file, header = TRUE)
data = na.omit(data)
# 4-variable model
By <- data %>% select(interest_rate, permit, loan, hp) %>% as.matrix
# 5-variable model
By <- data %>% select(interest_rate, permit, loan, Sentiment, hp) %>% as.matrix



#----- 模型設定 -----#
VAR.P = 2                       # 最大的落後項數
CONST = TRUE                    # 是否有常數項
Y     = VAR.Y(By, VAR.P)        # 設定 Y
X     = VAR.X(By, VAR.P)        # 設定 X

###### Reduced Form #######

###### 參數估計 ######
(Coef.OLS    = VAR.OLS(Y, X, CONST)                  )
#(Coef.EbyE   = VAR.EbyE(ddY, ddX, CONST)             )
(Sigma.OLS   = VAR.Sigma.OLS(Y, X, Coef.OLS, CONST)  )
# (ddSigma.OLS = VAR.ddSigma.OLS(ddY, ddX, CONST)      )
Sigma.MLE   = VAR.Sigma.MLE(Y, X, Coef.OLS, CONST)
# (ddSigma.MLE = VAR.ddSigma.MLE(ddY, ddX, CONST)      )


#----- 資訊準則 -----#
A0.Mat = matrix(1, 3, 7)
(SIC = VAR.IC(Sigma.MLE, A0.Mat, T)$SIC              )

(IC = VAR.Select(By, Max.lag = 4, CONST)             )
apply(IC, 1, which.min)


###### SVAR 估計 ######
#----- A-Model 參數估算 -----#
Amat = diag(4)
# Identification Conditions

### 4-variable model
Amat[1,1]  = NA;
Amat[2,1]  = NA; Amat[2,2]  = NA;
Amat[3,1]  = NA; Amat[3,3]  = NA; Amat[3,4]  = NA;
Amat[4,1]  = NA; Amat[4,2]  = NA; Amat[4,3]  = NA; Amat[4,4]  = NA;

Bmat = diag(4)
diag(Bmat) = NA


### 5-variable model
Amat = diag(5)
Amat[1,1]  = NA;
Amat[2,1]  = NA; Amat[2,2]  = NA;
Amat[3,1]  = NA; Amat[3,3]  = NA; Amat[3,5]  = NA;
Amat[4,1]  = NA; Amat[4,2]  = NA; Amat[4,3]  = NA; Amat[4,4]  = NA;
Amat[5,1]  = NA; Amat[5,2]  = NA; Amat[5,3]  = NA; Amat[5,4]  = NA; Amat[5,5]  = NA;

Bmat = diag(5)
diag(Bmat) = NA

#solve(Amat)%*%Bmat

### Estimating A,B Matrix

# 更換起使值，得到不同的估計結果
# seed
SVAR_AB_est <- VAR.svarest.AB(By, VAR.P, Amat, Bmat, CONST, start = "uniform")
solve(SVAR_AB_est$A0.svar) %*% SVAR_AB_est$B0.svar

A0 <- SVAR_AB_est$A0.svar
B0 <- SVAR_AB_est$B0.svar

### 暴力嘗試，做很多很多次，每次如果沒有符合某種收斂條件就繼續找
seed_stored <- c()
i <- 0
while(TRUE){
  set.seed(i)
  SVAR_AB_est <- try(VAR.svarest.AB(By, VAR.P, Amat, Bmat, CONST, start = "uniform"), 
                     silent = TRUE)
  S <- try(solve(SVAR_AB_est$A0.svar) %*% SVAR_AB_est$B0.svar)
  if(max(S)<=1000 && min(S)>=-1000){
    seed_stored <- rbind(seed_stored, i)
    cat("Seed: ", i, " found\n")
  }
  i <- i+1
  if(length(seed_stored)>=1000){
    break
  }
  cat(i, "\n", seed_stored, "\n")
}
#46108
getwd()
write.csv(seed_stored, "seed_S_smaller_1000.csv")

pnorm(-2.51, lower.tail = F)
pnorm(-2.236)*2
# Check
seed_stored
#set.seed(47)
for(j in seed_stored){
  cat("seed: ", j, "\n")
  set.seed(j)
  SVAR_AB_est <- VAR.svarest.AB(By, VAR.P, Amat, Bmat, CONST, start = "normal")
  cat("A Matrix: \n")
  print(SVAR_AB_est$A0.svar)
  cat("B Matrix: \n")
  print(SVAR_AB_est$B0.svar)
  cat("S Matrix: \n")
  print(solve(SVAR_AB_est$A0.svar) %*% SVAR_AB_est$B0.svar)
}
set.seed(69)
SVAR_AB_est <- VAR.svarest.AB(By, VAR.P, Amat, Bmat, CONST, start = "normal")
solve(SVAR_AB_est$A0.svar) %*% SVAR_AB_est$B0.svar

# for(i in 1:10000){
#   set.seed(i)
#   SVAR_AB_est <- VAR.svarest.AB(By, VAR.P, Amat, Bmat, CONST, start = "uniform")
#   if(max(B0)<=1000){
#     seed_stored <- rbind(seed_stored, i)
#     cat("Seed: ", i, " found")
#     break
#   }
# }

### Jen-Ckuan
#var.bm <- VAR(benchmark, p=1)

#svar.bm <- svar.ab(estimation = var.bm, try = 10, Amat = A, Bmat = B)$svar_est




### IRF
SVAR_AB_IRF <- VAR.svarirf.AB(By, VAR.P, Amat, Bmat, h = 119, CONST, SVAR_AB_est = SVAR_AB_est)
#=function(Data, VAR.p = 2, AMat, BMat, h=10, Const = TRUE){


# # Plot
# class(unlist(SVAR_AB_IRF))
# IRF_y3_shock_1 <- c()
# for(period in SVAR_AB_IRF){
#   #print(period)
#   IRF_y3_shock_1 <- rbind(IRF_y3_shock_1, period[1,1])
# }
# plot(1:120, IRF_y3_shock_1, type = 'l')

# 5*5個圖的time series
df_IRF_plot <- matrix(NA, 120, 25) #%>% as.tibble()
#dim(df_IRF_plot)
h <- 0 # h表示第幾期的IRF
for(period in SVAR_AB_IRF){
  k <- 0 # k表示把5*5的矩陣攤平到25個col的df時，要攤到第幾個columns上
  h <- h+1 # h表示第幾期的IRF
  for(j in 1:5){
    for(i in 1:5){
      k <- k+1 # k表示把5*5的矩陣攤平到25個col的df時，要攤到第幾個columns上
      df_IRF_plot[h,k] <- period[i,j]
    }
  }
}
#df_IRF_plot %>% View
df_IRF_plot <- df_IRF_plot %>% as.tibble()

# 待補完
# graph <- ggplot(df_IRF_plot)
# for(col in colnames(df_IRF_plot)){
#   graph <- graph +
#     geom_line(aes(x = 1:nrow(df_IRF_plot), y = col, color = "impulse response"))
# }
# print(graph)


# ggplot(df_IRF_plot) + 
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V1, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V2, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V3, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V4, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V5, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V6, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V7, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V8, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V9, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V10, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V11, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V12, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V13, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V14, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V15, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V16, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V17, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V18, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V19, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V20, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V21, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V22, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V23, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V24, color = "impulse response"))+
#   geom_line(aes(x = 1:nrow(df_IRF_plot), y = V25, color = "impulse response"))+
#   facet_wrap(~.,ncol = 5)
#   #facet_grid()

p1 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V1))
p2 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V2))
p3 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V3))
p4 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V4))
p5 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V5))
p6 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V6))
p7 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V7))
p8 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V8))
p9 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V9))
p10 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V10))
p11 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V11))
p12 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V12))
p13 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V13))
p14 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V14))
p15 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V15))
p16 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V16))
p17 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V17))
p18 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V18))
p19 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V19))
p20 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V20))
p21 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V21))
p22 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V22))
p23 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V23))
p24 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V24))
p25 <- ggplot(df_IRF_plot) + geom_line(aes(x = 1:nrow(df_IRF_plot), y = V25))

multiplot(p1,p2,p3,p4,p5,
          p6,p7,p8,p9,p10,
          p11,p12,p13,p14,p15,
          p16,p17,p18,p19,p20,
          p21,p22,p23,p24,p25,
          cols = 5)

# For shock 1
multiplot(p1,p2,p3,p4,p5,
          cols = 2)
# For shock 2
multiplot(p6,p7,p8,p9,p10,
          cols = 2)
# For shock 3
multiplot(p11,p12,p13,p14,p15,
          cols = 2)
# For shock 4
multiplot(p16,p17,p18,p19,p20,
          cols = 2)
# For shock 5
multiplot(p21,p22,p23,p24,p25,
          cols = 2)

### Bootstrap C.I. for IRF


### Variance Decomposition

# `ddTheta` 放已經估出來的IRF (至於要放怎樣穩定的還要再想)
# m表示對於第幾個變數的變異數分解（如第五個是對房價的變異數分解）
SVAR_AB_VarDecomp <- VAR.svardecomp.AB(m = 5, By, VAR.P,
                                       AMat, BMat, h=119,
                                       Const=TRUE, ddTheta = SVAR_AB_IRF)
SVAR_AB_VarDecomp*100


### Historical Decomposition
SVAR_AB_HistDecomp <- VAR.svarhist.AB(By, VAR.P, Amat, Bmat, CONST)

#----- Base Project 估計 -----#
SVAR_AB_Hist.c0 = VAR.baseproject(By, VAR.P, CONST)
head(SVAR_AB_Hist.c0)


ggplot(SVAR_AB_Hist.c0 %>% as.tibble()) + 
  geom_line(aes(x = 1:nrow(SVAR_AB_Hist.c0), y = V1))

# ggplot(SVAR_AB_Hist.c0 %>% as.tibble()) + 
#   geom_line(aes(x = 1:nrow(SVAR_AB_Hist.c0), y = V1)) +
#   geom_line(aes(x = 1:nrow(SVAR_AB_Hist.c0), y = V2)) +
#   geom_line(aes(x = 1:nrow(SVAR_AB_Hist.c0), y = V3)) +
#   geom_line(aes(x = 1:nrow(SVAR_AB_Hist.c0), y = V4)) +
#   geom_line(aes(x = 1:nrow(SVAR_AB_Hist.c0), y = V5))