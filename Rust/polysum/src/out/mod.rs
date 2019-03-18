pub mod latex;
use rug::Rational;

pub trait AsOutput {
  fn latex(&self) -> String;
}

impl AsOutput for Rational {
  fn latex(&self) -> String {
    format!("\\frac{{{}}}{{{}}}", self.numer(), self.denom())
  }
}

impl AsOutput for usize {
  fn latex(&self) -> String {
    format!("{{{}}}", self)
  }
}
