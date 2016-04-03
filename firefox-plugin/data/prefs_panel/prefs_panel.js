var wsaddress = document.getElementById("wsaddress"),
    email = document.getElementById("email"),
    password = document.getElementById("password"),
    proxyaddress = document.getElementById("proxyaddress"),
    timeout = document.getElementById("timeout"),
    profile = document.getElementById("profile"),
    proxyProfiles = document.getElementById("proxyProfiles");

function getCurrentProxyProfile() {
   return document.getElementById("proxyProfiles").value;
}

self.port.on("setprefs", function(prefs) {
  wsaddress.setAttribute("value", prefs.wsaddress);
  email.setAttribute("value", prefs.email);
  password.setAttribute("value", prefs.password);
  proxyaddress.setAttribute("value", prefs.proxyaddress);
  timeout.setAttribute("value", prefs.timeout);
  profile.setAttribute("value", prefs.profile);
  proxyProfiles.innerHTML = '<option value="' + prefs.proxyProfile + '">' + prefs.proxyProfile + '</option>"';
});

self.port.on("setProfiles", function(profiles) {
  proxyProfiles.innerHTML = "";
  profiles.forEach(function(profil) {
    let option = '<option value="' + profil + '">' + profil + '</option>"';
    proxyProfiles.innerHTML += option;
  })
});

window.addEventListener("click", function(event) {
  switch (event.target.getAttribute("title")) {
    case "getProfiles":
      self.port.emit("getProfiles", {email: email.value, password: password.value});
      break;
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
        profile: profile.value,
        proxyProfile: getCurrentProxyProfile()
      });
      self.port.emit("close", "");
      break;
  }
}, false);
