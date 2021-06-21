// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import ReactDOM from "react-dom"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "jquery"
import "bootstrap"
import App from "components"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

$("#micropost_image").bind("change", function() {
  var size_in_megabytes = this.files[0].size/1024/1024;
  if (size_in_megabytes > 5) {
    alert("Maximum file size is 5MB. Please choose a smaller file.");
    $("#micropost_image").val("");
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("app")
  if (container) {
    ReactDOM.render(<App />, container)
  }
})
