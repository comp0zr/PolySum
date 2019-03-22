Função Crie-Matriz(n: Inteiro) -> Matriz de Inteiros
  A := Nova Matriz (n + 1) x (n + 2) de Inteiros
  Preencha A com 0s
  Preencha a primeira linha de A com 1s

  Para i de 2 até n + 1
    Para j de i até n + 1
      A[i, j] := A[i-1, j] * (j - i + 2)
    Fim
    A[i, n+2] := A[i, n]
  Fim
  A[n+1, n+2] := A[n, n+2]
Fim
