{-|
The goal of this module is to find a polynomial \(Q\) such that \(Q(x) = \sum_{i=1}^{x} i^n\)

To do that, we must first create a \((n+1) \times (n+2)\) matrix \(A\), which we will
also call the base matrix of \(n\). This base matrix must adhere to the following rules:

  * if \(j < i\),   \(A[i,j]\) = \(0\)
  * if \(j = n+1\), \(A[i,j]\) = \((n)_i\)
  * otherwise,      \(A[i,j]\) = \((j+1)_i\)

Where \((k)_p = \frac{n!}{(n - p)!}\)
It will look like this:

\[
 \left(
 \begin{array}{c c c c c c c}
  (1)_0 &  (2)_0 &  (3)_0 & \cdots & (n)_0     & (n+1)_0     & (n)_0     \\
    0   &  (2)_1 &  (3)_1 & \cdots & (n)_1     & (n+1)_1     & (n)_1     \\
    0   &    0   &  (3)_2 & \cdots & (n)_2     & (n+1)_2     & (n)_2     \\
    0   &    0   &    0   & \cdots & (n)_3     & (n+1)_3     & (n)_3     \\
 \vdots & \vdots & \vdots & \ddots & \vdots    & \vdots      & \vdots    \\
    0   &    0   &    0   & \cdots & (n)_{n-2} & (n+1)_{n-2} & (n)_{n-2} \\
    0   &    0   &    0   & \cdots & (n)_{n-1} & (n+1)_{n-1} & (n)_{n-1} \\
    0   &    0   &    0   & \cdots &    0      & (n+1)_n     & (n)_n     \\
  \end{array}
  \right)
\]

The last column of the reduced row echelon form of \(A\) will be the coefficients of \(Q\).

Although we could just create \(A\) and get away with it, we can ignore certain elements
of the matrix to speed up computation and reduce memory usage. What we can ignore is
determined by the following rules:

 * for all \(j < i\), there is no need to store \(A[i,j]\), because it will always be 0.
 * the \(k\)th last row can be ignored if \(k\) is even and greater than 2.
 * the \(k\)th last column can be ignored if \(k\) is even and greater than 2. (same as above but columns)

It's of note that the last \((n + 1)\)th row/column is the first row/column, therefore, if \(n\) is odd and greater
than 2, we will start from the second row/column.

We can also change the last two rows of the matrix to be the following without changing
the reduced row echelon form:

 * \(A[n+1,n]   = \frac{1}{n+1}\)
 * \(A[n+1,n-1] = 1\)
 * \(A[n,n]     = \frac{1}{2}\)
 * \(A[n,n-1]   = 1\)
 * all other elements are zero.

The matrix should look like this by now:

 * if \(n\) is even and greater than 2:

 \[
 \left(
 \begin{array}{c c c c c c}
  (1)_0 &  (3)_0 & \cdots & (n)_0  & (n+1)_0     & (n)_0         \\
    0   &  (3)_2 & \cdots & (n)_2  & (n+1)_2     & (n)_2         \\
 \vdots & \vdots & \ddots & \vdots & \vdots      & \vdots        \\
    0   &    0   & \cdots &    0   & (n+1)_{n-2} & (n)_{n-2}     \\
    0   &    0   & \cdots &    1   &   0         & \frac{1}{2}   \\
    0   &    0   & \cdots &    0   &   1         & \frac{1}{n+1} \\
  \end{array}
  \right)
 \]

 * if \(n\) is odd and greater than 2:

 \[
 \left(
 \begin{array}{c c c c c c}
  (2)_1 &  (4)_1 & \cdots & (n)_1  & (n+1)_1     & (n)_1         \\
    0   &  (4)_3 & \cdots & (n)_3  & (n+1)_3     & (n)_3         \\
 \vdots & \vdots & \ddots & \vdots & \vdots      & \vdots        \\
    0   &    0   & \cdots &    0   & (n+1)_{n-2} & (n)_{n-2}     \\
    0   &    0   & \cdots &    1   &   0         & \frac{1}{2}   \\
    0   &    0   & \cdots &    0   &   1         & \frac{1}{n+1} \\
  \end{array}
  \right)
 \]


Next, we notice that the element \(A[k,k] = (k+1)_k = \frac{(k+1)!}{(k+1-k)!} = \frac{(k+1)!}{1!} = (k+1)!\).
It's also the first non-zero element of the row, and because, for \(j > k\)

 \[
 \begin{align*}
 A[k,j] &= \frac{(j+1)!}{(j+1-k)!}\\
        &= \frac{j! \cdot (j+1)}{(j-k)! \cdot (j+1-k)}\\
        &= \frac{j!}{(j-k)!} \cdot \frac{j+1}{j+1-k}\\
        &= A[k,j-1] \cdot \frac{j+1}{j+1-k}
 \end{align*}
 \]

We can then calculate each element in the row from the previous one,
thus roughtly turning \(k\) factorials into \(k\) multiplications. We also don't
need to calculate a factorial for \(A[k,k]\) at each row, since

 \[
 \begin{align*}
  A[k,k] &= (k+1)!\\
         &= k! \cdot (k+1)\\
         &= A[k-1,k-1] \cdot (k+1)
 \end{align*}
 \]

Therefore we only need to calculate \((n+1)!\). When calculating the kth row, we will call the
variable storing the value of \(A[k, k]\) to be passed along the @diagonal@, because it will
be used to generate the matrix's diagonal. The initial value of @diagonal@ will be one of two:

* if \(n\) is odd,  @diagonal@ = \(2!\) = \(2\)
* if \(n\) is even, @diagonal@ = \(1!\) = \(1\)

This is because if \(n\) is odd, we will either start our work at row 2 or not do any work at all
(so the value doesn't matter and may as well be 2), and if n is even, we will start out work
at row 1.

So now we know all we need to make this matrix. Skip first row if \(n\) is even and greater than 2,
skip every other one but make sure to include the last three, calculate the first diagonal and keep
passing it along (remember to make up for the skipped rows!!) and use it to calculate the other elements
of the row (again, make up for the skipped columns), stop after the 3th last row because the last two are
constants, append them, and voila, simple simple.

Note that because this matrix is sparse, we will represent its rows as the a list where the \(k\)th
element is the \(k\)th last element of the matrix. e.g. the row

> 0 0 0 0 0 0 0 1 0 3

will be represented as the list

> [3, 0, 1]

if the row is the \(k\)th last one, then the size of the list is than \(k + 1\),
e.g. the above list is from the 2nd last row.
-}
module PolySum
( polysum
, sumCoefficients
)
where

import Data.Ratio
import Math.Polynomial
import NamedPolynomial
import Control.Parallel
import Control.Parallel.Strategies
import Debug.Trace

-- |The map function used for rows
-- Used to test parallelism
mapRow :: (NFData b) => (a -> b) -> [a] -> [b]
mapRow func list = map func list
--mapRow func list = let nonpar = map func list
--                   in  nonpar `using` parList rdeepseq

-- |The last row of the base matrix of n
lastRow :: Integer -> [Rational]
lastRow n = [1%(n + 1), 1]

-- |The 2nd last row of the base matrix of n
secondLastRow :: Integer -> [Rational]
secondLastRow n = [1%2, 0, 1]

-- |Which row we will start building the matrix at
firstRow :: Int -> Integer
firstRow 1 = 2 -- No work to be done
firstRow n = if odd n then 2 else 1


-- |The value of A[k,k] where k is (firstRow n)
initialDiagonal :: Int -> Rational
initialDiagonal n = if odd n then 2 else 1

-- |Diagonal of the base matrix of n
diagonal :: Int -> [(Integer, Rational)]
diagonal n = diagonal' (toInteger n) (firstRow n) (initialDiagonal n) []

diagonal' :: Integer -> Integer -> Rational -> [(Integer, Rational)] -> [(Integer, Rational)]
diagonal' n i value result =
  if i >= n + 1
  then result
  else diagonal' n (i + 2) value' ((i,value):result)
       where value' = value * (((i + 1) * (i + 2)) % 1)


-- |Will build a matrix A such that the last column of its row echelon
-- form will contain the coefficients of the polynomial sum of x^n. The
-- result R is a sparse representation of A, where @((R !! i) !! j)@
-- will be jth last element of the ith last row of the actual matrix.
createMatrix :: Int -> [[Rational]]
createMatrix n = createMatrix' (toInteger n) (diagonal n)

createMatrix' :: Integer -> [(Integer, Rational)] -> [[Rational]]
createMatrix' n diag = let matrix = mapRow (createRow n) diag
                       in (lastRow n):((secondLastRow n):matrix)


createRow :: Integer -> (Integer, Rational) -> [Rational]
createRow n (1, init) = take ((fromIntegral n) + 2) (repeat 1)
createRow n (i, init) = createRow' n i i init [init]

createRow' :: Integer -> Integer -> Integer -> Rational -> [Rational] -> [Rational]
createRow' n i j value row =
  if j >= n + 1
  then if i /= n + 1
       then let (v':(v'':rest)) = row
            in  (v'':row)
       else row
  else let value'  = (value  * ((j+1) % ((j+1) - (i - 1))))
           value'' = (value' * ((j+2) % ((j+2) - (i - 1))))
           row'    = (value':row)
           row''   = (value'':row)
       in if j >= n - 1
          then createRow' n i (j + 1) value'  row'
          else createRow' n i (j + 2) value'' row''


-- |The last column of the reduced row echelon form
-- of the given sparse matrix.
independents :: [[Rational]] -> [Rational]
independents matrix = independents' matrix []

independents' :: [[Rational]] -> [Rational] -> [Rational]
independents' [(i:(p:_))] result = (i / p):result
independents' (head:rest) result =
  let [independent, pivot] = head
      independent'         = independent / pivot
      rest'                = mapRow (subtractPivot independent') rest
  in independents' rest' (independent':result)



subtractPivot :: Rational -> [Rational] -> [Rational]
subtractPivot p row =
  (independent':(pivot:rest))
  where (independent:(prev:(pivot:rest))) = row
        independent' = independent - (p * prev)


-- |Let \(Q\) be a polynomial such that \(Q(x) = \sum_{i=1}^{x} i^n\)
--
-- Then @((sumCoefficients n) !! i)@ will be the coefficient that multiplies
-- the term \(x^{i+1}\) in \(Q(x)\).
sumCoefficients :: Int -> [Rational]
sumCoefficients n = sumCoefficients' inds init
                    where
                      inds = independents (createMatrix n)
                      init = if (n == 1) || (even n) then [] else [0]

sumCoefficients' :: [Rational] -> [Rational] -> [Rational]
sumCoefficients' [a,b,c] result = reverse (c:(b:(a:result)))
sumCoefficients' [a,b]   result = reverse (b:(a:result))
sumCoefficients' (a:b)   result = sumCoefficients' b (0:(a:result))


-- |A polynomial \(Q\) such that \(Q(x) = \sum_{i=1}^{x} i^n\)
polysum :: Int -> Poly Rational
polysum n = poly LE (0:(sumCoefficients n))

