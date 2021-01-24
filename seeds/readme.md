# Seeds分類

* 以4變數`v4`及5個變數`v5`分類
* 以認定條件的區別分類



### 4-variable

1. `v4_identification1`

   1. 變數（按順序）：interest_rate, permit, loan, hp

   2. 認定條件：

      ```R
      Amat = diag(4)
      # Identification Conditions
      
      Amat[2,1]  = NA; 
      Amat[3,1]  = NA; Amat[3,4]  = NA;
      Amat[4,1]  = NA; Amat[4,2]  = NA; Amat[4,3]  = NA;
      
      Bmat = diag(4)
      diag(Bmat) = NA
      ```

      

### 5-variable

1. `v5_identification1`

   1. 變數（按順序）：interest_rate, permit, loan, Sentiment, hp

   2. 認定條件：

      ```R
      Amat = diag(5)
      Amat[2,1]  = NA;
      Amat[3,1]  = NA; Amat[3,5]  = NA;
      Amat[4,1]  = NA; Amat[4,2]  = NA; Amat[4,3]  = NA;
      Amat[5,1]  = NA; Amat[5,2]  = NA; Amat[5,3]  = NA; Amat[5,4]  = NA;
      
      Bmat = diag(5)
      diag(Bmat) = NA
      ```

   3. 初始值從：uniform(-10,10)出發

   4. 是否有找到好的seed：`seed:459250` 讓 `max(A0.Std)=17.77`, `max(B0.Std)=29.29`

   5. 

2. `v5_identification2`

   1. 變數（按順序）：interest_rate, Sentiment, permit, loan, hp

   2. 認定條件：

      ```R
      Amat = diag(5)
      Amat[2,1]  = NA;
      Amat[3,1]  = NA; Amat[3,2]  = NA;
      Amat[4,1]  = NA; Amat[4,2]  = NA; Amat[4,5]  = NA;
      Amat[5,1]  = NA; Amat[5,2]  = NA; Amat[5,3]  = NA; Amat[5,4]  = NA;
      
      Bmat = diag(5)
      diag(Bmat) = NA
      
      ```

   3. 初始值從：uniform(-10,10)出發

   4. 是否有找到夠好的seed

3. 