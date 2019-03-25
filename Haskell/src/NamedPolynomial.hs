module NamedPolynomial (NamedPoly (NamedPoly))
where

import ReduceTerms

import Data.Ratio
import Math.Polynomial

data NamedPoly = NamedPoly String (Poly Rational)

showCoeff :: Rational -> String
showCoeff coeff
  | coeff == (1%1)           = ""
  | (denominator coeff) == 1 = show (numerator coeff)
  | otherwise                = "(" ++ (show coeff) ++ ")"

showTerm' :: String -> Rational -> Int -> String
showTerm' name coeff 1   = (showCoeff coeff) ++ name
showTerm' name coeff exp = (showCoeff coeff) ++ name ++ "^" ++ (show exp)

showTerm :: String -> Bool -> Term -> String
showTerm name True (Term exp coeff)
  | coeff < 0 = "-" ++ (showTerm' name (abs coeff) exp)
  | coeff > 0 =        (showTerm' name (abs coeff) exp)
showTerm name False (Term exp coeff)
  | coeff < 0 = " - " ++ (showTerm' name (abs coeff) exp)
  | coeff > 0 = " + " ++ (showTerm' name (abs coeff) exp)




showPolynomial :: String -> Poly Rational -> String
showPolynomial name poly = let terms' = reverse (terms poly)
                               first  = showTerm name True (head terms')
                               rest   = map (showTerm name False) (drop 1 terms')
                           in concat (first:rest)

instance (Show NamedPoly) where
  show (NamedPoly name poly)  = showPolynomial name poly

