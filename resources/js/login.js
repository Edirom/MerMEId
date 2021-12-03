/*
 * activate modal with login form
 * or logout user 
 */
function showModal() {
    const user = document.getElementById("login-info").getAttribute("data-user");
    if(user) { 
        ajaxLogin("logout", "logout") 
    }
    else {
        document.getElementById("login-modal").style.display = "block";
    }
}

/*
 * close the modal on request
 * and login on submit
 */
function closeModal() {
    if(this.classList.contains('submit')) {
        const inputs = document.getElementById("login-modal").querySelectorAll('input')
        ajaxLogin(inputs[0].value, inputs[1].value, inputs[2].checked)
    }
    document.getElementById("login-modal").style.display = "none";
}

/*
 * make AJAX request
 * if no user and pass are provided, the current user information is returned
 * if user=logout and pass=logout, the current user gets logged out and the session invalidated
 * if user and pass are provided, the new user information is returned  
 */
function ajaxLogin(user, pass, dur) {
    const xhttp = new XMLHttpRequest();
    let postBody;
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            updateLoginInfo(JSON.parse(this.responseText));
        }
    };
    if(user === "logout" && pass === "logout") {
        postBody = "logout=logout";
    }
    // password might be empty, so allow for empty string but reject every other undefined value
    else if(user && (typeof pass === 'string' || pass instanceof String)) {
        postBody = "user=" + user + "&password=" + pass;
        if(dur) {
            postBody += "&duration=P14D"
        }
    }
    
    xhttp.open("POST", "login", true);
    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhttp.send(postBody);
}

/*
 * update the login icon in the top menu
 */
function updateLoginInfo(obj) {
    const info = document.getElementById("login-info")
    if(obj.user) {
        info.setAttribute("data-user", obj.user);
        info.innerHTML = obj.user;
    }
    else {
        info.setAttribute("data-user", "");
        info.innerHTML = "Login";
    }
}

document.getElementById("login-info").addEventListener("click", showModal, false);
document.querySelectorAll(".close-modal").forEach(el => {el.addEventListener("click", closeModal, false)});
document.querySelectorAll(".loginRequired input").forEach(el => {el.setAttribute('disabled', 'disabled')});
document.querySelectorAll(".loginRequired a").forEach(el => {el.style.pointerEvents = "none"});
window.addEventListener("focus", ajaxLogin);
