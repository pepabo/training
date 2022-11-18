"use strict";

document.addEventListener("DOMContentLoaded", function() {
  var code = document.getElementsByTagName("code"); 
  for (var i = 0; i < code.length; i++) {
    var el = code[i];
    if (el.className) {
      var s = el.className.split(":");
      var highlightLang = s[0];
      var filename = s[1];
      if (filename) {
        el.classList.remove(el.className);
        el.classList.add(highlightLang);
        el.parentElement.setAttribute("data-lang", filename);
        el.parentElement.classList.add("code-block-header");
      }
    }
  }
});

