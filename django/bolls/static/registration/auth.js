if (window.localStorage.getItem("theme")) {
  document.lastChild.dataset.theme = window.localStorage.getItem("theme");
}

let form = document.forms[0];
let i = 0;
for (i; i < form.children.length; i++) {
  if (
    form.children[i].tagName == "INPUT" &&
    (form.children[i].type == "text" ||
      form.children[i].type == "password" ||
      form.children[i].type == "email")
  ) {
    form.children[i].placeholder =
      form.children[i].previousElementSibling.innerText;
  }
}

const oauthLinks = document.querySelectorAll(".with");
// If we're on electron or android client -- redirect the links to external login page
if (navigator.userAgent.includes("bolls")) {
  document.querySelectorAll(".with").forEach((el) => {
    el.target = "_blank";
    el.href = el.href.replace("login", "accounts/login?redirect=/login");
  });
}

function getCookie(name) {
  let cookieValue = null;
  if (document.cookie && document.cookie !== "") {
    const cookies = document.cookie.split(";");
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i].trim();
      if (cookie.substring(0, name.length + 1) === name + "=") {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}

function checkOAuthRedirects() {
  const params = new URLSearchParams(window.location.search);
  const redirectUrl = params.get("redirect");
  if (redirectUrl) {
    // If redirectURL is present, then we must check if the user already logged in
    // and if so, we need to redirect to the client app
    const sessionId = getCookie("sessionid");
    if (sessionId) {
      // If the session id is present, then we need to redirect to the client app
      window.localStorage.removeItem("client-app-login");
      window.open(`bolls://bolls.life/login?sessionid=${btoa(sessionId)}`, '_blank');
      window.location.pathname = "/";
      return;
    }

    // Let the frontend know to open the client app once the login is successful
    window.localStorage.setItem("client-app-login", "true");
    window.location.pathname = redirectUrl;
  }
}

checkOAuthRedirects();
