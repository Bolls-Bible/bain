if (window.localStorage.getItem('theme')) {
	document.lastChild.dataset.theme = window.localStorage.getItem('theme');
}

let form = document.forms[0];
let i = 0;
for (i;i < form.children.length; i++) {
	if (form.children[i].tagName == 'INPUT' && (form.children[i].type == 'text' || form.children[i].type == 'password' || form.children[i].type == 'email')) {
		form.children[i].placeholder = form.children[i].previousElementSibling.innerText
	}
}