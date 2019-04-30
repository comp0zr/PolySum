#pragma once

namespace polysum {
  class LinearSystem; //
  class Equation;     // equations.h

  namespace system_const {
    class Const {
      public:
         typedef const LinearSystem* System;
         typedef Equation Value;
    };

    class Mut {
      public:
         typedef LinearSystem* System;
         typedef Equation*     Value;
    };
  }

  template <typename CONST>
  class EquationIteratorBuilder {
    private:
      typedef typename CONST::System system_type;

      size_t head;
      size_t tail;
      int direction;
      system_type system;
    public:
      EquationIteratorBuilder(size_t, size_t, int, system_type);
      EquationIterator<CONST> begin();
      EquationIterator<CONST> end();
  };

  template <typename CONST>
  class EquationIterator {
    private:
      typedef typename CONST::System system_type;

      size_t head;
      size_t tail;
      size_t index;
      int direction;
      system_type system;

    public:
      typedef typename CONST::Value            value_type;
      typedef typename CONST::Value&           reference;
      typedef typename CONST::Value*           pointer;
      typedef signed long                      difference_type;
      typedef std::bidirectional_iterator_tag  iterator_category;

      EquationIterator(size_t, size_t, int, system_type);
      EquationIterator(size_t, size_t, size_t, int, system_type);

      bool operator!=(const EquationIterator<CONST>& other) const;
      EquationIterator operator+(int) const;
      EquationIterator operator-(int) const;
      EquationIterator operator++();
      size_t begin() const;
      size_t end() const;
      EquationIterator reverse() const;

      value_type operator*();
  };
}

#include "equation_iterator.tpp"

