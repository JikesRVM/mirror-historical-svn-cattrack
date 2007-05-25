function is_admin() {
  return readCookie('cattrack_admin') == 'true'
}

function is_uploader() {
  return readCookie('cattrack_uploader') == 'true'
}

function is_authenticated() {
  return readCookie('cattrack_user') != null
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}
