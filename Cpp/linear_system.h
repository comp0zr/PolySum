#pragma once
#include "polysum.h"

namespace polysum {
  namespace system_const {
    class Const;
    class Mut;
  }


  class LinearSystem {
    private:
      std::vector<Equation> equations;
    public:
      LinearSystem(size_t);

      size_t      size() const;
      mpq_class   pop_rightmost_coefficient(size_t);
      mpq_class&  independent(size_t);

      void push_back(Equation);
      Equation& operator[](size_t);
      const Equation& operator[](size_t) const;

      EquationIteratorBuilder<system_const::Mut>    bottom_to_top();
      EquationIteratorBuilder<system_const::Mut>    to_top(int);
      EquationIteratorBuilder<system_const::Const>  bottom_to_top() const;
      EquationIteratorBuilder<system_const::Const>  to_top(int) const;

      EquationIterator<system_const::Mut>    begin();
      EquationIterator<system_const::Mut>    end();
      EquationIterator<system_const::Const>  begin() const;
      EquationIterator<system_const::Const>  end() const;


      const mpq_column& get_independents() const;
      friend std::ostream& operator<<(std::ostream&, const LinearSystem&);
  };
  std::ostream& operator<<(std::ostream&, const LinearSystem&);

  class Equation {
    private:
      size_t _index;
    public:
      size_t row;
      mpq_row coefficients;
      mpq_class independent;

      Equation() {}
      Equation(size_t, mpq_row, mpq_class);
      mpq_class pop_rightmost_coefficient();
      size_t index() const;

      friend EquationIterator<system_const::Const>;
      friend EquationIterator<system_const::Mut>;
  };

  class Pivot {
    public:
      size_t row;
      mpq_class value;

      Pivot(size_t, mpq_class);
      Pivot(size_t);

      Pivot next() const;
      Pivot next_next() const;
  };
}
