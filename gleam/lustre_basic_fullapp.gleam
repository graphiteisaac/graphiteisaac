// Contained in this file is everything I need to start off a new medium-sized Lustre 
// project, as in, one that starts off already importing `modem` for routing.

import lustre
import lustre/attribute.{class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import modem

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

type Route {
  Home
  NotFound
}

type Model {
  Model(route: Route, hello_msg: String)
}

fn init(_) -> #(Model, Effect(Message)) {
  let route =
    modem.initial_uri()
    |> result.map(fn(uri) { uri.path_segments(uri.path) })
    |> fn(path) {
      case path {
        Ok([]) | Ok(["home"]) -> Home
        _ -> NotFound
      }
    }

  #(Model(route:, hello_msg: "Hello world!"), modem.init(on_url_change))
}

type Message {
  OnRouteChange(Route)

  UserClickedNewHello
}

fn on_url_change(uri: uri.Uri) -> Message {
  case uri.path_segments(uri.path) {
    [] | ["home"] -> OnRouteChange(Home)
    _ -> OnRouteChange(NotFound)
  }
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    OnRouteChange(route) -> #(Model(..model, route:), effect.none())

    UserClickedNewHello -> #(
      Model(..model, hello_msg: "The first one wasn't enough for you? Sicko."),
      effect.none(),
    )
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([class("p-32 mx-auto text-center w-full max-w-2xl space-y-8")], [
    html.h1([class("font-semibold text-2xl")], [
      html.text("Welcome to your new Lustre app"),
    ]),
    html.p([class("mb-3")], [html.text(model.hello_msg)]),
    html.button([event.on_click(UserClickedNewHello)], [
      html.text("Greet me beter!"),
    ]),
  ])
}
