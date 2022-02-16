function show_confirm(formid, text)
{
    var r=confirm("Do you really want to delete the file '" + text +"'?" );
    if (r==true) {
    	var form = document.getElementById(formid);
    	form.submit();
    } else {
    }
}

function filename_prompt(formid, text, published)
{
    if (published) {
        alert("Only unpublished documents can be renamed.\nPlease unpublish the document before renaming it.");
    } else {
        var name = prompt("Rename '" + text +"' to " );
        if (name!=null && name!="") {
        	var form = document.getElementById(formid);
        	form.name.value = name;
        	form.submit();
        } else {
        }
    }
}


/*
 * callback for the copy task
 */
function copyprompt(params) {
    var source = params.get("source"),
        target = prompt("Copy " + source + " to:", source.substring(0, source.length -4) + "-copy.xml");
    params.append('target', target);
}

/*
 * main event handler for the forms on the main page
 */
function ajaxform(ev) {
    ev.preventDefault();
    var source = ev.target[0].value,
        endpoint = new URL(ev.target.getAttribute('action')),
        method = ev.target.getAttribute('method'),
        callback = ev.target.querySelector('[name=callback]').value, 
        params = new URLSearchParams(endpoint.search);
    // append all input name-value pairs (e.g. <input type="hidden" name="callback" value="copyprompt"/>) as URL parameters 
    ev.target.querySelectorAll('input').forEach(
        function(a,b) {
            params.append(a.getAttribute('name'), a.getAttribute('value'))
        }
    )
    // check if a callback function is given
    if(eval("typeof " + callback) === 'function') {
        window[callback](params)
    }
    //console.log(params.toString());
    const xhttp = new XMLHttpRequest();
    xhttp.open(method, endpoint, true);
    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.send(params.toString());
}

/*
 * Generic form submit event handler for the main page
 * to capture clicks on e.g. "copy", or "rename" buttons  
 */
document.querySelectorAll(".ajaxform").forEach(el => {el.addEventListener("submit", ajaxform)});
