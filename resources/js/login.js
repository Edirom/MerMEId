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
    document.getElementById("login-modal").style.display = "none"
    if(this.classList.contains('submit')) {
        const inputs = document.getElementById("login-modal").querySelectorAll('input')
        ajaxLogin(inputs[0].value, inputs[1].value)
    } 
}

/*
 * make AJAX request
 * if no user and pass are provided, the current user information is returned
 * if user=logout and pass=logout, the current user gets logged out and the session invalidated
 * if user and pass are provided, the new user information is returned  
 */
function ajaxLogin(user, pass) {
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
    else if(user && pass) {
        postBody = "user=" + user + "&password=" + pass;
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
window.addEventListener("focus", ajaxLogin);
