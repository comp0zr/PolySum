#pragma once
#include <vector>
#include <gmpxx.h>
#include <cstdint>
#include <iostream>
#include <iterator>

namespace polysum {
  class LinearSystem;            //
  class Equation;                //
  class Pivot;                   // linear_system.h

  template <typename CONST>      //
  class EquationIterator;        //
                                 // equation_iterator.h
  template <typename CONST>      //
  class EquationIteratorBuilder; //

  class Polynomial;              //
  class CoefficientIterator;     // polynomial.h

  typedef std::vector<mpq_class> mpq_row;
  typedef std::vector<mpq_class> mpq_column;
  typedef std::vector<mpq_row>   mpq_matrix;
  typedef std::vector<Pivot>     Diagonal;

  Diagonal diagonal(size_t);
  LinearSystem make_system(size_t);

  void reduced_row_echelon(mpq_matrix&);
  mpq_column sum_coefficients(size_t);
  Polynomial polysum(Polynomial&);
  Polynomial polysum(size_t);
  Polynomial polysum(std::string, size_t);
}

