use crate::out::AsOutput;

use rug::Rational;
use std::fmt;
use std::string::ToString;

#[derive(Debug, Clone, PartialEq)]
pub struct Var {
  name: String
}

impl Var {
  pub fn new(name: String) -> Var {
    Var {
      name
    }
  }
}

#[derive(Debug, Clone)]
pub struct Term<'a> {
  pub variable: &'a Var,
  pub constant: Rational,
  pub exponent: usize
}

impl<'a> Term<'a> {
  pub fn new(variable: &'a Var, constant: &'a Rational, exponent: usize) -> Term<'a> {
    Term {
      variable,
      exponent,
      constant: constant.as_abs().clone()
    }
  }

  pub fn format <
    FV: Fn(&'a Var) -> String,
    FC: Fn(&'a Rational) -> String,
    FE: Fn(&usize) -> String
  >
  (&'a self, fv: &FV, fc: &FC, fe: &FE) -> String {
    let constant;
    let exponent;
    let variable = fv(self.variable);

    if self.constant == 1 {
      constant = String::new();
    } else {
      constant = fc(&self.constant)
    }

    if self.exponent == 1 {
      exponent = String::new();
    } else {
      exponent = format!("^{}", fe(&self.exponent));
    }

    format!("{}{}{}", constant, variable, exponent)
  }
}

macro_rules! format_term {
  ($self:expr, $func:expr) => {
    $self.format(&$func, &$func, &$func)
  }
}

impl AsOutput for Var {
  fn latex(&self) -> String {
    format!("{}", self)
  }
}

impl<'a> AsOutput for Term<'a> {
  fn latex(&self) -> String {
    format_term!(self, AsOutput::latex)
  }
}

impl fmt::Display for Var {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "{}", &self.name)
  }
}

impl<'a> fmt::Display for Term<'a> {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "{}", format_term!(self, ToString::to_string))
  }
}

