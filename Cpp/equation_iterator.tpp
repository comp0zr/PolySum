namespace polysum {
  #define SYSTEM_TYPE(CONST) typename CONST::System
  #define VALUE_TYPE(CONST)  typename CONST::Value

  template <typename CONST>
  EquationIterator<CONST>::EquationIterator(size_t h, size_t t, int d, SYSTEM_TYPE(CONST) s) :
     head(h),
     tail(t),
     index(d == 1 ? h : t),
     direction(d),
     system(s)
     {}

  template <typename CONST>
  EquationIterator<CONST>::EquationIterator(size_t h, size_t t, size_t i, int d, SYSTEM_TYPE(CONST) s) :
     head(h),
     tail(t),
     index(i),
     direction(d),
     system(s)
     {}

  template <typename CONST>
  EquationIteratorBuilder<CONST>::EquationIteratorBuilder(size_t h, size_t t, int d, SYSTEM_TYPE(CONST) s) :
     head(h),
     tail(t),
     direction(d),
     system(s)
     {}

  template<typename CONST>
  bool EquationIterator<CONST>::operator!=(const EquationIterator<CONST>& other) const {
    return (index != other.index);
  }

  template<typename CONST>
  EquationIterator<CONST> EquationIterator<CONST>::operator-(int offset) const {
    return *this + (-offset);
  }

  template<typename CONST>
  EquationIterator<CONST> EquationIterator<CONST>::operator++() {
    index += direction;
    return *this;
  }

  template <typename CONST>
  size_t EquationIterator<CONST>::begin() const {
    return direction == 1 ? head : tail;
  }

  template <typename CONST>
  size_t EquationIterator<CONST>::end() const {
    return direction == 1 ? tail : head;
  }

  template<typename CONST>
  EquationIterator<CONST> EquationIterator<CONST>::operator+(int offset) const {
    return EquationIterator<CONST>(head, tail, index+(offset*direction), direction, system);
  }

  template <typename CONST>
  EquationIterator<CONST> EquationIteratorBuilder<CONST>::begin() {
    return EquationIterator<CONST>(head, tail, direction, system);
  }

  template <typename CONST>
  EquationIterator<CONST> EquationIteratorBuilder<CONST>::end() {
    size_t end = direction == 1 ? tail + 1 : head - 1;
    return EquationIterator<CONST>(head, tail, end, direction, system);
  }

  template <typename CONST>
  EquationIterator<CONST> EquationIterator<CONST>::reverse() const {
    return EquationIterator<CONST>(head, tail, index, -direction, system);
  }
}

