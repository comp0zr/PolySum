module PolySum
( polysum
, sumCoefficients
)
where

import Data.Ratio
import Debug.Trace (trace)
import Math.Polynomial
import NamedPolynomial

createMatrix :: Int -> [[Rational]]
createMatrix n = createMatrix' n' i diag matrix
                 where
                   n'     = toInteger n
                   i      = if n == 1
                            then 2
                            else toInteger ((mod (n + 1) 2) + 2)
                   diag   = if i == 2
                            then (2%1)
                            else (6%1)
                   matrix = if ((mod n 2) == 1)
                            then []
                            else [take (n + 2) (repeat (1%1))]

createMatrix' :: Integer -> Integer -> Rational -> [[Rational]] -> [[Rational]]
createMatrix' n i diag matrix =
  if i >= n + 1
  then [1%(n + 1), 1%1]:([1%2, 0%1, 1%1]:matrix)
  else let row     = createRow n i (i+1) diag [diag]
           diag'   = (diag  * (((i + 1) * (i + 2)) % 1))
           matrix' = (row:matrix)
       in createMatrix' n (i + 2) diag' matrix'


createRow :: Integer -> Integer -> Integer -> Rational -> [Rational] -> [Rational]
createRow n i j value row =
  if j >= n + 2
  then if i /= n + 1
       then let (v':(v'':rest)) = row
            in (v'':row)
       else row
  else let value'  = (value  * (j % (j - (i - 1))))
           value'' = (value' * ((j+1) % ((j+1) - (i - 1))))
           row'    = (value':row)
           row''   = (value'':row)
       in if j >= n - 1
          then createRow n i (j + 1) value'  row'
          else createRow n i (j + 2) value'' row''


independents :: [[Rational]] -> [Rational]
independents matrix = independents' matrix []

independents' :: [[Rational]] -> [Rational] -> [Rational]
independents' [(i:(p:_))] result = (i / p):result
independents' (head:rest) result =
  let [independent, pivot] = head
      independent'         = independent / pivot
      rest'                = subtractPivot independent' rest []
  in independents' rest' (independent':result)


subtractPivot :: Rational -> [[Rational]] -> [[Rational]] -> [[Rational]]
subtractPivot p [] result  = reverse result
subtractPivot p (head:rest) result =
  let (hIndependent:(hPrev:(hPivot:hRest))) = head
      hIndependent' = hIndependent - (p * hPrev)
      head'         = (hIndependent':(hPivot:hRest))
  in subtractPivot p rest (head':result)


sumCoefficients :: Int -> [Rational]
sumCoefficients n = sumCoefficients' inds init
                    where
                      inds = independents (createMatrix n)
                      init = if (n == 1) || (even n) then [] else [0]

sumCoefficients' :: [Rational] -> [Rational] -> [Rational]
sumCoefficients' [a,b,c] result = reverse (c:(b:(a:result)))
sumCoefficients' [a,b]   result = reverse (b:(a:result))
sumCoefficients' (a:b)   result = sumCoefficients' b (0:(a:result))


polysum :: Int -> Poly Rational
polysum n = poly LE (0:(sumCoefficients n))

