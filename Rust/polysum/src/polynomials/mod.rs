mod terms;
mod from_str;
mod ops;
//mod iter;

use terms::*;
//use iter::*;
use crate::out::AsOutput;

use std::fmt;
use rug::{Rational, Integer, ops::NegAssign};

#[derive(Debug, Clone)]
pub struct Polynomial {
  var: Var,
  constants: Vec<Rational>,
}

impl Polynomial {
  pub fn new<S: ToString>(variable: S, constants: Vec<Rational>) -> Polynomial {
    Polynomial {
      var: Var::new(variable.to_string()),
      constants
    }
  }

  pub fn len(&self) -> usize {
    self.constants.len()
  }

  pub fn degree(&self) -> usize {
    for i in (0..self.len()).rev() {
      if self.constants[i] != 0 {
        return i + 1;
      }
    }
    return 0;
  }

  pub fn pad_terms(&mut self, upto: usize) {
    while self.constants.len() < upto {
      self.constants.push(Rational::from((0, 1)));
    }
  }

  pub fn negate(&mut self) {
    for constant in &mut self.constants {
      constant.neg_assign();
    }
  }

  pub fn constant(&self, i: usize) -> &Rational {
    &self.constants[i]
  }

  pub fn constant_mut(&mut self, i: usize) -> &mut Rational {
    &mut self.constants[i]
  }

  /*
  pub fn iter_consts(&self) -> ConstantIterator {
    ConstantIterator::new(self)
  }

  pub fn iter_consts_mut<'a>(&'a mut self) -> ConstantIteratorMut<'a> {
    ConstantIteratorMut::new(self)
  }
  */

  pub fn variable(&self) -> &Var {
    &self.var
  }

  fn format<'a, F: Fn(&Term<'a>) -> String>(&'a self, term_formatter: &F) -> String {
    let mut result = String::new();
    for exp in 0..self.constants.len() {
      let constant = &self.constants[exp];

      if constant != &0 {
        if result.len() != 0 {
          if constant > &0 {
            result.push_str(" + ");
          } else {
            result.push_str(" - ");
          }
        }
        let term = Term::new(&self.var, constant, exp+1);
        result.push_str(&term_formatter(&term));
      }
    }
    return result;
  }
}

impl AsOutput for Polynomial {
  fn latex(&self) -> String {
    self.format(&Term::latex)
  }
}

impl<'a> fmt::Display for Polynomial {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "{}", self.format(&Term::to_string))
  }
}

