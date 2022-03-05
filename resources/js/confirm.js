/*
 * main event handler for the forms on the main page
 * it will simply show the modal and clone all inputs etc
 * to the modal form 
 */
function ajaxform(ev) {
    ev.preventDefault();
    const curForm = ev.target,
        orgButton = curForm.querySelector("button[type=submit]");
    
    // remove class information from the status message to hide it initially
    document.getElementById("confirm_modal_statusmessage").className = "";
    // set the title of the modal
    document.getElementById("confirm_modal_heading").innerHTML = ev.target.getAttribute("title");
    // copy the action and method attribute to the modal form
    document.querySelector("#confirm_modal form").setAttribute("action", curForm.getAttribute("action"));
    document.querySelector("#confirm_modal form").setAttribute("method", curForm.getAttribute("method"));
    // empty the modal body
    document.getElementById("confirm_modal_body").innerHTML = "";
    // fill the modal body by (deep) cloning inputs and labels from the original form
    curForm.querySelectorAll(".ajaxform_input, .ajaxform_label").forEach(function(p) {
        document.getElementById("confirm_modal_body").appendChild(p.cloneNode(true));
    })
    // add the submit button by (shallow) cloning the original button 
    document.getElementById("confirm_modal_body").appendChild(orgButton.cloneNode(false)).innerHTML=orgButton.value;
    // finally show the modal
    document.getElementById("confirm_modal").style.display = "block";
}

/*
 * event handler for the modal form
 * it will call the backend crud functions via AJAX and
 * update the main table if successfull  
 */
function modal_submit_handler(ev) {
    ev.preventDefault();
    const curForm = ev.target,
        endpoint = new URL(curForm.getAttribute("action")),
        method = curForm.getAttribute("method");
        params = new URLSearchParams(new FormData(curForm));
    
    fetch(endpoint, {
        method: method,
        headers: {
            "Content-type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
        },
        body: params
    })
    .then(response => {
        if (!response.ok) {
            throw response;
        }
        return response.json();
    })
    .then(data => {
        update_statusmessage(data, "info");
        setTimeout(() => {  
            document.getElementById("confirm_modal").style.display = "none";
            if(endpoint.pathname === '/data/create') {
                // for new documents, directly redirect to the edit page 
                window.location.href = '../forms/edit-work-case.xml?doc=' + params.get('filename');
            }
            else { 
                // for all other actions, reload the list page
                // (instead of simply reloading the page we might update the table dynamically)
                location.reload(); 
            }
        }, 1000);
        
    })
    .catch(error => {
        if (typeof error.json === 'function') {
        error.json().then(
            obj => {
                update_statusmessage(obj, "error");
            } 
        )}
        else {
            update_statusmessage("Some unknown error occured", "error");
        }
    })
};

/*
 * helper function for modal_submit_handler()
 */
function update_statusmessage(obj, classname) {
    if(obj.constructor === Array) {
        document.getElementById("confirm_modal_statusmessage").innerHTML = obj[0].message;
        document.getElementById("confirm_modal_statusmessage").className = classname;
    }
    else {
        document.getElementById("confirm_modal_statusmessage").innerHTML = obj.message;
        document.getElementById("confirm_modal_statusmessage").className = classname;
    }
}

/*
 * Generic form submit event handler for the main page
 * to capture clicks on e.g. "copy", or "rename" buttons  
 */
document.querySelectorAll(".ajaxform").forEach(el => {el.addEventListener("submit", ajaxform)});
document.querySelector("#confirm_modal form").addEventListener("submit", modal_submit_handler); 

/*
 * close modal on click
 */
document.querySelectorAll(".close-modal").forEach(el => {el.addEventListener("click", function(ev) {
    document.getElementById("confirm_modal").style.display = "none";}, false)
});
