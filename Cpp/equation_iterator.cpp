#include "polysum.h"
#include "equation_iterator.h"
#include "linear_system.h"

namespace polysum {
  using namespace system_const;

  template <>
  Equation* EquationIterator<Mut>::operator*() {
    (*system)[index]._index = index;
    return &(*system)[index];
  }

  template <>
  Equation EquationIterator<Const>::operator*() {
    auto eq = (*system)[index];
    eq._index = index;
    return eq;
  }
}
