Function Create-Matrix(n: Integer) -> Matrix of Integers
  A := New (n + 1) x (n + 2) Matrix of Integers
  Fill A with 0s
  Fill first row of A with 1s

  For i from 2 to n + 1
    For j from i to n + 1
      A[i, j] := A[i-1, j] * (j - i + 2)
    End
    A[i, n+2] := A[i, n]
  End
  A[n+1, n+2] := A[n, n+2]
End
