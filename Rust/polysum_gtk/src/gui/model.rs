use polynomial_macro::polynomial;

use polysum::out::{self, AsOutput};
use polysum::polynomials::Polynomial;
use polysum::approx;

use crate::gui::style;

use std::process::Command;
use std::fs::File;
use std::io::Write;

use tempfile::tempdir;

use relm_derive::Msg;
use relm_attributes::*;

use relm::{
  self,
  connect,
  connect_stream,
  Widget
};

use gtk::{
  BoxExt,
  ButtonExt,
  LabelExt,
  EntryExt,
  OrientableExt,
  WidgetExt,
  GtkWindowExt,
  TextViewExt,
  TextBufferExt,
  CssProviderExt,
  StyleContext,
  StyleContextExt,
  ScrolledWindowExt,
  Inhibit
};

use gtk::Orientation::{Vertical, Horizontal};

use gdk::{self, enums::key};

use self::Msg::*;

pub struct Model {
  result: Polynomial,
}

#[derive(Msg)]
pub enum Msg {
  SendPolynomial,
  KeyOnInput(key::Key),
  ShowLatex,
  Quit
}

pub fn add_class<W: WidgetExt>(widget: &mut W, class: &str) {
  if let Some(context) = widget.get_style_context() {
    context.add_class(class);
  }
}

#[widget]
impl Widget for Win {
  fn model() -> Model {
    Model {
      result: polynomial!(x;),
    }
  }

  fn init_view(&mut self) {
    let css_provider = gtk::CssProvider::new();
    if let Err(e) = css_provider.load_from_data(style::CSS.as_bytes()) {
      println!("Error: {:?}", e);
    }

    self.window.set_default_size(800, 640);
    self.window.resize(800, 640);

    self.result_scroll.set_policy(
      gtk::PolicyType::Never,
      gtk::PolicyType::Automatic
    );

    add_class(&mut self.polynomial_label, "polynomial-label");
    add_class(&mut self.result_label,     "result-label");
    add_class(&mut self.main_box,         "main-box");
    add_class(&mut self.result,           "polynomial-terms");
    add_class(&mut self.polynomial,       "polynomial-terms");

    if let Some(screen) = self.window.get_screen() {
      StyleContext::add_provider_for_screen(
        &screen,
        &css_provider,
        gtk::STYLE_PROVIDER_PRIORITY_USER
      );
    }
  }

  fn update(&mut self, event: Msg) {
    match event {
      SendPolynomial             |
      KeyOnInput(key::Return)    |
      KeyOnInput(key::KP_Enter)  |
      KeyOnInput(key::ISO_Enter) => {
        self.send_polynomial();
      },

      ShowLatex => {
        let latex_contents = out::latex::document(&self.model.result.latex());
        if let Ok(latex_directory) = tempdir() {
          let pdf_path   = latex_directory.path().join("file.pdf");
          let latex_path = latex_directory.path().join("file.tex");

          if let Ok(mut latex_file) = File::create(&latex_path) {
            if let Ok(_) = write!(latex_file, "{}", &latex_contents) {

              if let Ok(_) =
                Command::new("pdflatex")
                  .arg("-output-directory")
                  .arg(&latex_directory.path())
                  .arg(&latex_path)
                  .output() {

                if let Ok(_) = Command::new("xreader").arg(&pdf_path).output() {
                }
              }
            }
          }
        }
      },

      Quit => {
        gtk::main_quit();
      },

      _ => ()
    }
  }

  view! {
    #[name="window"]
    gtk::Window {
      title: "PolySum",
      gravity: gdk::Gravity::Center,
      #[name="main_box"]
      gtk::Box {
        orientation: Vertical,
        spacing: 10,

        #[name="polynomial_label"]
        gtk::Label {
          halign: gtk::Align::Start,
          text: "Polinômio:",
        },

        gtk::Box {
          orientation: Horizontal,
          spacing: 4,
          #[name="polynomial"]
          gtk::Entry {
            hexpand: true,
            key_press_event(_,e) => (KeyOnInput(e.get_keyval()), Inhibit(false))
          },
          gtk::Button {
            label: ">>",
            clicked => SendPolynomial,
          }
        },

        gtk::Box {
          orientation: Horizontal,
          spacing: 10,

          #[name="result_label"]
          gtk::Label {
            halign: gtk::Align::Start,
            text: "Resultado:",
          },

          #[name="latex_button"]
          gtk::Button {
            label: "Latex",
            clicked => ShowLatex,
          },
        },

        #[name="result_scroll"]
        gtk::ScrolledWindow {
          #[name="result"]
          gtk::TextView {
            editable: true,
            vexpand: true,
            hexpand: false,
            overwrite: false,
            wrap_mode: gtk::WrapMode::WordChar
          }
        },

        gtk::Box {
          spacing: 10,
          orientation: Horizontal,
          halign: gtk::Align::Center,

          gtk::Button {
            label: "<"
          },

          #[name="current_page"]
          gtk::Label {
            text: "1"
          },

          gtk::Label {
            text: "/"
          },

          #[name="last_page"]
          gtk::Label {
            text: "1"
          },

          gtk::Button {
            label: ">"
          },
        }
      },
      delete_event(_,_) => (Quit, Inhibit(false))
    }
  }
}

impl Win {
  fn send_polynomial(&mut self) {
    if let Some(src) = self.polynomial.get_text() {
      if let Ok(polynomial) = src.parse() {
        let result = approx::sum(&polynomial);
        if let Some(buffer) = self.result.get_buffer() {
          println!("n: {}", result.to_string().len());
          buffer.set_text(&result.to_string());
          self.model.result = result;
        }
      }
    }
  }
}

