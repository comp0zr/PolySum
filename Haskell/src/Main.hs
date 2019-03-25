import System.Environment (getArgs)
import Data.Ratio
import Math.Polynomial
import PolySum
import NamedPolynomial

evalPolysum :: Int -> Integer -> Integer
evalPolysum n k = numerator (evalPoly (polysum n) (k % 1))

main = do args <- getArgs
          case args of
            [n]       -> print (NamedPoly "x" (polysum (read n)))
            [n, k]    -> print (evalPolysum (read n) (read k))
            otherwise -> do value <- getLine
                            print (NamedPoly "x" (polysum (read value)))

