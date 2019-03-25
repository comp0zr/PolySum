module ReduceTerms (Term (Term), reduceTerms, terms)
where

import Data.Ratio
import Math.Polynomial

data Term = Term Int Rational

reduceTerms :: Poly Rational -> (Term -> a -> a) -> a -> a
reduceTerms poly func init = reduceTerms' (polyCoeffs LE poly) func init 0

reduceTerms' :: [Rational] -> (Term -> a -> a) -> a -> Int -> a
reduceTerms' []    func value exp = value
reduceTerms' (0:b) func value exp = reduceTerms' b func value (exp + 1)
reduceTerms' (a:b) func value exp = reduceTerms' b func (func (Term exp a) value) (exp + 1)

terms :: Poly Rational -> [Term]
terms poly = reduceTerms poly (:) []

