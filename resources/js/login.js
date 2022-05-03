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
        ajaxLogin(inputs[0].value, inputs[1].value)
    }
    document.getElementById("login-modal").style.display = "none";
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
    // password might be empty, so allow for empty string but reject every other undefined value
    else if(user && (typeof pass === 'string' || pass instanceof String)) {
        postBody = "user=" + user + "&password=" + pass;
    }
    
    xhttp.open("POST", "login", true);
    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhttp.send(postBody);
}

/*
 * update the login icon in the top menu
 * and toggle classes for edit buttons
 */
function updateLoginInfo(obj) {
    const info = document.getElementById("login-info")
    if(obj.user) {
        info.setAttribute("data-user", obj.user);
        info.innerHTML = obj.user;
        // toggle classes
        toggleButtons('show');
    }
    else {
        info.setAttribute("data-user", "");
        info.innerHTML = "Login";
        // toggle classes
        toggleButtons('hide');
    }
}

/*
 * Toggle css and events for edit buttons
 * param: hide|show
 */
function toggleButtons(status) {
    // input elements toggle the "disabled" attribute
    document.querySelectorAll(".loginRequired input").forEach(el => {
        if(status === 'show') {
            el.removeAttribute('disabled');
            el.parentElement.parentElement.classList.add(status);
        }
        else {
            el.setAttribute('disabled', 'disabled');
            el.parentElement.parentElement.classList.remove('show');
        }
    });
    // all other elements toggle the pointerEvents and toggle the class "show" 
    document.querySelectorAll(".loginRequired a, .loginRequired img, .loginRequired label").forEach(el => {
        if(status === 'show') {
            el.style.pointerEvents = "auto";
            el.parentElement.classList.add(status);
        }
        else {
            el.style.pointerEvents = "none";
            el.parentElement.classList.remove('show');
        }
    });
}

document.getElementById("login-info").addEventListener("click", showModal, false);
document.querySelectorAll(".close-modal").forEach(el => {el.addEventListener("click", closeModal, false)});

/*
 * add (main) event listener on load and on focus change
 * this will trigger and propagate 
 * all changes to login form and buttons
 */
window.addEventListener("focus", ajaxLogin);
window.addEventListener("load", ajaxLogin);

/*
 * close modal on escape key press
 */
document.addEventListener('keydown', evt => {
    if (evt.key === 'Escape') {
        document.getElementById("login-modal").style.display = "none";
    }
});
