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

function filecopy(ev) {
    ev.preventDefault();
    var source = ev.target[0].value, target, overwrite=false;
    target = prompt("Copy " + source + " to:", source.substring(0, source.length -4) + "-copy.xml");
    const xhttp = new XMLHttpRequest();
    xhttp.open("POST", "../data/copy", true);
    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhttp.send("source="+source+"&target="+target+"&overwrite="+overwrite);
}

document.querySelectorAll(".copyform").forEach(el => {el.addEventListener("submit", filecopy)});
