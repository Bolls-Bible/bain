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

// If we're on electron or android client -- redirect the links to external login page
if (navigator.userAgent.includes("bolls")) {
  document.querySelectorAll(".with").forEach((el) => {
    el.target = "_blank";
    el.href = el.href.replace("login", "client-app-login");
  });
  console.log(document.querySelectorAll(".with"));
}
