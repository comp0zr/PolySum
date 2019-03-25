import System.Environment (getArgs)
import Math.Polynomial
import PolySum
import NamedPolynomial

main = do args <- getArgs
          case args of
            [n]       -> print (NamedPoly "x" (polysum (read n)))
            [n, k]    -> print (evalPoly (polysum (read n)) (read k))
            otherwise -> do value <- getLine
                            print (NamedPoly "x" (polysum (read value)))

