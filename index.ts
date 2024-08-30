// @ts-ignore
import { Elm } from "./src/Main.elm";

// const accessToken = fetch("https://something.com", {
//   method: "GET",
// })
//   .then((resp) => resp.json())
//   .then((data) => data.access_token);

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: window.matchMedia("(prefers-color-scheme: dark)").matches,
});
