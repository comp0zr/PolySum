use crate::polynomials::*;

use rug::Rational;
use std::iter::Iterator;
use std::mem::transmute;

pub trait IntoPolynomial {
  fn into_polynomial<T: ToString>(self, var: T) -> Polynomial;
}

pub struct ConstantIterator<'a> {
  polynomial: &'a Polynomial,
  index: usize
}

pub struct ConstantIteratorMut<'a> {
  polynomial: &'a mut Polynomial,
  index: usize
}

impl<'a> ConstantIterator<'a> {
  pub fn new(polynomial: &'a Polynomial) -> Self {
    Self {
      polynomial,
      index: 0
    }
  }
}

impl<'a> ConstantIteratorMut<'a> {
  pub fn new(polynomial: &'a mut Polynomial) -> Self {
    Self {
      polynomial,
      index: 0
    }
  }
}

impl<'a> Iterator for ConstantIterator<'a> {
  type Item = &'a Rational;

  fn next(&mut self) -> Option<Self::Item> {
    if self.index < self.polynomial.len() {
      self.index += 1;
      Some(self.polynomial.constant(self.index-1))

    } else {
      None
    }
  }
}

impl<'a> Iterator for ConstantIteratorMut<'a> {
  type Item = &'a mut Rational;

  fn next(&mut self) -> Option<Self::Item> {
    if self.index < self.polynomial.len() {
      self.index += 1;
      let item = self.polynomial.constant_mut(self.index-1);
      unsafe {
        Some(transmute(item))
      }
    } else {
      None
    }
  }
}

impl<'a, I: Iterator<Item=Rational>> IntoPolynomial for I {
  fn into_polynomial<T: ToString>(self, var: T) -> Polynomial {
    let constants = self.collect();
    Polynomial::new(var.to_string(), constants)
  }
}

