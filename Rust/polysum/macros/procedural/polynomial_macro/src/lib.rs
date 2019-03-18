#![feature(box_syntax, box_patterns)]

extern crate proc_macro;
extern crate proc_macro2;
#[macro_use]
extern crate syn;
#[macro_use]
extern crate quote;

use proc_macro::{TokenStream};
use syn::{Ident, LitInt, IntSuffix};
use syn::parse::{Parse, ParseStream, Result};
use proc_macro2::{Span};

type TokenStream2 = proc_macro2::TokenStream;

struct PolynomialExpr {
  var: Ident,
  constants: Vec<ConstantExpr>
}

struct ConstantExpr {
  numer: NumberExpr,
  denom: NumberExpr,
}

enum NumberExpr {
  Positive(LitInt),
  Negative(LitInt)
}

impl Parse for PolynomialExpr {
  fn parse(input: ParseStream) -> Result<Self> {
    let var: Ident = input.parse()?;
    input.parse::<Token![;]>()?;

    let mut constants = vec![];
    while !input.is_empty() {
      constants.push(input.parse()?);
      if !input.is_empty() {
        input.parse::<Token![,]>()?;
      }
    }

    Ok(PolynomialExpr { var, constants })
  }
}

impl Parse for ConstantExpr {
  fn parse(input: ParseStream) -> Result<Self> {
    let numer: NumberExpr;
    let denom: NumberExpr;

    numer = input.parse()?;

    if input.is_empty() || input.peek(Token![,]) {
      denom = one();
    } else {
      input.parse::<Token![/]>()?;
      denom = input.parse()?;
    }

    Ok(ConstantExpr { numer, denom })
  }
}

impl Parse for NumberExpr {
  fn parse(input: ParseStream) -> Result<Self> {
    if input.peek(Token![-]) {
      input.parse::<Token![-]>()?;
      Ok(NumberExpr::Negative(input.parse()?))
    } else {
      Ok(NumberExpr::Positive(input.parse()?))
    }
  }
}

#[proc_macro]
pub fn polynomial(input: TokenStream) -> TokenStream {
  let ast = parse_macro_input!(input as PolynomialExpr);
  expand_polynomial_ast(ast)
}

fn expand_polynomial_ast(ast: PolynomialExpr) -> TokenStream {
  let PolynomialExpr { var, constants } = ast;
  let rationals: Vec<_> = constants.iter().map(constant_as_rational).collect();
  let expanded = quote! {
    Polynomial::new(
      String::from(stringify!(#var)),
      vec![#(#rationals),*]
    )
  };
  TokenStream::from(expanded)
}

fn one() -> NumberExpr {
  NumberExpr::Positive(LitInt::new(1, IntSuffix::I64, Span::call_site()))
}

fn constant_as_rational(constant: &ConstantExpr) -> TokenStream2 {
  let numer = number_tokens(&constant.numer);
  let denom = number_tokens(&constant.denom);

  quote! { rug::Rational::from((#numer, #denom)) }
}

fn number_tokens(number: &NumberExpr) -> TokenStream2 {
  match number {
    NumberExpr::Positive(n) => quote! { #n },
    NumberExpr::Negative(n) => quote! { -#n },
  }
}
