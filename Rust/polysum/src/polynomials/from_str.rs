use polynomial_macro::polynomial;

use crate::polynomials::*;
use std::str::FromStr;

use self::ParseState::*;

type Info  = ParsePolynomialErrInfo;
type Error = ParsePolynomialErr;

#[derive(Debug)]
pub struct ParsePolynomialErrInfo {
  pub column: usize,
  pub line: usize,
  pub term: usize,
  pub state: ParseState,
  pub string: String,
  pub polynomial: Polynomial,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum ParseState {
  Start,
  BeforeTerm,
  Numerator,
  AfterNumerator,
  BeforeDenominator,
  Denominator,
  BeforeVariable,
  Variable,
  AfterVariable,
  BeforeRaise,
  BeforeExponent,
  Exponent,
  AfterTerm,
  BeforeOperator,
}

#[derive(Debug)]
pub enum ParsePolynomialErr {
  UnexpectedChar(Info, char),
  UnexpectedEnd(Info),
  MultipleVariables(Info, String, String),
  ZeroExponent(Info),
}

impl Info {
  pub fn new(column: usize, line: usize, term: usize,
             state: ParseState, string: String, polynomial: Polynomial) -> Info {
    Info {
      column,
      line,
      term,
      state,
      string,
      polynomial
    }
  }
}

impl FromStr for Polynomial {
  type Err = Error;

  fn from_str(s: &str) -> Result<Self, Self::Err> {
    let mut constants   = vec![];
    let mut numerator   = String::new();
    let mut denominator = String::new();
    let mut exponent    = String::new();
    let mut variable    = String::new();
    let mut sign        = String::new();

    let mut final_variable = None;

    let mut state  = Start;
    let mut line   = 0;
    let mut column = 0;

    macro_rules! make_polynomial {
      () => {
        match final_variable {
          None => {
            polynomial!(_none_;)
          },
          Some(ref v) => {
            Polynomial::new(String::clone(v), constants)
          }
        }
      }
    }

    macro_rules! assert_variable {
      () => {
        match &final_variable {
          &None => {
            final_variable = Some(variable.clone());
          },

          &Some(ref v) => {
            if &variable != v {
              parse_error!(MultipleVariables(v.clone(), variable.clone()))
            }
          }
        }
      }
    }

    macro_rules! parse_error {
      ($err:ident($($args:expr),*)) => {
        parse_error!($err($($args),*), make_polynomial!())
      };

      ($err:ident($($args:expr),*), $polynomial:expr) => {{
        let term = constants.len();
        return Err(
          ParsePolynomialErr::$err(
            Info::new(column, line, term, state, String::from(s), $polynomial),
            $($args),*
          )
        )
      }}
    }

    macro_rules! error_unless_whitespace {
      ($c:ident) => {
        if !$c.is_whitespace() {
          parse_error!(UnexpectedChar($c));
        }
      }
    }

    macro_rules! next_if_whitespace {
      ($c:ident, $next:expr) => {
        if $c.is_whitespace() {
          state = $next;
        } else {
          parse_error!(UnexpectedChar($c));
        }
      }
    }

    macro_rules! add_term {
      () => {{
        let inumer: Integer = numerator.parse().unwrap();
        let idenom: Integer = denominator.parse().unwrap();
        let iexpon: usize   = exponent.parse().unwrap();

        let isign = if &sign == "+" {1} else {-1};

        if iexpon == 0 {
          parse_error!(ZeroExponent());
        }

        let constant = Rational::from((isign * inumer, idenom));
        while iexpon-1 >= constants.len() {
          constants.push(Rational::from((0,1)));
        }
        constants[iexpon-1] += constant;
        numerator.clear();
        denominator.clear();
        exponent.clear();
        variable.clear();
        sign.clear();
      }}
    }


    for c in s.chars() {
      match state {
        Start | BeforeTerm => {
          match c {
            '+'|'-' => {
              if state == Start {
                sign.push(c);
                state = BeforeTerm;

              } else {
                parse_error!(UnexpectedChar(c));
              }
            },

            '0'...'9' => {
              if state == Start {
                sign.push('+');
              }
              numerator.push(c);
              state = Numerator;
            },

            'a'...'z' | 'A'...'Z' => {
              if state == Start {
                sign.push('+');
              }
              numerator.push('1');
              denominator.push('1');
              variable.push(c);
              state = Variable;
            },
            _ => error_unless_whitespace!(c)
          }
        },

        Numerator => {
          match c {
            '0'...'9' => {
              numerator.push(c);
            },
            '/' => {
              state = BeforeDenominator;
            },
            'a'...'z' | 'A'...'Z' => {
              denominator.push('1');
              variable.push(c);
              state = Variable;
            },
            _ => next_if_whitespace!(c, AfterNumerator)
          }
        },

        AfterNumerator => {
          match c {
            '/' => {
              state = BeforeDenominator;
            },
            'a'...'z' | 'A'...'Z' => {
              denominator.push('1');
              variable.push(c);
              state = Variable;
            },
            _ => error_unless_whitespace!(c)
          }
        },

        BeforeDenominator => {
          match c {
            '0'...'9' => {
              denominator.push(c);
              state = Denominator;
            },
            _ => error_unless_whitespace!(c)
          }
        },

        Denominator => {
          match c {
            '0'...'9' => {
              denominator.push(c);
            },
            'a'...'z' | 'A'...'Z' => {
              variable.push(c);
              state = Variable;
            },
            _ => next_if_whitespace!(c, BeforeVariable)
          }
        },

        BeforeVariable => {
          match c {
            'a'...'z' | 'A'...'Z' => {
              variable.push(c);
              state = Variable;
            },
            _ => error_unless_whitespace!(c)
          }
        },

        Variable => {
          match c {
            'a'...'z' | 'A'...'Z' => {
              variable.push(c);
            },
            '^' => {
              assert_variable!();
              state = BeforeExponent;
            },
            _ => next_if_whitespace!(c, AfterVariable)
          }
        },

        BeforeRaise => {
          match c {
            '^' => {
              state = BeforeExponent;
            },

            '+'|'-' => {
              exponent.push('1');
              add_term!();
              sign.push(c);
              state = BeforeTerm;
            },

            _ => error_unless_whitespace!(c)
          }
        },

        BeforeExponent => {
          match c {
            '0'...'9' => {
              exponent.push(c);
              state = Exponent;
            },

            _ => error_unless_whitespace!(c)
          }
        },

        Exponent => {
          match c {
            '0'...'9' => {
              exponent.push(c);
            }

            _ => next_if_whitespace!(c, AfterTerm)
          }
        },

        BeforeOperator => {
          match c {
            '+'|'-' => {
              sign.push(c);
              state = BeforeTerm;
            },
            _ => error_unless_whitespace!(c)
          }
        },

        AfterVariable | AfterTerm => unreachable!()
      }

      match state {
        AfterVariable => {
          assert_variable!();
          state = BeforeRaise;
        },

        AfterTerm => {
          add_term!();
          state = BeforeOperator;
        },

        _ => ()
      }

      if c == '\n' {
        line += 1;
        column = 0;
      } else {
        column += 1;
      }
    }
    match state {

      Variable => {
        assert_variable!();
        exponent.push('1');
        add_term!();
        Ok(make_polynomial!())
      },

      Exponent => {
        add_term!();
        Ok(make_polynomial!())
      },

      BeforeOperator => {
        Ok(make_polynomial!())
      },

      _ => parse_error!(UnexpectedEnd())
    }
  }
}


