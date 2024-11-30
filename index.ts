// @ts-ignore
import { Elm } from "./src/Main.elm";

fetch("https://asx.api.markitdigital.com/asx-research/1.0/bbsw/rates", {
  method: "GET",
})
  .then((resp) => resp.json())
  .then((data) => {
    const app = Elm.Main.init({
      node: document.querySelector("main"),
      flags: data,
    });
  });
