var notification = require("sdk/notifications");
    
function checkEmpty(obj) {
  for (let prop in obj) { 
    if (obj.hasOwnProperty(prop)) { 
      return false;
    }
  }
  return true;
}

function notify(message) {
  notification.notify({
    title: "BProxy message",
    text: message
  });
}

exports.checkEmpty = checkEmpty;
exports.notify = notify;
