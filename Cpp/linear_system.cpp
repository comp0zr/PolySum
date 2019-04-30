#include <vector>
#include <gmpxx.h>
#include <stdlib.h>
#include <iomanip>
#include "polysum.h"
#include "equation_iterator.h"
#include "linear_system.h"

namespace polysum {
  using namespace system_const;

  Pivot::Pivot(size_t init) :
    row(init),
    value(init + 1)
    {}

  Pivot::Pivot(size_t r, mpq_class v) :
    row(r),
    value(v)
    {}

  Pivot Pivot::next() const {
    size_t row = this->row;
    return Pivot(row + 1, this->value * (row + 2));
  }

  Pivot Pivot::next_next() const {
    size_t row = this->row;
    return Pivot(row + 2, this->value * (row + 2) * (row + 3));
  }


  LinearSystem::LinearSystem(size_t size) :
    equations(size)
    {}


  size_t LinearSystem::size() const {
    return this->equations.size();
  }

  Equation& LinearSystem::operator[](size_t index) {
    return this->equations[index];
  }

  const Equation& LinearSystem::operator[](size_t index) const {
    return this->equations[index];
  }


  void LinearSystem::push_back(Equation eq) {
    this->equations.push_back(eq);
  }

  EquationIterator<Mut> LinearSystem::begin() {
    return EquationIterator<Mut>(0, size()-1, 0, 1, this);
  }

  EquationIterator<Const> LinearSystem::begin() const {
    return EquationIterator<Const>(0, size()-1, 0, 1, this);
  }

  EquationIterator<Mut> LinearSystem::end() {
    return EquationIterator<Mut>(0, size()-1, size(), 1, this);
  }

  EquationIterator<Const> LinearSystem::end() const {
    return EquationIterator<Const>(0, size()-1, size(), 1, this);
  }

  EquationIteratorBuilder<Mut> LinearSystem::bottom_to_top() {
    return EquationIteratorBuilder<Mut>(0, size()-1, -1, this);
  }

  EquationIteratorBuilder<Const> LinearSystem::bottom_to_top() const {
    return EquationIteratorBuilder<Const>(0, size()-1, -1, this);
  }

  EquationIteratorBuilder<Mut> LinearSystem::to_top(int index) {
    return EquationIteratorBuilder<Mut>(0, index, -1, this);
  }

   EquationIteratorBuilder<Const> LinearSystem::to_top(int index) const {
    return EquationIteratorBuilder<Const>(0, index, -1, this);
  }


  Equation::Equation(size_t r, mpq_row c, mpq_class i) :
    row(r),
    coefficients(c),
    independent(i)
    {}

  size_t Equation::index() const {
    return this->_index;
  }

  mpq_class Equation::pop_rightmost_coefficient() {
    mpq_class coeff = std::move(this->coefficients.back());
    this->coefficients.pop_back();
    return coeff;
  }

  const auto SET_ELEMENT_WIDTH = std::setw(8);
  const auto DELIMITER_PADDING = "    ";
  const auto LEFT_DELIMITER    = "||";
  const auto RIGHT_DELIMITER   = "||";
  const auto INDEPENDENT_VALUE_DELIMITER = "=";

  std::ostream& operator<<(std::ostream& stream, const Equation& eq) {
     for (auto coeff : eq.coefficients) {
       stream << SET_ELEMENT_WIDTH << coeff;
     }
     stream << DELIMITER_PADDING << INDEPENDENT_VALUE_DELIMITER;
     stream << DELIMITER_PADDING << SET_ELEMENT_WIDTH << eq.independent;
     return stream;
  }


  std::ostream& operator<<(std::ostream& stream, const LinearSystem& system) {
    for (auto equation : system) {
      stream << LEFT_DELIMITER << DELIMITER_PADDING;
      for (size_t j = 0; j < equation.index(); j++) {
        stream << SET_ELEMENT_WIDTH << "0";
      }
      stream << equation;
      stream << DELIMITER_PADDING << RIGHT_DELIMITER << "\n";
    }
    return stream;
  }
}
