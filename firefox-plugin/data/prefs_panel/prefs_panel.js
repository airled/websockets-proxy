let wsaddress = document.getElementById("wsaddress"),
    email = document.getElementById("email"),
    password = document.getElementById("password"),
    proxyaddress = document.getElementById("proxyaddress"),
    timeout = document.getElementById("timeout"),
    profile = document.getElementById("profile");

self.port.on("setprefs", function(prefs) {
  wsaddress.setAttribute("value", prefs.wsaddress);
  email.setAttribute("value", prefs.email);
  password.setAttribute("value", prefs.password);
  proxyaddress.setAttribute("value", prefs.proxyaddress);
  timeout.setAttribute("value", prefs.timeout);
  profile.setAttribute("value", prefs.profile);
});

window.addEventListener("click", function(event) {
  switch (event.target.getAttribute("title")) {
    case "close":
      self.port.emit("close", "");
      break;
    case "save":
      self.port.emit("saveprefs", {
        wsaddress: wsaddress.value,
        email: email.value,
        password: password.value,
        proxyaddress: proxyaddress.value,
        timeout: timeout.value,
        profile: profile.value
      });
      self.port.emit("close", "");
      break;
  }
}, false);
